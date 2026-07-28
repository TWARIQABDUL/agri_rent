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
      status: data['status'] ?? 'available',
      category: data['category'] ?? '',
      image: data['image'] ?? '',
      location: data['location'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ownerName: data['ownerName'] ?? '',
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      pricePerHectare: (data['pricePerHectare'] as num?)?.toDouble() ?? 0.0,
      specs: (data['specs'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
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
    };
  }
}
