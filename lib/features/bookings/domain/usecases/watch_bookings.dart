import 'package:injectable/injectable.dart';

import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class WatchFarmerBookings {
  final BookingRepository repository;

  WatchFarmerBookings(this.repository);

  Stream<List<Booking>> call(String farmerId) {
    return repository.watchFarmerBookings(farmerId);
  }
}

@lazySingleton
class WatchOwnerBookings {
  final BookingRepository repository;

  WatchOwnerBookings(this.repository);

  Stream<List<Booking>> call(String ownerId) {
    return repository.watchOwnerBookings(ownerId);
  }
}
