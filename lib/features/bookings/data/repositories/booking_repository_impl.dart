import 'package:injectable/injectable.dart';

import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Booking>> watchFarmerBookings(String farmerId) {
    return remoteDataSource.watchFarmerBookings(farmerId);
  }

  @override
  Stream<List<Booking>> watchOwnerBookings(String ownerId) {
    return remoteDataSource.watchOwnerBookings(ownerId);
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String ownerId,
    required BookingStatus status,
  }) {
    return remoteDataSource.updateBookingStatus(
      bookingId: bookingId,
      ownerId: ownerId,
      status: status,
    );
  }

  @override
  Future<void> deleteBooking({
    required String bookingId,
    required String farmerId,
  }) {
    return remoteDataSource.deleteBooking(
      bookingId: bookingId,
      farmerId: farmerId,
    );
  }
}
