import 'package:agri_rent/features/bookings/data/models/booking_model.dart';
import 'package:agri_rent/features/bookings/domain/entities/booking.dart';
import 'package:agri_rent/features/bookings/domain/usecases/manage_booking.dart';
import 'package:agri_rent/features/bookings/domain/usecases/watch_bookings.dart';
import 'package:agri_rent/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'booking_test_helpers.dart';

void main() {
  group('BookingStatus', () {
    test('parses canonical and compatible backend values', () {
      expect(BookingStatus.fromValue('pending'), BookingStatus.pending);
      expect(BookingStatus.fromValue('approved'), BookingStatus.accepted);
      expect(BookingStatus.fromValue('in_use'), BookingStatus.active);
      expect(BookingStatus.fromValue('complete'), BookingStatus.completed);
      expect(BookingStatus.fromValue('rejected'), BookingStatus.declined);
      expect(BookingStatus.fromValue('canceled'), BookingStatus.cancelled);
      expect(BookingStatus.fromValue(null), BookingStatus.pending);
    });

    test('groups farmer and owner booking states correctly', () {
      expect(
        makeBooking().belongsToFarmerGroup(FarmerBookingGroup.pending),
        isTrue,
      );
      expect(
        makeBooking(
          status: BookingStatus.accepted,
        ).belongsToFarmerGroup(FarmerBookingGroup.active),
        isTrue,
      );
      expect(
        makeBooking(
          status: BookingStatus.active,
        ).belongsToFarmerGroup(FarmerBookingGroup.active),
        isTrue,
      );
      expect(
        makeBooking(
          status: BookingStatus.completed,
        ).belongsToFarmerGroup(FarmerBookingGroup.history),
        isTrue,
      );
      expect(
        makeBooking(
          status: BookingStatus.declined,
        ).belongsToOwnerGroup(OwnerBookingGroup.declined),
        isTrue,
      );
      expect(
        makeBooking(
          status: BookingStatus.completed,
        ).belongsToOwnerGroup(OwnerBookingGroup.accepted),
        isTrue,
      );
    });
  });

  group('BookingModel', () {
    test('maps the rentals Firestore schema and serializes it', () {
      final start = DateTime(2026, 7, 10);
      final created = DateTime(2026, 7, 1);
      final model = BookingModel.fromMap('booking-1', {
        'renterId': 'farmer-1',
        'renterName': 'Jean Bosco',
        'ownerId': 'owner-1',
        'ownerName': 'Patrick',
        'equipmentId': 'equipment-1',
        'equipmentName': 'John Deere',
        'equipmentCategory': 'Tractor',
        'equipmentImage': 'https://example.com/tractor.png',
        'startDate': Timestamp.fromDate(start),
        'endDate': Timestamp.fromDate(DateTime(2026, 7, 12)),
        'rateType': 'day',
        'duration': 3,
        'rate': 25000,
        'subtotal': 75000,
        'serviceFee': 3750,
        'totalAmount': 78750,
        'status': 'accepted',
        'createdAt': Timestamp.fromDate(created),
      });

      expect(model.id, 'booking-1');
      expect(model.startDate, start);
      expect(model.durationDays, 3);
      expect(model.status, BookingStatus.accepted);
      expect(model.totalAmount, 78750);

      final encoded = model.toFirestore();
      expect(encoded['status'], 'accepted');
      expect(encoded['renterId'], 'farmer-1');
      expect(encoded['duration'], 3);
      expect(encoded['rate'], 25000);
      expect((encoded['startDate'] as Timestamp).toDate(), start);
    });

    test('supports legacy aliases and calculates missing totals', () {
      final model = BookingModel.fromMap('legacy-1', {
        'renterId': 'farmer-2',
        'renterName': 'Alice',
        'ownerId': 'owner-2',
        'name': 'Irrigation Pump',
        'category': 'Pump',
        'imageUrl': 'image',
        'startDate': '2026-07-10T00:00:00.000',
        'durationDays': 2,
        'pricePerDay': '8000',
        'status': 'confirmed',
      });

      expect(model.farmerId, 'farmer-2');
      expect(model.equipmentName, 'Irrigation Pump');
      expect(model.endDate, DateTime(2026, 7, 12));
      expect(model.subtotal, 16000);
      expect(model.serviceFee, 800);
      expect(model.totalAmount, 16800);
      expect(model.status, BookingStatus.accepted);
    });

    test('uses safe defaults for incomplete documents', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final model = BookingModel.fromMap('empty', const {});
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(model.farmerName, 'Farmer');
      expect(model.ownerName, 'Equipment owner');
      expect(model.equipmentName, 'Farm equipment');
      expect(model.durationDays, 1);
      expect(model.createdAt.isAfter(before), isTrue);
      expect(model.createdAt.isBefore(after), isTrue);
    });
  });

  group('Booking use cases and BLoC', () {
    late FakeBookingRepository repository;
    late BookingBloc bloc;

    setUp(() {
      repository = FakeBookingRepository();
      bloc = BookingBloc(
        WatchFarmerBookings(repository),
        WatchOwnerBookings(repository),
        UpdateBookingStatus(repository),
        DeleteBooking(repository),
      );
    });

    tearDown(() async {
      await bloc.close();
      await repository.close();
    });

    test('starts in BookingInitial', () {
      expect(bloc.state, isA<BookingInitial>());
    });

    test('rejects empty farmer id without opening a stream', () async {
      final expectation = expectLater(
        bloc.stream,
        emits(
          isA<BookingFailure>().having(
            (state) => state.message,
            'message',
            contains('Sign in'),
          ),
        ),
      );
      bloc.add(const WatchFarmerBookingsRequested(''));
      await expectation;
    });

    test('streams farmer bookings in real time', () async {
      final booking = makeBooking();
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BookingLoading>(),
          isA<BookingLoaded>().having((state) => state.bookings, 'bookings', [
            booking,
          ]),
        ]),
      );

      bloc.add(const WatchFarmerBookingsRequested('farmer-1'));
      await Future<void>.delayed(Duration.zero);
      repository.farmerController.add([booking]);

      await expectation;
      expect(repository.watchedFarmerId, 'farmer-1');
    });

    test('streams owner bookings in real time', () async {
      final booking = makeBooking();
      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<BookingLoading>(), isA<BookingLoaded>()]),
      );

      bloc.add(const WatchOwnerBookingsRequested('owner-1'));
      await Future<void>.delayed(Duration.zero);
      repository.ownerController.add([booking]);

      await expectation;
      expect(repository.watchedOwnerId, 'owner-1');
    });

    test('accepts a pending request and exposes a success notice', () async {
      final booking = makeBooking();
      bloc.add(const WatchOwnerBookingsRequested('owner-1'));
      await Future<void>.delayed(Duration.zero);
      repository.ownerController.add([booking]);
      await bloc.stream.firstWhere((state) => state is BookingLoaded);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BookingLoaded>().having(
            (state) => state.actionBookingId,
            'action id',
            booking.id,
          ),
          isA<BookingLoaded>().having(
            (state) => state.notice,
            'notice',
            contains('accepted'),
          ),
        ]),
      );
      bloc.add(
        BookingStatusUpdateRequested(
          bookingId: booking.id,
          ownerId: booking.ownerId,
          status: BookingStatus.accepted,
        ),
      );

      await expectation;
      expect(repository.updatedBookingId, booking.id);
      expect(repository.updatedStatus, BookingStatus.accepted);
    });

    test('reports update errors without losing loaded bookings', () async {
      final booking = makeBooking();
      repository.updateError = StateError('permission denied');
      bloc.add(const WatchOwnerBookingsRequested('owner-1'));
      await Future<void>.delayed(Duration.zero);
      repository.ownerController.add([booking]);
      await bloc.stream.firstWhere((state) => state is BookingLoaded);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BookingLoaded>(),
          isA<BookingLoaded>()
              .having(
                (state) => state.errorMessage,
                'error',
                contains('permission denied'),
              )
              .having((state) => state.bookings, 'bookings', [booking]),
        ]),
      );
      bloc.add(
        BookingStatusUpdateRequested(
          bookingId: booking.id,
          ownerId: booking.ownerId,
          status: BookingStatus.declined,
        ),
      );
      await expectation;
    });

    test('deletes a farmer pending request', () async {
      final booking = makeBooking();
      bloc.add(const WatchFarmerBookingsRequested('farmer-1'));
      await Future<void>.delayed(Duration.zero);
      repository.farmerController.add([booking]);
      await bloc.stream.firstWhere((state) => state is BookingLoaded);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BookingLoaded>(),
          isA<BookingLoaded>().having(
            (state) => state.notice,
            'notice',
            contains('cancelled'),
          ),
        ]),
      );
      bloc.add(
        BookingDeleteRequested(
          bookingId: booking.id,
          farmerId: booking.farmerId,
        ),
      );

      await expectation;
      expect(repository.deletedBookingId, booking.id);
      expect(repository.deleteFarmerId, booking.farmerId);
    });
  });
}
