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
    super.ownerName,
    super.reviewCount,
    super.pricePerHour,
    super.pricePerHectare,
    super.specs,
    super.bookingCount,
    super.createdAt,
    super.updatedAt,
  });

  factory EquipmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EquipmentModel.fromMap(id: doc.id, data: data);
  }

  factory EquipmentModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return EquipmentModel(
      id: id,
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
      ownerName: data['ownerName'] ?? '',
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      pricePerHectare: (data['pricePerHectare'] as num?)?.toDouble() ?? 0.0,
      specs:
          (data['specs'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
      bookingCount: (data['bookingCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory EquipmentModel.fromEntity(Equipment equipment) {
    return EquipmentModel(
      id: equipment.id,
      name: equipment.name,
      ownerId: equipment.ownerId,
      description: equipment.description,
      pricePerDay: equipment.pricePerDay,
      pricePerMonth: equipment.pricePerMonth,
      status: equipment.status,
      category: equipment.category,
      image: equipment.image,
      location: equipment.location,
      rating: equipment.rating,
      ownerName: equipment.ownerName,
      reviewCount: equipment.reviewCount,
      pricePerHour: equipment.pricePerHour,
      pricePerHectare: equipment.pricePerHectare,
      specs: equipment.specs,
      bookingCount: equipment.bookingCount,
      createdAt: equipment.createdAt,
      updatedAt: equipment.updatedAt,
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
      'ownerName': ownerName,
      'reviewCount': reviewCount,
      'pricePerHour': pricePerHour,
      'pricePerHectare': pricePerHectare,
      'specs': specs,
      'bookingCount': bookingCount,
    };
  }
}
