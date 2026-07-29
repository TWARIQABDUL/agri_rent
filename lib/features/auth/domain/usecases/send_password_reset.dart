import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SendPasswordReset implements UseCase<void, SendPasswordResetParams> {
  final AuthRepository repository;

  SendPasswordReset(this.repository);

  @override
  Future<void> call(SendPasswordResetParams params) {
    return repository.sendPasswordResetEmail(params.email);
  }
}

class SendPasswordResetParams {
  final String email;

  SendPasswordResetParams({required this.email});
}
