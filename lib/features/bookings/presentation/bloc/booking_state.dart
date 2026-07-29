part of 'booking_bloc.dart';

sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;
  final String? actionBookingId;
  final String? notice;
  final String? errorMessage;

  const BookingLoaded(
    this.bookings, {
    this.actionBookingId,
    this.notice,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [bookings, actionBookingId, notice, errorMessage];
}

class BookingFailure extends BookingState {
  final String message;

  const BookingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
