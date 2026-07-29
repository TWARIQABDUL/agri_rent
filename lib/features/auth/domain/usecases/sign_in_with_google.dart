import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/google_auth_result.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInWithGoogle
    implements UseCase<GoogleAuthResult, SignInWithGoogleParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<GoogleAuthResult> call(SignInWithGoogleParams params) {
    return repository.signInWithGoogle(presetRole: params.presetRole);
  }
}

class SignInWithGoogleParams {
  final String? presetRole;

  const SignInWithGoogleParams({this.presetRole});
}
