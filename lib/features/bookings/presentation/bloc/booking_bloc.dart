import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/booking.dart';
import '../../domain/usecases/manage_booking.dart';
import '../../domain/usecases/watch_bookings.dart';

part 'booking_event.dart';
part 'booking_state.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final WatchFarmerBookings watchFarmerBookings;
  final WatchOwnerBookings watchOwnerBookings;
  final UpdateBookingStatus updateBookingStatus;
  final DeleteBooking deleteBooking;
  StreamSubscription<List<Booking>>? _bookingSubscription;

  BookingBloc(
    this.watchFarmerBookings,
    this.watchOwnerBookings,
    this.updateBookingStatus,
    this.deleteBooking,
  ) : super(BookingInitial()) {
    on<WatchFarmerBookingsRequested>(_watchFarmer);
    on<WatchOwnerBookingsRequested>(_watchOwner);
    on<BookingStatusUpdateRequested>(_updateStatus);
    on<BookingDeleteRequested>(_delete);
    on<_BookingsChanged>((event, emit) => emit(BookingLoaded(event.bookings)));
    on<_BookingWatchFailed>(
      (event, emit) => emit(BookingFailure(_message(event.error))),
    );
  }

  void _watchFarmer(
    WatchFarmerBookingsRequested event,
    Emitter<BookingState> emit,
  ) {
    if (event.farmerId.isEmpty) {
      _cancelBookingSubscription();
      emit(const BookingFailure('Sign in to view your bookings.'));
      return;
    }
    emit(BookingLoading());
    _cancelBookingSubscription();
    _bookingSubscription = watchFarmerBookings(event.farmerId).listen(
      (bookings) => add(_BookingsChanged(bookings)),
      onError: (Object error, StackTrace _) => add(_BookingWatchFailed(error)),
    );
  }

  void _watchOwner(
    WatchOwnerBookingsRequested event,
    Emitter<BookingState> emit,
  ) {
    if (event.ownerId.isEmpty) {
      _cancelBookingSubscription();
      emit(const BookingFailure('Sign in to review rental requests.'));
      return;
    }
    emit(BookingLoading());
    _cancelBookingSubscription();
    _bookingSubscription = watchOwnerBookings(event.ownerId).listen(
      (bookings) => add(_BookingsChanged(bookings)),
      onError: (Object error, StackTrace _) => add(_BookingWatchFailed(error)),
    );
  }

  Future<void> _updateStatus(
    BookingStatusUpdateRequested event,
    Emitter<BookingState> emit,
  ) async {
    final bookings = _currentBookings;
    emit(BookingLoaded(bookings, actionBookingId: event.bookingId));
    try {
      await updateBookingStatus(
        UpdateBookingStatusParams(
          bookingId: event.bookingId,
          ownerId: event.ownerId,
          status: event.status,
        ),
      );
      final verb = event.status == BookingStatus.accepted
          ? 'accepted'
          : 'declined';
      emit(
        BookingLoaded(bookings, notice: 'Rental request $verb successfully.'),
      );
    } catch (error) {
      emit(BookingLoaded(bookings, errorMessage: _message(error)));
    }
  }

  Future<void> _delete(
    BookingDeleteRequested event,
    Emitter<BookingState> emit,
  ) async {
    final bookings = _currentBookings;
    emit(BookingLoaded(bookings, actionBookingId: event.bookingId));
    try {
      await deleteBooking(
        DeleteBookingParams(
          bookingId: event.bookingId,
          farmerId: event.farmerId,
        ),
      );
      emit(
        BookingLoaded(
          bookings,
          notice: 'Booking request cancelled successfully.',
        ),
      );
    } catch (error) {
      emit(BookingLoaded(bookings, errorMessage: _message(error)));
    }
  }

  List<Booking> get _currentBookings {
    final current = state;
    return current is BookingLoaded ? current.bookings : const [];
  }

  String _message(Object error) {
    final text = error.toString().replaceFirst(RegExp(r'^.*Exception: '), '');
    return text.isEmpty ? 'Something went wrong. Please try again.' : text;
  }

  Future<void>? _cancelBookingSubscription() {
    final subscription = _bookingSubscription;
    _bookingSubscription = null;
    return subscription?.cancel();
  }

  @override
  Future<void> close() async {
    final cancellation = _cancelBookingSubscription();
    if (cancellation != null) await cancellation;
    return super.close();
  }
}
