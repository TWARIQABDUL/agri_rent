import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/owner_repository.dart';

@lazySingleton
class SetListingPaused implements UseCase<void, SetListingPausedParams> {
  final OwnerRepository repository;

  SetListingPaused(this.repository);

  @override
  Future<void> call(SetListingPausedParams params) => repository
      .setListingPaused(listingId: params.listingId, paused: params.paused);
}

class SetListingPausedParams {
  final String listingId;
  final bool paused;

  const SetListingPausedParams({required this.listingId, required this.paused});
}
