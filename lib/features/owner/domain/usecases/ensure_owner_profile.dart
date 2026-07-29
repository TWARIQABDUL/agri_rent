import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/owner_repository.dart';

/// Run when the owner area opens, so the profile document the security rules
/// read from exists before the first listing write is attempted.
@lazySingleton
class EnsureOwnerProfile implements UseCase<void, EnsureOwnerProfileParams> {
  final OwnerRepository repository;

  EnsureOwnerProfile(this.repository);

  @override
  Future<void> call(EnsureOwnerProfileParams params) =>
      repository.ensureOwnerProfile(
        ownerId: params.ownerId,
        displayName: params.displayName,
        email: params.email,
      );
}

class EnsureOwnerProfileParams {
  final String ownerId;
  final String? displayName;
  final String? email;

  const EnsureOwnerProfileParams({
    required this.ownerId,
    this.displayName,
    this.email,
  });
}
