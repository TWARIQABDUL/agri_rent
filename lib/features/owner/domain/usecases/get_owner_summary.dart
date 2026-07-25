import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/owner_summary.dart';
import '../repositories/owner_repository.dart';

@lazySingleton
class GetOwnerSummary implements UseCase<OwnerSummary, String> {
  final OwnerRepository repository;

  GetOwnerSummary(this.repository);

  @override
  Future<OwnerSummary> call(String ownerId) => repository.getSummary(ownerId);
}
