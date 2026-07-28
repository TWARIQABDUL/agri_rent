import 'package:equatable/equatable.dart';

class Equipment extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final String description;
  final double pricePerDay;
  final double pricePerMonth;
  final String status;
  final String category;
  final String image;
  final String location;
  final double rating;
  final String ownerName;
  final int reviewCount;
  final double pricePerHour;
  final double pricePerHectare;
  final Map<String, String> specs;

  const Equipment({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.description,
    required this.pricePerDay,
    required this.pricePerMonth,
    required this.status,
    required this.category,
    required this.image,
    required this.location,
    required this.rating,
    this.ownerName = '',
    this.reviewCount = 0,
    this.pricePerHour = 0.0,
    this.pricePerHectare = 0.0,
    this.specs = const {},
  });

  @override
  List<Object?> get props => [
    id,
    name,
    ownerId,
    description,
    pricePerDay,
    pricePerMonth,
    status,
    category,
    image,
    location,
    rating,
    ownerName,
    reviewCount,
    pricePerHour,
    pricePerHectare,
    specs,
  ];
}
