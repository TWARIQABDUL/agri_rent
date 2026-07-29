import 'package:injectable/injectable.dart';

import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class UpdateBookingStatusParams {
  final String bookingId;
  final String ownerId;
  final BookingStatus status;

  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.ownerId,
    required this.status,
  });
}

@lazySingleton
class UpdateBookingStatus {
  final BookingRepository repository;

  UpdateBookingStatus(this.repository);

  Future<void> call(UpdateBookingStatusParams params) {
    return repository.updateBookingStatus(
      bookingId: params.bookingId,
      ownerId: params.ownerId,
      status: params.status,
    );
  }
}

class DeleteBookingParams {
  final String bookingId;
  final String farmerId;

  const DeleteBookingParams({required this.bookingId, required this.farmerId});
}

@lazySingleton
class DeleteBooking {
  final BookingRepository repository;

  DeleteBooking(this.repository);

  Future<void> call(DeleteBookingParams params) {
    return repository.deleteBooking(
      bookingId: params.bookingId,
      farmerId: params.farmerId,
    );
  }
}
