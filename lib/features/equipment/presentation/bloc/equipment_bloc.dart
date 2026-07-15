import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/equipment.dart';
import '../../domain/usecases/get_equipment.dart';

part 'equipment_event.dart';
part 'equipment_state.dart';

@injectable
class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  final GetEquipment getEquipment;

  EquipmentBloc(this.getEquipment) : super(EquipmentInitial()) {
    on<FetchEquipmentEvent>((event, emit) async {
      emit(EquipmentLoading());
      try {
        final equipmentList = await getEquipment(
          GetEquipmentParams(category: event.category),
        );
        
        // Client-side filtering for location (as requested for Phase 1)
        List<Equipment> filteredList = equipmentList;
        if (event.location != null && event.location!.isNotEmpty) {
          filteredList = equipmentList
              .where((e) => e.location.toLowerCase().contains(event.location!.toLowerCase()))
              .toList();
        }

        emit(EquipmentLoaded(filteredList));
      } catch (e) {
        emit(EquipmentError(e.toString()));
      }
    });
  }
}
