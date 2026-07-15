import '../entities/equipment.dart';

abstract class EquipmentRepository {
  Future<List<Equipment>> getEquipment({String? category});
}
