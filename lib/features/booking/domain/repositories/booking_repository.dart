import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Booking> createBooking(Booking booking);
}
