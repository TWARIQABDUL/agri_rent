import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class CompleteGoogleSignUp implements UseCase<User, CompleteGoogleSignUpParams> {
  final AuthRepository repository;

  CompleteGoogleSignUp(this.repository);

  @override
  Future<User> call(CompleteGoogleSignUpParams params) {
    return repository.completeGoogleSignUp(params.role);
  }
}

class CompleteGoogleSignUpParams {
  final String role;

  const CompleteGoogleSignUpParams({required this.role});
}
