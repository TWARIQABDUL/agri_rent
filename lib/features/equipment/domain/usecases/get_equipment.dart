import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/equipment.dart';
import '../repositories/equipment_repository.dart';

@lazySingleton
class GetEquipment implements UseCase<List<Equipment>, GetEquipmentParams> {
  final EquipmentRepository repository;

  GetEquipment(this.repository);

  @override
  Future<List<Equipment>> call(GetEquipmentParams params) async {
    return await repository.getEquipment(category: params.category);
  }
}

class GetEquipmentParams {
  final String? category;

  GetEquipmentParams({this.category});
}
