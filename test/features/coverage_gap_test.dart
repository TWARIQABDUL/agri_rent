import 'dart:async';

import 'package:agri_rent/core/error/app_exception.dart';
import 'package:agri_rent/core/services/preferences_service.dart';
import 'package:agri_rent/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agri_rent/features/auth/data/models/user_model.dart';
import 'package:agri_rent/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agri_rent/features/auth/domain/entities/google_auth_result.dart';
import 'package:agri_rent/features/auth/domain/entities/user.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agri_rent/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:agri_rent/features/booking/data/models/booking_model.dart'
    as checkout_data;
import 'package:agri_rent/features/booking/domain/entities/booking.dart'
    as checkout_domain;
import 'package:agri_rent/features/booking/presentation/bloc/booking_bloc.dart'
    as checkout_presentation;
import 'package:agri_rent/features/bookings/data/repositories/booking_repository_impl.dart'
    as operations_data;
import 'package:agri_rent/features/bookings/data/datasources/booking_remote_data_source.dart'
    as operations_remote;
import 'package:agri_rent/features/bookings/data/models/booking_model.dart'
    as operations_data_model;
import 'package:agri_rent/features/bookings/domain/usecases/manage_booking.dart';
import 'package:agri_rent/features/bookings/domain/usecases/watch_bookings.dart';
import 'package:agri_rent/features/bookings/domain/entities/booking.dart'
    as operations_domain;
import 'package:agri_rent/features/bookings/presentation/bloc/booking_bloc.dart'
    as operations_presentation;
import 'package:agri_rent/features/equipment/data/models/equipment_model.dart';
import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/equipment/domain/repositories/equipment_repository.dart';
import 'package:agri_rent/features/equipment/domain/usecases/get_equipment.dart';
import 'package:agri_rent/features/equipment/presentation/bloc/equipment_bloc.dart';
import 'package:agri_rent/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:agri_rent/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:agri_rent/features/main_shell/farmer_navigation_cubit.dart';
import 'package:agri_rent/features/main_shell/main_shell.dart';
import 'package:agri_rent/features/owner/data/datasources/owner_remote_data_source.dart';
import 'package:agri_rent/features/owner/data/models/owner_rental_model.dart';
import 'package:agri_rent/features/owner/data/repositories/owner_repository_impl.dart';
import 'package:agri_rent/features/owner/domain/entities/listing_draft.dart';
import 'package:agri_rent/features/owner/domain/entities/owner_rental.dart';
import 'package:agri_rent/features/owner/presentation/widgets/owner_bottom_nav.dart';
import 'package:agri_rent/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:agri_rent/injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/auth_test_helpers.dart';
import '../support/feature_test_helpers.dart';
import 'bookings/booking_test_helpers.dart';

const modelEquipment = Equipment(
  id: 'equipment-1',
  name: 'John Deere 5050D',
  ownerId: 'owner-1',
  description: 'A reliable tractor for farm work.',
  pricePerDay: 25000,
  pricePerMonth: 500000,
  status: EquipmentStatus.paused,
  category: 'Tractors',
  image: '',
  location: 'Musanze',
  rating: 4.8,
  ownerName: 'Patrick',
  reviewCount: 12,
  pricePerHour: 5000,
  pricePerHectare: 18000,
  specs: {'Power': '50 HP'},
  bookingCount: 4,
);

class DelegatingAuthRemoteDataSource implements AuthRemoteDataSource {
  static const user = UserModel(
    id: 'user-1',
    email: 'alice@example.com',
    displayName: 'Alice',
  );

  final controller = StreamController<UserModel?>.broadcast();
  var calls = 0;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    calls++;
    return user;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    calls++;
    return user;
  }

  @override
  Future<GoogleAuthResult> signInWithGoogle({String? presetRole}) async {
    calls++;
    return const GoogleAuthResult(
      user: user,
      isNewUser: false,
      profilePersisted: true,
    );
  }

  @override
  Future<UserModel> completeGoogleSignUp(String role) async {
    calls++;
    return user;
  }

  @override
  Future<void> signOut() async {
    calls++;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    calls++;
    return user;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    calls++;
    return controller.stream;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    calls++;
  }

  @override
  Future<void> sendEmailVerification() async {
    calls++;
  }

  @override
  Future<UserModel?> reloadCurrentUser() async {
    calls++;
    return user;
  }
}

class ErrorOwnerRemoteDataSource implements OwnerRemoteDataSource {
  Object error;

  ErrorOwnerRemoteDataSource(this.error);

  Never _throw() => throw error;

  @override
  Future<List<EquipmentModel>> getListings(String ownerId) async => _throw();

