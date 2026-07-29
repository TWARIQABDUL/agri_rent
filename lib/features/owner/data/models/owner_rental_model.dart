import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/owner_rental.dart';

class OwnerRentalModel extends OwnerRental {
  const OwnerRentalModel({
    required super.id,
    required super.equipmentId,
    required super.equipmentName,
    required super.renterName,
    required super.startDate,
    required super.endDate,
    required super.amount,
    required super.status,
    required super.updatedAt,
    super.paidOut,
  });

  factory OwnerRentalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final start = (data['startDate'] as Timestamp?)?.toDate();
    final end = (data['endDate'] as Timestamp?)?.toDate();
    final updated = (data['updatedAt'] as Timestamp?)?.toDate();
    return OwnerRentalModel(
      id: doc.id,
      equipmentId: data['equipmentId'] ?? '',
      equipmentName: data['equipmentName'] ?? '',
      renterName: data['renterName'] ?? '',
      startDate: start ?? DateTime.fromMillisecondsSinceEpoch(0),
      endDate: end ?? start ?? DateTime.fromMillisecondsSinceEpoch(0),
      amount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? RentalStatus.pending,
      paidOut: data['paidOut'] ?? false,
      updatedAt: updated ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
