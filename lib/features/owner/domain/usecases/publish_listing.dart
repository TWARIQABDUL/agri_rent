import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/listing_draft.dart';
import '../repositories/owner_repository.dart';

@lazySingleton
class PublishListing implements UseCase<String, PublishListingParams> {
  final OwnerRepository repository;

  PublishListing(this.repository);

  @override
  Future<String> call(PublishListingParams params) {
    if (!params.draft.isPublishable) {
      throw const AppException(
        'This listing is missing details. Complete every step before '
        'publishing.',
      );
    }
    return repository.publishListing(
      ownerId: params.ownerId,
      draft: params.draft,
    );
  }
}

class PublishListingParams {
  final String ownerId;
  final ListingDraft draft;

  const PublishListingParams({required this.ownerId, required this.draft});
}
