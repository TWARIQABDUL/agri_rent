import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/booking.dart';
import '../../domain/usecases/create_booking.dart';

part 'booking_event.dart';
part 'booking_state.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBooking createBooking;

  BookingBloc(this.createBooking) : super(BookingInitial()) {
    on<SubmitBookingRequest>((event, emit) async {
      emit(BookingSubmitting());
      try {
        final booking = await createBooking(event.params);
        emit(BookingSuccess(booking));
      } catch (e) {
        emit(BookingFailure(e.toString()));
      }
    });
  }
}
