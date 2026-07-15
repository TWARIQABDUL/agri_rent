import 'package:injectable/injectable.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../datasources/equipment_remote_data_source.dart';

@LazySingleton(as: EquipmentRepository)
class EquipmentRepositoryImpl implements EquipmentRepository {
  final EquipmentRemoteDataSource remoteDataSource;

  EquipmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Equipment>> getEquipment({String? category}) async {
    try {
      return await remoteDataSource.getEquipment(category: category);
    } catch (e) {
      // In a real app, you would handle exceptions and return failures
      rethrow;
    }
  }
}
