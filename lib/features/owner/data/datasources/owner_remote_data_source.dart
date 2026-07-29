import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../equipment/data/models/equipment_model.dart';
import '../../domain/entities/listing_draft.dart';
import '../models/listing_write_model.dart';
import '../models/owner_rental_model.dart';

abstract class OwnerRemoteDataSource {
  Future<List<EquipmentModel>> getListings(String ownerId);

  Future<String> createListing({
    required String ownerId,
    required ListingDraft draft,
  });

  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  });

  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  });

  Future<List<OwnerRentalModel>> getRentals(String ownerId);

  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  });
}

@LazySingleton(as: OwnerRemoteDataSource)
class OwnerRemoteDataSourceImpl implements OwnerRemoteDataSource {
  static const String _equipment = 'equipment';
  static const String _rentals = 'rentals';
  static const String _users = 'users';
  static const String _ownerRole = 'owner';

  final FirebaseFirestore firestore;

  OwnerRemoteDataSourceImpl(this.firestore);

  /// Sorted in Dart rather than with `orderBy`, so an owner query needs only
  /// the single-field index Firestore creates by itself.
  @override
  Future<List<EquipmentModel>> getListings(String ownerId) async {
    final snapshot = await firestore
        .collection(_equipment)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs.map(EquipmentModel.fromFirestore).toList()
      ..sort(_newestFirst);
  }

  /// Listings written before `createdAt` existed fall back to alphabetical
  /// order instead of jumping to the top of the shelf.
  static int _newestFirst(EquipmentModel a, EquipmentModel b) {
    final left = a.createdAt;
    final right = b.createdAt;
    if (left == null || right == null) return a.name.compareTo(b.name);
    return right.compareTo(left);
  }

  @override
  Future<String> createListing({
    required String ownerId,
    required ListingDraft draft,
  }) async {
    final reference = await firestore
        .collection(_equipment)
        .add(ListingWriteModel.create(ownerId: ownerId, draft: draft));
    return reference.id;
  }

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  }) {
    return firestore
        .collection(_equipment)
        .doc(listingId)
        .update(ListingWriteModel.update(draft));
  }

  @override
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  }) {
    return firestore
        .collection(_equipment)
        .doc(listingId)
        .update(ListingWriteModel.status(paused: paused));
  }

  @override
  Future<List<OwnerRentalModel>> getRentals(String ownerId) async {
    final snapshot = await firestore
        .collection(_rentals)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs.map(OwnerRentalModel.fromFirestore).toList();
  }

  /// Writes only the fields a client is allowed to own. `verified` is left
  /// alone on purpose: the security rules reject any client write to it, and
  /// the listing rules read it to decide whether this owner may publish.
  @override
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  }) async {
    final document = firestore.collection(_users).doc(ownerId);
    final profile = <String, dynamic>{
      'role': _ownerRole,
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      if (email != null && email.isNotEmpty) 'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final snapshot = await document.get();
    if (snapshot.exists) {
      await document.update(profile);
      return;
    }

    await document.set({
      ...profile,
      'verified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
