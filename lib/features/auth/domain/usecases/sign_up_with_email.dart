import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignUpWithEmail implements UseCase<User, SignUpWithEmailParams> {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  @override
  Future<User> call(SignUpWithEmailParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpWithEmailParams {
  final String email;
  final String password;
  final String? displayName;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}
