import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  accepted,
  active,
  completed,
  declined,
  cancelled;

  String get value => name;

  String get label => switch (this) {
    BookingStatus.pending => 'Pending',
    BookingStatus.accepted => 'Accepted',
    BookingStatus.active => 'In use',
    BookingStatus.completed => 'Completed',
    BookingStatus.declined => 'Declined',
    BookingStatus.cancelled => 'Cancelled',
  };

  static BookingStatus fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'accepted' || 'approved' || 'confirmed' => BookingStatus.accepted,
      'active' || 'in_use' || 'in use' => BookingStatus.active,
      'completed' || 'complete' => BookingStatus.completed,
      'declined' || 'rejected' => BookingStatus.declined,
      'cancelled' || 'canceled' => BookingStatus.cancelled,
      _ => BookingStatus.pending,
    };
  }
}

enum FarmerBookingGroup { pending, active, history }

enum OwnerBookingGroup { pending, accepted, declined }

class Booking extends Equatable {
  final String id;
  final String farmerId;
  final String farmerName;
  final String ownerId;
  final String ownerName;
  final String equipmentId;
  final String equipmentName;
  final String equipmentCategory;
  final String equipmentImage;
  final DateTime startDate;
  final DateTime endDate;
  final String rateType;
  final int durationDays;
  final double dailyRate;
  final double subtotal;
  final double serviceFee;
  final double totalAmount;
  final BookingStatus status;
  final String renterNote;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.ownerId,
    required this.ownerName,
    required this.equipmentId,
    required this.equipmentName,
    required this.equipmentCategory,
    required this.equipmentImage,
    required this.startDate,
    required this.endDate,
    this.rateType = 'day',
    required this.durationDays,
    required this.dailyRate,
    required this.subtotal,
    required this.serviceFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.renterNote = '',
    this.paymentMethod = 'AgriRent Wallet',
    this.updatedAt,
  });

  bool belongsToFarmerGroup(FarmerBookingGroup group) => switch (group) {
    FarmerBookingGroup.pending => status == BookingStatus.pending,
    FarmerBookingGroup.active =>
      status == BookingStatus.accepted || status == BookingStatus.active,
    FarmerBookingGroup.history =>
      status == BookingStatus.completed ||
          status == BookingStatus.declined ||
          status == BookingStatus.cancelled,
  };

  bool belongsToOwnerGroup(OwnerBookingGroup group) => switch (group) {
    OwnerBookingGroup.pending => status == BookingStatus.pending,
    OwnerBookingGroup.accepted =>
      status == BookingStatus.accepted ||
          status == BookingStatus.active ||
          status == BookingStatus.completed,
    OwnerBookingGroup.declined =>
      status == BookingStatus.declined || status == BookingStatus.cancelled,
  };

  String get rateUnit => switch (rateType) {
    'hour' => 'hour',
    'hectare' => 'hectare',
    _ => 'day',
  };

  String get durationLabel =>
      '$durationDays $rateUnit${durationDays == 1 ? '' : 's'}';

  String get rateLabel => switch (rateType) {
    'hour' => 'Hourly rate',
    'hectare' => 'Rate per hectare',
    _ => 'Daily rate',
  };

  @override
  List<Object?> get props => [
    id,
    farmerId,
    farmerName,
    ownerId,
    ownerName,
    equipmentId,
    equipmentName,
    equipmentCategory,
    equipmentImage,
    startDate,
    endDate,
    rateType,
    durationDays,
    dailyRate,
    subtotal,
    serviceFee,
    totalAmount,
    status,
    renterNote,
    paymentMethod,
    createdAt,
    updatedAt,
  ];
}
