import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing_draft.dart';
import '../repositories/owner_repository.dart';

@lazySingleton
class UpdateListing implements UseCase<void, UpdateListingParams> {
  final OwnerRepository repository;

  UpdateListing(this.repository);

  @override
  Future<void> call(UpdateListingParams params) {
    if (!params.draft.isPublishable) {
      throw const AppException(
        'This listing is missing details. Complete every step before saving.',
      );
    }
    return repository.updateListing(
      listingId: params.listingId,
      draft: params.draft,
    );
  }
}

class UpdateListingParams {
  final String listingId;
  final ListingDraft draft;

  const UpdateListingParams({required this.listingId, required this.draft});
}
