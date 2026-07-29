import 'package:equatable/equatable.dart';

abstract class RateType {
  static const hour = 'hour';
  static const day = 'day';
  static const hectare = 'hectare';
}

abstract class BookingStatus {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const declined = 'declined';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

abstract class BookingPaymentStatus {
  static const paid = 'paid';
}

class Booking extends Equatable {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String equipmentCategory;
  final String equipmentImage;
  final String farmerId;
  final String farmerName;
  final String ownerId;
  final String ownerName;
  final String rateType;
  final double rate;
  final int duration;
  final DateTime startDate;
  final double subtotal;
  final double serviceFee;
  final double total;
  final String status;
  final DateTime createdAt;
  final String walletTransactionId;
  final String paymentStatus;

  const Booking({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentCategory,
    required this.equipmentImage,
    required this.farmerId,
    required this.farmerName,
    required this.ownerId,
    required this.ownerName,
    required this.rateType,
    required this.rate,
    required this.duration,
    required this.startDate,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.walletTransactionId = '',
    this.paymentStatus = BookingPaymentStatus.paid,
  });

  @override
  List<Object?> get props => [
    id,
    equipmentId,
    equipmentName,
    equipmentCategory,
    equipmentImage,
    farmerId,
    farmerName,
    ownerId,
    ownerName,
    rateType,
    rate,
    duration,
    startDate,
    subtotal,
    serviceFee,
    total,
    status,
    createdAt,
    walletTransactionId,
    paymentStatus,
  ];
}
