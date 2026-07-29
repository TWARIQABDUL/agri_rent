import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.equipmentId,
    required super.equipmentName,
    required super.equipmentCategory,
    required super.equipmentImage,
    required super.farmerId,
    required super.farmerName,
    required super.ownerId,
    required super.ownerName,
    required super.rateType,
    required super.rate,
    required super.duration,
    required super.startDate,
    required super.subtotal,
    required super.serviceFee,
    required super.total,
    required super.status,
    required super.createdAt,
    super.walletTransactionId,
    super.paymentStatus,
  });

  factory BookingModel.fromEntity(
    Booking booking, {
    String? id,
    String? walletTransactionId,
  }) {
    return BookingModel(
      id: id ?? booking.id,
      equipmentId: booking.equipmentId,
      equipmentName: booking.equipmentName,
      equipmentCategory: booking.equipmentCategory,
      equipmentImage: booking.equipmentImage,
      farmerId: booking.farmerId,
      farmerName: booking.farmerName,
      ownerId: booking.ownerId,
      ownerName: booking.ownerName,
      rateType: booking.rateType,
      rate: booking.rate,
      duration: booking.duration,
      startDate: booking.startDate,
      subtotal: booking.subtotal,
      serviceFee: booking.serviceFee,
      total: booking.total,
      status: booking.status,
      createdAt: booking.createdAt,
      walletTransactionId: walletTransactionId ?? booking.walletTransactionId,
      paymentStatus: booking.paymentStatus,
    );
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      equipmentId: data['equipmentId'] ?? '',
      equipmentName: data['equipmentName'] ?? '',
      equipmentCategory: data['equipmentCategory'] ?? '',
      equipmentImage: data['equipmentImage'] ?? '',
      // Wire field is `renterId` (deployed security rules' vocabulary);
      // domain entity keeps `farmerId` since that's this app's own term.
      farmerId: data['renterId'] ?? '',
      farmerName: data['renterName'] ?? 'Farmer',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      rateType: data['rateType'] ?? 'day',
      rate: (data['rate'] as num?)?.toDouble() ?? 0.0,
      duration: (data['duration'] as num?)?.toInt() ?? 1,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (data['serviceFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      walletTransactionId: data['walletTransactionId'] ?? '',
      paymentStatus: data['paymentStatus'] ?? BookingPaymentStatus.paid,
    );
  }

  /// Field names here must match the deployed Firestore security rules for
  /// `/rentals/{rentalId}` exactly: `renterId`, `totalAmount`, `endDate` and
  /// `paidOut` are all checked server-side on create. Extra display fields
  /// (equipmentName, rate, subtotal, etc.) are unrestricted on create, so
  /// they ride along for screens that read this collection back.
  Map<String, dynamic> toJson() {
    return {
      'renterId': farmerId,
      'ownerId': ownerId,
      'equipmentId': equipmentId,
      'status': status,
      'paidOut': false,
      'paymentStatus': paymentStatus,
      'walletTransactionId': walletTransactionId,
      'totalAmount': total,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(startDate.add(_durationSpan())),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'equipmentName': equipmentName,
      'equipmentCategory': equipmentCategory,
      'equipmentImage': equipmentImage,
      'renterName': farmerName,
      'ownerName': ownerName,
      'rateType': rateType,
      'rate': rate,
      'duration': duration,
      'subtotal': subtotal,
      'serviceFee': serviceFee,
    };
  }

  /// `endDate` has no natural meaning for a per-hectare job (that rate
  /// prices land area, not time), so it defaults to a one-day window; hourly
  /// and daily rates translate `duration` directly into the matching span.
  Duration _durationSpan() {
    switch (rateType) {
      case 'hour':
        return Duration(hours: duration);
      case 'hectare':
        return const Duration(days: 1);
      case 'day':
      default:
        return Duration(days: duration);
    }
  }
}
