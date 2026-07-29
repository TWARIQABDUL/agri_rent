import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class ReloadCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  ReloadCurrentUser(this.repository);

  @override
  Future<User?> call(NoParams params) {
    return repository.reloadCurrentUser();
  }
}
