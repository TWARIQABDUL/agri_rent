import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SendEmailVerification implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SendEmailVerification(this.repository);

  @override
  Future<void> call(NoParams params) {
    return repository.sendEmailVerification();
  }
}
