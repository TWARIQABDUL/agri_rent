import 'package:equatable/equatable.dart';

import '../../../equipment/domain/entities/equipment.dart';

/// Everything an owner supplies to publish or edit a listing.
///
/// The draft carries no id and no derived fields: rating, booking count and
/// timestamps belong to the server, not to the form.
class ListingDraft extends Equatable {
  static const int minDescriptionLength = 20;

  final String name;
  final String category;
  final double pricePerDay;
  final double pricePerMonth;
  final String location;
  final String description;
  final String imageUrl;

  const ListingDraft({
    this.name = '',
    this.category = '',
    this.pricePerDay = 0,
    this.pricePerMonth = 0,
    this.location = '',
    this.description = '',
    this.imageUrl = '',
  });

  factory ListingDraft.fromEquipment(Equipment equipment) => ListingDraft(
    name: equipment.name,
    category: equipment.category,
    pricePerDay: equipment.pricePerDay,
    pricePerMonth: equipment.pricePerMonth,
    location: equipment.location,
    description: equipment.description,
    imageUrl: equipment.image,
  );

  /// Step one: what the machine is.
  bool get hasIdentity => name.trim().isNotEmpty && category.isNotEmpty;

  /// Step two: what it costs and where it sits.
  bool get hasTerms => pricePerDay > 0 && location.trim().isNotEmpty;

  /// Step three: enough copy for a farmer to decide.
  bool get hasDetails => description.trim().length >= minDescriptionLength;

  bool get isPublishable => hasIdentity && hasTerms && hasDetails;

  ListingDraft copyWith({
    String? name,
    String? category,
    double? pricePerDay,
    double? pricePerMonth,
    String? location,
    String? description,
    String? imageUrl,
  }) {
    return ListingDraft(
      name: name ?? this.name,
      category: category ?? this.category,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    name,
    category,
    pricePerDay,
    pricePerMonth,
    location,
    description,
    imageUrl,
  ];
}
