part of 'equipment_bloc.dart';

abstract class EquipmentState extends Equatable {
  const EquipmentState();

  @override
  List<Object?> get props => [];
}

class EquipmentInitial extends EquipmentState {}

class EquipmentLoading extends EquipmentState {}

class EquipmentLoaded extends EquipmentState {
  final List<Equipment> equipment;

  const EquipmentLoaded(this.equipment);

  @override
  List<Object?> get props => [equipment];
}

class EquipmentError extends EquipmentState {
  final String message;

  const EquipmentError(this.message);

  @override
  List<Object?> get props => [message];
}
