import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../repositories/owner_repository.dart';

@lazySingleton
class GetOwnerListings implements UseCase<List<Equipment>, String> {
  final OwnerRepository repository;

  GetOwnerListings(this.repository);

  @override
  Future<List<Equipment>> call(String ownerId) =>
      repository.getListings(ownerId);
}