  @override
  Future<String> createListing({
    required String ownerId,
    required ListingDraft draft,
  }) async => _throw();

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  }) async => _throw();

  @override
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  }) async => _throw();

  @override
  Future<List<OwnerRentalModel>> getRentals(String ownerId) async => _throw();

  @override
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  }) async => _throw();
}

class SuccessfulOwnerRemoteDataSource implements OwnerRemoteDataSource {
  var profileEnsured = false;
  var listingUpdated = false;
  var pauseChanged = false;

  @override
  Future<List<EquipmentModel>> getListings(String ownerId) async => [
    EquipmentModel.fromEntity(modelEquipment),
  ];

  @override
  Future<String> createListing({
    required String ownerId,
    required ListingDraft draft,
  }) async => 'listing-1';

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  }) async {
    listingUpdated = true;
  }

  @override
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  }) async {
    pauseChanged = true;
  }

  @override
  Future<List<OwnerRentalModel>> getRentals(String ownerId) async => [
    OwnerRentalModel(
      id: 'rental-1',
      equipmentId: 'listing-1',
      equipmentName: 'Updated Tractor',
      renterName: 'Alice',
      startDate: DateTime(2026, 7, 30),
      endDate: DateTime(2026, 7, 31),
      amount: 52500,
      status: RentalStatus.pending,
      updatedAt: DateTime(2026, 7, 29),
    ),
  ];

  @override
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  }) async {
    profileEnsured = true;
  }
}

class EmptyEquipmentRepository implements EquipmentRepository {
  @override
  Future<List<Equipment>> getEquipment({String? category}) async => const [];
}

class SuccessfulBookingOperationsRemote
    implements operations_remote.BookingRemoteDataSource {
  var updated = false;
  var deleted = false;

  operations_data_model.BookingModel get booking =>
      operations_data_model.BookingModel.fromMap('rental-1', {
        'renterId': 'farmer-1',
        'ownerId': 'owner-1',
        'equipmentId': 'equipment-1',
        'equipmentName': 'Updated Tractor',
        'startDate': DateTime(2026, 7, 30),
        'endDate': DateTime(2026, 7, 31),
        'duration': 2,
        'rate': 25000,
        'totalAmount': 52500,
        'status': 'pending',
        'createdAt': DateTime(2026, 7, 29),
      });

  @override
  Stream<List<operations_data_model.BookingModel>> watchFarmerBookings(
    String farmerId,
  ) => Stream.value([booking]);

  @override
  Stream<List<operations_data_model.BookingModel>> watchOwnerBookings(
    String ownerId,
  ) => Stream.value([booking]);

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String ownerId,
    required operations_domain.BookingStatus status,
  }) async {
    updated = true;
  }

  @override
  Future<void> deleteBooking({
    required String bookingId,
    required String farmerId,
  }) async {
    deleted = true;
  }
}

