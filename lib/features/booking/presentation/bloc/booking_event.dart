part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBookingRequest extends BookingEvent {
  final CreateBookingParams params;

  const SubmitBookingRequest(this.params);

  @override
  List<Object?> get props => [params];
}
