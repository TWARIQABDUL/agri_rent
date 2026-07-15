part of 'equipment_bloc.dart';

abstract class EquipmentEvent extends Equatable {
  const EquipmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchEquipmentEvent extends EquipmentEvent {
  final String? category;
  final String? location;
  final double? maxPrice;

  const FetchEquipmentEvent({
    this.category,
    this.location,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [category, location, maxPrice];
}
