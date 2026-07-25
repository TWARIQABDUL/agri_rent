import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/equipment.dart';

class EquipmentModel extends Equipment {
  const EquipmentModel({
    required super.id,
    required super.name,
    required super.ownerId,
    required super.description,
    required super.pricePerDay,
    required super.pricePerMonth,
    required super.status,
    required super.category,
    required super.image,
    required super.location,
    required super.rating,
    super.bookingCount,
    super.createdAt,
    super.updatedAt,
  });

  factory EquipmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentModel(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      description: data['description'] ?? '',
      pricePerDay: (data['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      pricePerMonth: (data['pricePerMonth'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? EquipmentStatus.available,
      category: data['category'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      bookingCount: (data['bookingCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ownerId': ownerId,
      'description': description,
      'pricePerDay': pricePerDay,
      'pricePerMonth': pricePerMonth,
      'status': status,
      'category': category,
      'image': image,
      'location': location,
      'rating': rating,
      'bookingCount': bookingCount,
    };
  }
}
