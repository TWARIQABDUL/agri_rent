part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class WatchFarmerBookingsRequested extends BookingEvent {
  final String farmerId;

  const WatchFarmerBookingsRequested(this.farmerId);

  @override
  List<Object?> get props => [farmerId];
}

class WatchOwnerBookingsRequested extends BookingEvent {
  final String ownerId;

  const WatchOwnerBookingsRequested(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class BookingStatusUpdateRequested extends BookingEvent {
  final String bookingId;
  final String ownerId;
  final BookingStatus status;

  const BookingStatusUpdateRequested({
    required this.bookingId,
    required this.ownerId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, ownerId, status];
}

class BookingDeleteRequested extends BookingEvent {
  final String bookingId;
  final String farmerId;

  const BookingDeleteRequested({
    required this.bookingId,
    required this.farmerId,
  });

  @override
  List<Object?> get props => [bookingId, farmerId];
}

class _BookingsChanged extends BookingEvent {
  final List<Booking> bookings;

  const _BookingsChanged(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class _BookingWatchFailed extends BookingEvent {
  final Object error;

  const _BookingWatchFailed(this.error);

  @override
  List<Object?> get props => [error];
}
