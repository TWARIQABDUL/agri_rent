import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/entities/listing_draft.dart';
import '../../domain/entities/owner_summary.dart';
import '../../domain/repositories/owner_repository.dart';
import '../datasources/owner_remote_data_source.dart';

@LazySingleton(as: OwnerRepository)
class OwnerRepositoryImpl implements OwnerRepository {
  final OwnerRemoteDataSource remoteDataSource;

  OwnerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Equipment>> getListings(String ownerId) {
    return _guard(() => remoteDataSource.getListings(ownerId));
  }

  @override
  Future<String> publishListing({
    required String ownerId,
    required ListingDraft draft,
  }) {
    return _guard(
      () => remoteDataSource.createListing(ownerId: ownerId, draft: draft),
    );
  }

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  }) {
    return _guard(
      () => remoteDataSource.updateListing(listingId: listingId, draft: draft),
    );
  }

  @override
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  }) {
    return _guard(
      () => remoteDataSource.setListingPaused(
        listingId: listingId,
        paused: paused,
      ),
    );
  }

  @override
  Future<OwnerSummary> getSummary(String ownerId) {
    return _guard(() async {
      final rentals = await remoteDataSource.getRentals(ownerId);
      final listings = await remoteDataSource.getListings(ownerId);
      return OwnerSummary.from(rentals: rentals, listings: listings);
    });
  }

  @override
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  }) {
    return _guard(
      () => remoteDataSource.ensureOwnerProfile(
        ownerId: ownerId,
        displayName: displayName,
        email: email,
      ),
    );
  }

  /// Keeps Firebase error codes out of the blocs. Everything above this layer
  /// only ever sees an [AppException] with a message worth showing.
  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw AppException(_messageFor(error));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('Something went wrong. Please try again.');
    }
  }

  String _messageFor(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Your owner account is not verified yet, so listings cannot be '
            'changed. Verification is completed by the AgriRent team.';
      case 'not-found':
        return 'This listing no longer exists.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'No connection to the server. Check your network and try again.';
      case 'resource-exhausted':
        return 'The service is busy right now. Please try again shortly.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
}
