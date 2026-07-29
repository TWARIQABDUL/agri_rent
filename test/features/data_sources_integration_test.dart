import 'package:agri_rent/core/services/preferences_service.dart';
import 'package:agri_rent/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agri_rent/features/booking/data/datasources/booking_remote_data_source.dart'
    as checkout_data;
import 'package:agri_rent/features/booking/data/models/booking_model.dart'
    as checkout_data;
import 'package:agri_rent/features/booking/domain/entities/booking.dart'
    as checkout_domain;
import 'package:agri_rent/features/bookings/data/datasources/booking_remote_data_source.dart'
    as operations_data;
import 'package:agri_rent/features/bookings/domain/entities/booking.dart'
    as operations_domain;
import 'package:agri_rent/features/equipment/data/datasources/equipment_remote_data_source.dart';
import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:agri_rent/features/owner/data/datasources/owner_remote_data_source.dart';
import 'package:agri_rent/features/owner/domain/entities/listing_draft.dart';
import 'package:agri_rent/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:agri_rent/features/wallet/domain/exceptions/wallet_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

const favoriteEquipment = Equipment(
  id: 'equipment-1',
  name: 'John Deere 5050D',
  ownerId: 'owner-1',
  ownerName: 'Patrick',
  description: 'A reliable tractor for ploughing and planting.',
  pricePerDay: 25000,
  pricePerMonth: 500000,
  status: EquipmentStatus.available,
  category: 'Tractors',
  image: '',
  location: 'Musanze',
  rating: 4.8,
  reviewCount: 12,
  pricePerHour: 5000,
  pricePerHectare: 18000,
  specs: {'Power': '50 HP'},
);

checkout_data.BookingModel checkoutBooking({
  String farmerId = 'farmer-1',
  double total = 52500,
  String rateType = checkout_domain.RateType.day,
  int duration = 2,
}) {
  return checkout_data.BookingModel(
    id: '',
    equipmentId: favoriteEquipment.id,
    equipmentName: favoriteEquipment.name,
    equipmentCategory: favoriteEquipment.category,
    equipmentImage: '',
    farmerId: farmerId,
    farmerName: 'Alice',
    ownerId: favoriteEquipment.ownerId,
    ownerName: favoriteEquipment.ownerName,
    rateType: rateType,
    rate: 25000,
    duration: duration,
    startDate: DateTime(2026, 7, 30),
    subtotal: 50000,
    serviceFee: 2500,
    total: total,
    status: checkout_domain.BookingStatus.pending,
    createdAt: DateTime(2026, 7, 29),
  );
}

Map<String, dynamic> rentalData({
  String renterId = 'farmer-1',
  String ownerId = 'owner-1',
  String status = 'pending',
  DateTime? createdAt,
}) {
  return {
    'renterId': renterId,
    'renterName': 'Alice',
    'ownerId': ownerId,
    'ownerName': 'Patrick',
    'equipmentId': 'equipment-1',
    'equipmentName': 'John Deere 5050D',
    'equipmentCategory': 'Tractors',
    'equipmentImage': '',
    'startDate': Timestamp.fromDate(DateTime(2026, 7, 30)),
    'endDate': Timestamp.fromDate(DateTime(2026, 8, 1)),
    'rateType': 'day',
    'duration': 2,
    'rate': 25000,
    'subtotal': 50000,
    'serviceFee': 2500,
    'totalAmount': 52500,
    'status': status,
    'paidOut': false,
    'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 7, 29)),
    'updatedAt': Timestamp.fromDate(DateTime(2026, 7, 29)),
  };
}

