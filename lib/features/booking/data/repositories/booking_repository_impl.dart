import 'package:injectable/injectable.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';
import '../models/booking_model.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Booking> createBooking(Booking booking) async {
    try {
      return await remoteDataSource.createBooking(
        BookingModel.fromEntity(booking),
      );
    } catch (e) {
      rethrow;
    }
  }
}
