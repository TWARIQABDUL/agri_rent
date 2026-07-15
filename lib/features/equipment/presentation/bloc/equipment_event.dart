part of 'equipment_bloc.dart';

abstract class EquipmentEvent extends Equatable {
  const EquipmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchEquipmentEvent extends EquipmentEvent {
  final String? category;
  final String? location;

  const FetchEquipmentEvent({this.category, this.location});

  @override
  List<Object?> get props => [category, location];
}
