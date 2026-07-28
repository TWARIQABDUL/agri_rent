import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';
import 'calculate_rental_cost.dart';

class CreateBookingParams {
  final Equipment equipment;
  final String farmerId;
  final String rateType;
  final double rate;
  final int duration;
  final DateTime startDate;

  CreateBookingParams({
    required this.equipment,
    required this.farmerId,
    required this.rateType,
    required this.rate,
    required this.duration,
    required this.startDate,
  });
}

@lazySingleton
class CreateBooking implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository repository;
  final CalculateRentalCost calculateRentalCost;

  CreateBooking(this.repository, this.calculateRentalCost);

  @override
  Future<Booking> call(CreateBookingParams params) async {
    final breakdown = calculateRentalCost(
      rate: params.rate,
      duration: params.duration,
    );

    final booking = Booking(
      id: '',
      equipmentId: params.equipment.id,
      equipmentName: params.equipment.name,
      equipmentCategory: params.equipment.category,
      farmerId: params.farmerId,
      ownerId: params.equipment.ownerId,
      ownerName: params.equipment.ownerName,
      rateType: params.rateType,
      rate: params.rate,
      duration: params.duration,
      startDate: params.startDate,
      subtotal: breakdown.subtotal,
      serviceFee: breakdown.serviceFee,
      total: breakdown.total,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    return repository.createBooking(booking);
  }
}