void main() {
  test(
    'equipment and favorites data sources use real Firestore-shaped data',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('equipment').doc('equipment-1').set({
        ...rentalEquipmentMap(),
        'status': EquipmentStatus.available,
        'category': 'Tractors',
      });
      await firestore.collection('equipment').doc('equipment-2').set({
        ...rentalEquipmentMap(name: 'Water Pump', category: 'Pumps'),
        'status': EquipmentStatus.available,
      });
      await firestore.collection('equipment').doc('paused').set({
        ...rentalEquipmentMap(name: 'Paused Tractor'),
        'status': EquipmentStatus.paused,
        'category': 'Tractors',
      });

      final equipmentSource = EquipmentRemoteDataSourceImpl(firestore);
      expect((await equipmentSource.getEquipment()).length, 2);
      final tractors = await equipmentSource.getEquipment(category: 'Tractors');
      expect(tractors.single.id, 'equipment-1');
      expect(tractors.single.ownerName, 'Patrick');

      final favorites = FavoritesRemoteDataSourceImpl(firestore);
      await favorites.addFavorite(
        userId: 'farmer-1',
        equipment: favoriteEquipment,
      );
      final saved = await favorites
          .watchFavorites('farmer-1')
          .firstWhere((items) => items.isNotEmpty);
      expect(saved.single.name, favoriteEquipment.name);
      expect(saved.single.specs['Power'], '50 HP');
      await favorites.removeFavorite(
        userId: 'farmer-1',
        equipmentId: favoriteEquipment.id,
      );
      expect(await favorites.watchFavorites('farmer-1').first, isEmpty);
    },
  );

  test(
    'wallet data source initializes, tops up, and streams its ledger',
    () async {
      final firestore = FakeFirebaseFirestore();
      final source = WalletRemoteDataSourceImpl(firestore);

      await source.ensureWallet('farmer-1');
      await source.ensureWallet('farmer-1');
      expect((await source.watchWallet('farmer-1').first).balance, 0);

      await source.topUp(userId: 'farmer-1', amount: 25000);
      expect(
        (await source
                .watchWallet('farmer-1')
                .firstWhere((wallet) => wallet.balance == 25000))
            .balance,
        25000,
      );
      final activities = await source
          .watchActivities('farmer-1')
          .firstWhere((items) => items.isNotEmpty);
      expect(activities.single.amount, 25000);
      expect(activities.single.isCredit, isTrue);

      await expectLater(
        source.topUp(userId: 'farmer-1', amount: 0),
        throwsArgumentError,
      );
      await expectLater(
        source.topUp(userId: 'missing-wallet', amount: 1000),
        throwsStateError,
      );
    },
  );

  test(
    'checkout atomically debits wallet, writes ledger, and creates rental',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('wallets').doc('farmer-1').set({
        'userId': 'farmer-1',
        'balance': 100000,
        'currency': 'RWF',
      });
      final source = checkout_data.BookingRemoteDataSourceImpl(firestore);
      final created = await source.createBooking(checkoutBooking());
      expect(created.id, isNotEmpty);
      expect(created.walletTransactionId, isNotEmpty);
      expect(created.paymentStatus, checkout_domain.BookingPaymentStatus.paid);

      final wallet = await firestore
          .collection('wallets')
          .doc('farmer-1')
          .get();
      expect(wallet.data()!['balance'], 47500);
      final rental = await firestore
          .collection('rentals')
          .doc(created.id)
          .get();
      expect(rental.data()!['paymentStatus'], 'paid');
      expect(
        rental.data()!['walletTransactionId'],
        created.walletTransactionId,
      );
      final activity = await firestore
          .collection('wallets')
          .doc('farmer-1')
          .collection('transactions')
          .doc(created.walletTransactionId)
          .get();
      expect(activity.data()!['amount'], -52500);
      expect(activity.data()!['rentalId'], created.id);

      await expectLater(
        source.createBooking(checkoutBooking(total: 90000)),
        throwsA(isA<InsufficientWalletBalanceException>()),
      );
      await expectLater(
        source.createBooking(
          checkoutBooking(farmerId: 'wallet-does-not-exist'),
        ),
        throwsA(isA<InsufficientWalletBalanceException>()),
      );
    },
  );

  test('booking operations stream, sort, update, and delete rentals', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore
        .collection('rentals')
        .doc('older')
        .set(rentalData(createdAt: DateTime(2026, 7, 28)));
    await firestore
        .collection('rentals')
        .doc('newer')
        .set(rentalData(createdAt: DateTime(2026, 7, 29)));
    final source = operations_data.BookingRemoteDataSourceImpl(firestore);

    final farmer = await source
        .watchFarmerBookings('farmer-1')
        .firstWhere((items) => items.length == 2);
    expect(farmer.first.id, 'newer');
    final owner = await source
        .watchOwnerBookings('owner-1')
        .firstWhere((items) => items.length == 2);
    expect(owner.length, 2);

    await source.updateBookingStatus(
      bookingId: 'newer',
      ownerId: 'owner-1',
      status: operations_domain.BookingStatus.accepted,
    );
    expect(
      (await firestore.collection('rentals').doc('newer').get())
          .data()!['status'],
      'accepted',
    );
    await expectLater(
      source.updateBookingStatus(
        bookingId: 'newer',
        ownerId: 'owner-1',
        status: operations_domain.BookingStatus.active,
      ),
      throwsArgumentError,
    );
    await expectLater(
      source.updateBookingStatus(
        bookingId: 'missing',
        ownerId: 'owner-1',
        status: operations_domain.BookingStatus.accepted,
      ),
      throwsStateError,
    );
    await expectLater(
      source.updateBookingStatus(
        bookingId: 'older',
        ownerId: 'someone-else',
        status: operations_domain.BookingStatus.declined,
      ),
      throwsStateError,
    );
    await expectLater(
      source.updateBookingStatus(
        bookingId: 'newer',
        ownerId: 'owner-1',
        status: operations_domain.BookingStatus.declined,
      ),
      throwsStateError,
    );

    await source.deleteBooking(bookingId: 'older', farmerId: 'farmer-1');
    expect(
      (await firestore.collection('rentals').doc('older').get()).exists,
      isFalse,
    );
    await source.deleteBooking(bookingId: 'already-gone', farmerId: 'farmer-1');
    await expectLater(
      source.deleteBooking(bookingId: 'newer', farmerId: 'someone-else'),
      throwsStateError,
    );
    await expectLater(
      source.deleteBooking(bookingId: 'newer', farmerId: 'farmer-1'),
      throwsStateError,
    );
  });

  test(
    'owner data source manages profiles, listings, and rental reads',
    () async {
      final firestore = FakeFirebaseFirestore();
      final source = OwnerRemoteDataSourceImpl(firestore);
      const draft = ListingDraft(
        name: '  John Deere 5050D  ',
        category: 'Tractors',
        pricePerDay: 25000,
        pricePerMonth: 500000,
        location: '  Musanze  ',
        description: '  Reliable tractor with a maintained diesel engine.  ',
        imageUrl: '  https://example.com/tractor.png  ',
      );

      await source.ensureOwnerProfile(
        ownerId: 'owner-1',
        displayName: 'Patrick',
        email: 'patrick@example.com',
      );
      await source.ensureOwnerProfile(
        ownerId: 'owner-1',
        displayName: 'Patrick Updated',
      );
      final profile = await firestore.collection('users').doc('owner-1').get();
      expect(profile.data()!['role'], 'owner');
      expect(profile.data()!['displayName'], 'Patrick Updated');

      final listingId = await source.createListing(
        ownerId: 'owner-1',
        draft: draft,
      );
      await source.updateListing(
        listingId: listingId,
        draft: draft.copyWith(name: 'Updated Tractor'),
      );
      await source.setListingPaused(listingId: listingId, paused: true);
      await source.setListingPaused(listingId: listingId, paused: false);
      final listings = await source.getListings('owner-1');
      expect(listings.single.name, 'Updated Tractor');
      expect(listings.single.status, EquipmentStatus.available);

      await firestore
          .collection('rentals')
          .doc('rental-1')
          .set(rentalData(ownerId: 'owner-1'));
      final rentals = await source.getRentals('owner-1');
      expect(rentals.single.equipmentName, 'John Deere 5050D');
      expect(rentals.single.days, 3);
    },
  );

  test('auth data source persists profiles and syncs account roles', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService();
    await preferences.setRole(PreferencesService.roleOwner);
    final firestore = FakeFirebaseFirestore();
    final user = MockUser(
      uid: 'farmer-1',
      email: 'alice@example.com',
      displayName: 'Alice Farmer',
      isEmailVerified: false,
    );
    final auth = MockFirebaseAuth(mockUser: user, signedIn: false);
    final source = AuthRemoteDataSourceImpl(
      auth,
      GoogleSignIn.instance,
      firestore,
      preferences,
    );

    final signedUp = await source.signUpWithEmailAndPassword(
      email: 'alice@example.com',
      password: 'password123',
      displayName: 'Alice Farmer',
    );
    expect(signedUp.email, 'alice@example.com');
    final profile = await firestore.collection('users').doc(signedUp.id).get();
    expect(profile.data()!['role'], 'owner');
    expect(profile.data()!['verified'], false);

    await firestore.collection('users').doc(signedUp.id).update({
      'role': 'farmer',
    });
    final signedIn = await source.signInWithEmailAndPassword(
      email: 'alice@example.com',
      password: 'password123',
    );
    expect(signedIn.id, signedUp.id);
    expect(await preferences.getRole(), 'farmer');
    expect((await source.getCurrentUser())?.email, 'alice@example.com');
    expect(
      (await source.authStateChanges().firstWhere((user) => user != null))?.id,
      signedUp.id,
    );

    await source.sendPasswordResetEmail('alice@example.com');
    await source.sendEmailVerification();
    expect((await source.reloadCurrentUser())?.id, signedUp.id);
    expect((await source.completeGoogleSignUp('owner')).role, isNull);

    await auth.signOut();
    expect(await source.getCurrentUser(), isNull);
    expect(await source.reloadCurrentUser(), isNull);
    await expectLater(
      source.sendEmailVerification(),
      throwsA(isA<FirebaseAuthException>()),
    );
    await expectLater(
      source.completeGoogleSignUp('farmer'),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}

Map<String, dynamic> rentalEquipmentMap({
  String name = 'John Deere 5050D',
  String category = 'Tractors',
}) {
  return {
    'name': name,
    'ownerId': 'owner-1',
    'ownerName': 'Patrick',
    'description': 'A reliable machine for farm work.',
    'pricePerDay': 25000,
    'pricePerMonth': 500000,
    'category': category,
    'image': '',
    'location': 'Musanze',
    'rating': 4.8,
    'reviewCount': 12,
    'pricePerHour': 5000,
    'pricePerHectare': 18000,
    'specs': {'Power': '50 HP'},
    'bookingCount': 2,
    'createdAt': Timestamp.fromDate(DateTime(2026, 7, 29)),
    'updatedAt': Timestamp.fromDate(DateTime(2026, 7, 29)),
  };
}
