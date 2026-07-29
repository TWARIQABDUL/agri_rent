import 'package:agri_rent/features/bookings/domain/entities/booking.dart';
import 'package:agri_rent/features/bookings/domain/usecases/manage_booking.dart';
import 'package:agri_rent/features/bookings/domain/usecases/watch_bookings.dart';
import 'package:agri_rent/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:agri_rent/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:agri_rent/features/bookings/presentation/pages/rental_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'booking_test_helpers.dart';

void main() {
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

  Widget app(Widget page) {
    return BlocProvider<BookingBloc>.value(
      value: bloc,
      child: MaterialApp(home: page),
    );
  }

  Future<void> emitFarmerBookings(
    WidgetTester tester,
    List<Booking> bookings,
  ) async {
    await tester.runAsync(() async {
      final loaded = bloc.stream.firstWhere((state) => state is BookingLoaded);
      repository.farmerController.add(bookings);
      await loaded;
    });
    await tester.pump();
  }

  Future<void> emitOwnerBookings(
    WidgetTester tester,
    List<Booking> bookings,
  ) async {
    await tester.runAsync(() async {
      final loaded = bloc.stream.firstWhere((state) => state is BookingLoaded);
      repository.ownerController.add(bookings);
      await loaded;
    });
    await tester.pump();
  }

  testWidgets('My Bookings renders groups, cards, and rental detail', (
    tester,
  ) async {
    final pending = makeBooking();
    final active = makeBooking(
      id: 'b-102',
      status: BookingStatus.active,
      equipmentName: 'Irrigation Pump X2',
      category: 'Pump',
    );
    final history = makeBooking(
      id: 'b-103',
      status: BookingStatus.completed,
      equipmentName: 'Knapsack Sprayer',
      category: 'Sprayer',
    );
    await tester.pumpWidget(app(const MyBookingsPage(farmerId: 'farmer-1')));
    await tester.pump();
    await tester.pump();
    expect(repository.farmerController.hasListener, isTrue);
    await emitFarmerBookings(tester, [pending, active, history]);
    expect(repository.watchedFarmerId, 'farmer-1');

    expect(find.byKey(const Key('my-bookings-page')), findsOneWidget);
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.byKey(const Key('farmer-booking-card-b-101')), findsOneWidget);
    expect(find.text('RWF 52,500'), findsOneWidget);

    await tester.tap(find.byKey(const Key('farmer-booking-card-b-101')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rental-detail-page')), findsOneWidget);
    expect(find.text('Status Tracking'), findsOneWidget);
    expect(find.text('Booking Info'), findsOneWidget);
    expect(find.byKey(const Key('cancel-booking-button')), findsOneWidget);
  });

  testWidgets('farmer confirms deletion of a pending booking', (tester) async {
    final booking = makeBooking();
    await tester.pumpWidget(app(const MyBookingsPage(farmerId: 'farmer-1')));
    await tester.pump();
    await tester.pump();
    await emitFarmerBookings(tester, [booking]);

    await tester.tap(find.byKey(const Key('farmer-booking-card-b-101')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancel-booking-button')));
    await tester.pumpAndSettle();

    expect(find.text('Cancel this request?'), findsOneWidget);
    final cancellationNotice = bloc.stream.firstWhere(
      (state) =>
          state is BookingLoaded && state.notice?.contains('cancelled') == true,
    );
    await tester.tap(find.text('Cancel Request').last);
    await tester.pump();
    await tester.runAsync(() => cancellationNotice);
    await tester.pumpAndSettle();

    expect(repository.deletedBookingId, booking.id);
    expect(find.byKey(const Key('rental-detail-page')), findsNothing);
  });

  testWidgets('My Bookings displays an actionable empty state', (tester) async {
    await tester.pumpWidget(app(const MyBookingsPage(farmerId: 'farmer-1')));
    await tester.pump();
    await tester.pump();
    await emitFarmerBookings(tester, const []);

    expect(find.text('No pending requests'), findsOneWidget);
    expect(
      find.text(
        'New rental requests will appear here while owners review them.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Rental Requests renders request and owner detail', (
    tester,
  ) async {
    final booking = makeBooking();
    await tester.pumpWidget(app(const RentalRequestsPage(ownerId: 'owner-1')));
    await tester.pump();
    await tester.pump();
    await emitOwnerBookings(tester, [booking]);
    expect(repository.watchedOwnerId, 'owner-1');

    expect(find.byKey(const Key('rental-requests-page')), findsOneWidget);
    expect(find.text('Rental Requests'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
    expect(find.byKey(const Key('owner-request-card-b-101')), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    await tester.tap(find.byKey(const Key('owner-request-card-b-101')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('request-detail-page')), findsOneWidget);
    expect(find.text("Renter's note"), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.text('Your payout'), findsOneWidget);
    expect(find.byKey(const Key('accept-request-button')), findsOneWidget);
    expect(find.byKey(const Key('decline-request-button')), findsOneWidget);
  });

  testWidgets('owner accepts a request from the detail screen', (tester) async {
    final booking = makeBooking();
    await tester.pumpWidget(app(const RentalRequestsPage(ownerId: 'owner-1')));
    await tester.pump();
    await tester.pump();
    await emitOwnerBookings(tester, [booking]);

    await tester.tap(find.byKey(const Key('owner-request-card-b-101')));
    await tester.pumpAndSettle();
    final acceptedNotice = bloc.stream.firstWhere(
      (state) =>
          state is BookingLoaded && state.notice?.contains('accepted') == true,
    );
    await tester.tap(find.byKey(const Key('accept-request-button')));
    await tester.pump();
    await tester.runAsync(() => acceptedNotice);
    await tester.pumpAndSettle();

    expect(repository.updatedBookingId, booking.id);
    expect(repository.updateOwnerId, 'owner-1');
    expect(repository.updatedStatus, BookingStatus.accepted);
    expect(find.byKey(const Key('request-detail-page')), findsNothing);
  });

  testWidgets('owner declines a request from the detail screen', (
    tester,
  ) async {
    final booking = makeBooking();
    await tester.pumpWidget(app(const RentalRequestsPage(ownerId: 'owner-1')));
    await tester.pump();
    await tester.pump();
    await emitOwnerBookings(tester, [booking]);

    await tester.tap(find.byKey(const Key('owner-request-card-b-101')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('decline-request-button')));
    await tester.pumpAndSettle();

    expect(repository.updatedBookingId, booking.id);
    expect(repository.updatedStatus, BookingStatus.declined);
  });
}