void main() {
  testWidgets('forgot password validates, submits, and returns to sign in', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(700, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeAuthRepository();
    final bloc = makeAuthBloc(repository);
    addTearDown(() async {
      await bloc.close();
      await repository.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  ),
                  child: const Text('Open reset'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open reset'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot your password?'), findsOneWidget);

    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'not-an-email');
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'alice@example.com');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repository.submittedEmail, 'alice@example.com');
    expect(find.text('Open reset'), findsOneWidget);
    expect(find.text('Reset link sent to alice@example.com'), findsOneWidget);
  });

  testWidgets('forgot password shows backend errors and supports back', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(700, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeAuthRepository()
      ..error = StateError('network offline');
    final bloc = makeAuthBloc(repository);
    addTearDown(() async {
      await bloc.close();
      await repository.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: const MaterialApp(
          home: ForgotPasswordPage(initialEmail: 'alice@example.com'),
        ),
      ),
    );
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Back to Sign In'));
    await tester.pump();
  });

  test('auth repository delegates its complete contract', () async {
    final remote = DelegatingAuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remote);
    addTearDown(remote.controller.close);

    expect(
      (await repository.signInWithEmailAndPassword(
        email: 'alice@example.com',
        password: 'password',
      )).id,
      'user-1',
    );
    await repository.signUpWithEmailAndPassword(
      email: 'alice@example.com',
      password: 'password',
      displayName: 'Alice',
    );
    expect((await repository.signInWithGoogle()).profilePersisted, isTrue);
    await repository.completeGoogleSignUp('farmer');
    await repository.getCurrentUser();
    repository.authStateChanges();
    await repository.sendPasswordResetEmail('alice@example.com');
    await repository.sendEmailVerification();
    await repository.reloadCurrentUser();
    await repository.signOut();
    expect(remote.calls, 10);
  });

  test(
    'domain values and checkout model cover every rental-rate mapping',
    () async {
      expect(modelEquipment.isPaused, isTrue);
      expect(modelEquipment.props, contains('equipment-1'));
      final equipmentModel = EquipmentModel.fromEntity(modelEquipment);
      expect(equipmentModel.toJson()['pricePerHour'], 5000);

      checkout_domain.Booking booking(String rateType) =>
          checkout_domain.Booking(
            id: 'booking-$rateType',
            equipmentId: modelEquipment.id,
            equipmentName: modelEquipment.name,
            equipmentCategory: modelEquipment.category,
            equipmentImage: '',
            farmerId: 'farmer-1',
            farmerName: 'Alice',
            ownerId: modelEquipment.ownerId,
            ownerName: modelEquipment.ownerName,
            rateType: rateType,
            rate: 5000,
            duration: 3,
            startDate: DateTime(2026, 7, 30),
            subtotal: 15000,
            serviceFee: 750,
            total: 15750,
            status: checkout_domain.BookingStatus.pending,
            createdAt: DateTime(2026, 7, 29),
          );

      final hourly = checkout_data.BookingModel.fromEntity(
        booking(checkout_domain.RateType.hour),
        id: 'hourly',
        walletTransactionId: 'wallet-hour',
      );
      final hectares = checkout_data.BookingModel.fromEntity(
        booking(checkout_domain.RateType.hectare),
      );
      final daily = checkout_data.BookingModel.fromEntity(
        booking(checkout_domain.RateType.day),
      );
      expect(
        (hourly.toJson()['endDate'] as Timestamp).toDate(),
        DateTime(2026, 7, 30, 3),
      );
      expect(
        (hectares.toJson()['endDate'] as Timestamp).toDate(),
        DateTime(2026, 7, 31),
      );
      expect(
        (daily.toJson()['endDate'] as Timestamp).toDate(),
        DateTime(2026, 8, 2),
      );
      expect(hourly.props, contains('wallet-hour'));

      final firestore = FakeFirebaseFirestore();
      final mappedData = daily.toJson()
        ..['createdAt'] = Timestamp.fromDate(DateTime(2026, 7, 29))
        ..['updatedAt'] = Timestamp.fromDate(DateTime(2026, 7, 29));
      await firestore.collection('rentals').doc('mapped').set(mappedData);
      final snapshot = await firestore
          .collection('rentals')
          .doc('mapped')
          .get();
      final mapped = checkout_data.BookingModel.fromFirestore(snapshot);
      expect(mapped.id, 'mapped');
      expect(mapped.paymentStatus, checkout_domain.BookingPaymentStatus.paid);

      final ownerRental = OwnerRental(
        id: 'rental-1',
        equipmentId: modelEquipment.id,
        equipmentName: modelEquipment.name,
        renterName: 'Alice',
        startDate: DateTime(2026, 7, 30),
        endDate: DateTime(2026, 7, 31),
        amount: 52500,
        status: RentalStatus.completed,
        paidOut: true,
        updatedAt: DateTime(2026, 8, 1),
      );
      expect(ownerRental.days, 2);
      expect(ownerRental.isCompleted, isTrue);
      expect(ownerRental.isPending, isFalse);
      expect(ownerRental.isActive, isFalse);
      expect(ownerRental.props, contains(true));
    },
  );

  test('auth event and state equality includes payloads', () {
    const user = User(id: 'user-1', email: 'alice@example.com');
    expect(
      const SignInWithEmailRequested(
        email: 'alice@example.com',
        password: 'secret',
      ).props,
      ['alice@example.com', 'secret'],
    );
    expect(
      const SignUpWithEmailRequested(
        email: 'alice@example.com',
        password: 'secret',
        displayName: 'Alice',
      ).props,
      ['alice@example.com', 'secret', 'Alice'],
    );
    expect(const SignInWithGoogleRequested(presetRole: 'farmer').props, [
      'farmer',
    ]);
    expect(const CompleteGoogleSignUpRequested('owner').props, ['owner']);
    expect(const PasswordResetRequested('alice@example.com').props, [
      'alice@example.com',
    ]);
    expect(const AuthStateChanged(user).props, [user]);
    expect(const Authenticated(user).props, [user]);
    expect(const AuthError('error').props, ['error']);
    expect(const PasswordResetEmailSent('alice@example.com').props, [
      'alice@example.com',
    ]);
    expect(const NeedsRoleForGoogleSignUp(user).props, [user]);
    expect(const VerificationEmailSent().props, isEmpty);
    expect(CheckAuthStatusEvent().props, isEmpty);
    expect(SignOutRequested().props, isEmpty);
  });

  test('owner repository maps Firebase and unexpected errors', () async {
    final draft = const ListingDraft(
      name: 'Tractor',
      category: 'Tractors',
      pricePerDay: 25000,
      location: 'Musanze',
      description: 'A reliable tractor for ploughing.',
    );

    Future<AppException> errorFor(Object error) async {
      final repository = OwnerRepositoryImpl(ErrorOwnerRemoteDataSource(error));
      try {
        await repository.publishListing(ownerId: 'owner-1', draft: draft);
        throw StateError('Expected an error');
      } on AppException catch (exception) {
        return exception;
      }
    }

    FirebaseException firebase(String code, [String? message]) =>
        FirebaseException(
          plugin: 'cloud_firestore',
          code: code,
          message: message,
        );

    expect(
      (await errorFor(firebase('permission-denied'))).message,
      contains('not verified'),
    );
    expect(
      (await errorFor(firebase('not-found'))).message,
      contains('no longer exists'),
    );
    expect(
      (await errorFor(firebase('unavailable'))).message,
      contains('No connection'),
    );
    expect(
      (await errorFor(firebase('deadline-exceeded'))).message,
      contains('No connection'),
    );
    expect(
      (await errorFor(firebase('resource-exhausted'))).message,
      contains('busy'),
    );
    expect(
      (await errorFor(firebase('unknown', 'Backend detail'))).message,
      'Backend detail',
    );
    expect(
      (await errorFor(StateError('unexpected'))).message,
      contains('Something went wrong'),
    );
    const original = AppException('Already useful');
    expect((await errorFor(original)).message, original.message);
  });

  test(
    'owner and booking repositories cover successful storage operations',
    () async {
      final ownerRemote = SuccessfulOwnerRemoteDataSource();
      final ownerRepository = OwnerRepositoryImpl(ownerRemote);
      const draft = ListingDraft(
        name: 'John Deere 5050D',
        category: 'Tractors',
        pricePerDay: 25000,
        pricePerMonth: 500000,
        location: 'Musanze',
        description: 'A dependable tractor for ploughing and planting.',
      );
      await ownerRepository.ensureOwnerProfile(
        ownerId: 'owner-1',
        displayName: 'Patrick',
        email: 'patrick@example.com',
      );
      final listingId = await ownerRepository.publishListing(
        ownerId: 'owner-1',
        draft: draft,
      );
      expect(ownerRemote.profileEnsured, isTrue);
      expect(await ownerRepository.getListings('owner-1'), hasLength(1));
      await ownerRepository.updateListing(
        listingId: listingId,
        draft: draft.copyWith(name: 'Updated Tractor'),
      );
      await ownerRepository.setListingPaused(
        listingId: listingId,
        paused: true,
      );
      expect(ownerRemote.listingUpdated, isTrue);
      expect(ownerRemote.pauseChanged, isTrue);
      final summary = await ownerRepository.getSummary('owner-1');
      expect(summary.pendingRequestCount, 1);

      final operationsSource = SuccessfulBookingOperationsRemote();
      final operationsRepository = operations_data.BookingRepositoryImpl(
        operationsSource,
      );
      final watched = await operationsRepository
          .watchFarmerBookings('farmer-1')
          .firstWhere((items) => items.isNotEmpty);
      expect(watched.single.id, 'rental-1');
      await operationsRepository.updateBookingStatus(
        bookingId: 'rental-1',
        ownerId: 'owner-1',
        status: operations_domain.BookingStatus.accepted,
      );
      await operationsRepository.deleteBooking(
        bookingId: 'rental-1',
        farmerId: 'farmer-1',
      );
      expect(operationsSource.updated, isTrue);
      expect(operationsSource.deleted, isTrue);
    },
  );

  test('remaining value objects expose validation and state payloads', () {
    const user = User(
      id: 'farmer-1',
      email: 'alice@example.com',
      displayName: 'Alice',
      role: 'farmer',
      emailVerified: true,
    );
    expect(user.props, containsAll(['farmer-1', 'alice@example.com', true]));

    const blank = ListingDraft();
    expect(blank.hasIdentity, isFalse);
    expect(blank.hasTerms, isFalse);
    expect(blank.hasDetails, isFalse);
    expect(blank.isPublishable, isFalse);
    final draft = blank.copyWith(
      name: 'Tractor',
      category: 'Tractors',
      pricePerDay: 25000,
      location: 'Musanze',
      description: 'A dependable tractor for ploughing and planting.',
    );
    expect(draft.isPublishable, isTrue);
    expect(draft.props, contains('Musanze'));
    expect(
      ListingDraft.fromEquipment(modelEquipment).name,
      modelEquipment.name,
    );

    expect(checkout_presentation.BookingInitial().props, isEmpty);
    expect(checkout_presentation.BookingSubmitting().props, isEmpty);
    expect(
      const checkout_presentation.BookingInsufficientBalance(
        amountDue: 52500,
        availableBalance: 5000,
      ).props,
      [52500, 5000],
    );
    expect(const checkout_presentation.BookingFailure('failed').props, [
      'failed',
    ]);

    expect(
      const operations_presentation.WatchFarmerBookingsRequested(
        'farmer-1',
      ).props,
      ['farmer-1'],
    );
    expect(
      const operations_presentation.WatchOwnerBookingsRequested(
        'owner-1',
      ).props,
      ['owner-1'],
    );
    expect(
      const operations_presentation.BookingStatusUpdateRequested(
        bookingId: 'rental-1',
        ownerId: 'owner-1',
        status: operations_domain.BookingStatus.accepted,
      ).props,
      ['rental-1', 'owner-1', operations_domain.BookingStatus.accepted],
    );
    expect(
      const operations_presentation.BookingDeleteRequested(
        bookingId: 'rental-1',
        farmerId: 'farmer-1',
      ).props,
      ['rental-1', 'farmer-1'],
    );
    expect(
      const operations_presentation.BookingLoaded([], notice: 'done').props,
      [const <operations_domain.Booking>[], null, 'done', null],
    );
    expect(const operations_presentation.BookingFailure('offline').props, [
      'offline',
    ]);
  });

  testWidgets('main shell protects farmer pages while auth is loading', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final bloc = makeAuthBloc(repository);
    addTearDown(() async {
      await bloc.close();
      await repository.close();
    });
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: const MaterialApp(home: MainShell()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('main shell connects farmer navigation to real feature pages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'pref_role': 'farmer'});
    await sl.reset();
    sl.registerSingleton<PreferencesService>(PreferencesService());
    addTearDown(sl.reset);

    final authRepository = FakeAuthRepository()
      ..currentUser = const User(
        id: 'farmer-1',
        email: 'alice@example.com',
        displayName: 'Alice Farmer',
        role: 'farmer',
        emailVerified: true,
      );
    final authBloc = makeAuthBloc(authRepository);
    await authenticate(authBloc);
    final equipmentBloc = EquipmentBloc(
      GetEquipment(EmptyEquipmentRepository()),
    );
    final bookingRepository = FakeBookingRepository();
    final bookingBloc = operations_presentation.BookingBloc(
      WatchFarmerBookings(bookingRepository),
      WatchOwnerBookings(bookingRepository),
      UpdateBookingStatus(bookingRepository),
      DeleteBooking(bookingRepository),
    );
    final favoritesRepository = FakeFavoritesRepository();
    final favoritesCubit = FavoritesCubit(favoritesRepository);
    final walletRepository = FakeWalletRepository();
    final walletCubit = WalletCubit(walletRepository);
    final navigation = FarmerNavigationCubit();
    addTearDown(() async {
      await authBloc.close();
      await authRepository.close();
      await equipmentBloc.close();
      await bookingBloc.close();
      await bookingRepository.close();
      await favoritesCubit.close();
      await favoritesRepository.close();
      await walletCubit.close();
      await walletRepository.close();
      await navigation.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<EquipmentBloc>.value(value: equipmentBloc),
          BlocProvider<operations_presentation.BookingBloc>.value(
            value: bookingBloc,
          ),
          BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
          BlocProvider<WalletCubit>.value(value: walletCubit),
          BlocProvider<FarmerNavigationCubit>.value(value: navigation),
        ],
        child: const MaterialApp(home: MainShell()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Alice Farmer'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.account_balance_wallet));
    await tester.pump();
    expect(find.text('My Wallet'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();
    expect(find.text('Favorites'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.book_online));
    await tester.pump();
    expect(find.text('My Bookings'), findsOneWidget);
  });

  testWidgets('farmer and owner bottom navigation expose every destination', (
    tester,
  ) async {
    var farmerIndex = -1;
    var ownerIndex = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CustomBottomNav(
                currentIndex: 0,
                onTap: (index) => farmerIndex = index,
              ),
              OwnerBottomNav(
                currentIndex: 1,
                pendingRequestCount: 3,
                onTap: (index) => ownerIndex = index,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.favorite_border));
    expect(farmerIndex, 3);
    await tester.tap(find.byIcon(Icons.inbox_outlined));
    expect(ownerIndex, 2);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
