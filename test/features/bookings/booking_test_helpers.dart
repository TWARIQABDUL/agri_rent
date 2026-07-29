import 'dart:async';

import 'package:agri_rent/features/bookings/domain/entities/booking.dart';
import 'package:agri_rent/features/bookings/domain/repositories/booking_repository.dart';

Booking makeBooking({
  String id = 'b-101',
  String farmerId = 'farmer-1',
  String ownerId = 'owner-1',
  BookingStatus status = BookingStatus.pending,
  String equipmentName = 'John Deere 5050D',
  String category = 'Tractor',
}) {
  return Booking(
    id: id,
    farmerId: farmerId,
    farmerName: 'Jean Bosco',
    ownerId: ownerId,
    ownerName: 'Patrick Mugisha',
    equipmentId: 'equipment-1',
    equipmentName: equipmentName,
    equipmentCategory: category,
    equipmentImage: '',
    startDate: DateTime(2026, 6, 10),
    endDate: DateTime(2026, 6, 11),
    durationDays: 2,
    dailyRate: 25000,
    subtotal: 50000,
    serviceFee: 2500,
    totalAmount: 52500,
    status: status,
    renterNote: 'Need it for ploughing 2 hectares of maize field.',
    paymentMethod: 'AgriRent Wallet',
    createdAt: DateTime(2026, 6, 4),
  );
}

class FakeBookingRepository implements BookingRepository {
  final farmerController = StreamController<List<Booking>>.broadcast(
    sync: true,
  );
  final ownerController = StreamController<List<Booking>>.broadcast(sync: true);

  String? watchedFarmerId;
  String? watchedOwnerId;
  String? updatedBookingId;
  String? updateOwnerId;
  BookingStatus? updatedStatus;
  String? deletedBookingId;
  String? deleteFarmerId;
  Object? updateError;
  Object? deleteError;
  List<Booking>? initialFarmerBookings;
  List<Booking>? initialOwnerBookings;

  @override
  Stream<List<Booking>> watchFarmerBookings(String farmerId) {
    watchedFarmerId = farmerId;
    if (initialFarmerBookings != null) {
      return _initialFarmerStream();
    }
    return farmerController.stream;
  }

  @override
  Stream<List<Booking>> watchOwnerBookings(String ownerId) {
    watchedOwnerId = ownerId;
    if (initialOwnerBookings != null) {
      return _initialOwnerStream();
    }
    return ownerController.stream;
  }

  Stream<List<Booking>> _initialFarmerStream() async* {
    yield initialFarmerBookings!;
    yield* farmerController.stream;
  }

  Stream<List<Booking>> _initialOwnerStream() async* {
    yield initialOwnerBookings!;
    yield* ownerController.stream;
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String ownerId,
    required BookingStatus status,
  }) async {
    if (updateError != null) throw updateError!;
    updatedBookingId = bookingId;
    updateOwnerId = ownerId;
    updatedStatus = status;
  }

  @override
  Future<void> deleteBooking({
    required String bookingId,
    required String farmerId,
  }) async {
    if (deleteError != null) throw deleteError!;
    deletedBookingId = bookingId;
    deleteFarmerId = farmerId;
  }

  Future<void> close() async {
    await farmerController.close();
    await ownerController.close();
  }
}
