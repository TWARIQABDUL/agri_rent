import '../../../equipment/domain/entities/equipment.dart';
import '../entities/listing_draft.dart';
import '../entities/owner_summary.dart';

/// Everything the owner side of the marketplace needs from storage.
///
/// Farmers read the same `equipment` collection through
/// `EquipmentRepository`; this contract covers the writes and the
/// owner-scoped reads that browsing does not need.
abstract class OwnerRepository {
  /// Every listing belonging to [ownerId], newest first, paused ones included.
  Future<List<Equipment>> getListings(String ownerId);

  /// Creates a listing owned by [ownerId] and returns its document id.
  Future<String> publishListing({
    required String ownerId,
    required ListingDraft draft,
  });

  /// Overwrites the owner-editable fields of an existing listing.
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  });

  /// Hides a listing from browse, or puts it back on the market.
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  });

  /// Earnings, counters and rental activity for the dashboard.
  Future<OwnerSummary> getSummary(String ownerId);

  /// Makes sure the owner has a profile document, because the security rules
  /// read `role` from it before allowing any listing write. Never sets the
  /// verification flag; only an administrator can do that.
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  });
}
