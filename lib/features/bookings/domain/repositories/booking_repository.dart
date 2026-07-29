import '../entities/booking.dart';

abstract class BookingRepository {
  Stream<List<Booking>> watchFarmerBookings(String farmerId);

  Stream<List<Booking>> watchOwnerBookings(String ownerId);

  Future<void> updateBookingStatus({
    required String bookingId,
    required String ownerId,
    required BookingStatus status,
  });

  Future<void> deleteBooking({
    required String bookingId,
    required String farmerId,
  });
}
