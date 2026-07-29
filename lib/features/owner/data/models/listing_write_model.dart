import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/entities/listing_draft.dart';

/// Turns a [ListingDraft] into the payloads the `equipment` collection accepts.
///
/// The split matters: `create` initializes fields the owner does not control
/// (status, rating, booking count, created timestamp), while `update` leaves
/// every one of them untouched. The security rules reject an update that tries
/// to move them, so keeping them out of the map here is what lets a legitimate
/// edit through.
class ListingWriteModel {
  const ListingWriteModel._();

  static Map<String, dynamic> create({
    required String ownerId,
    required ListingDraft draft,
  }) {
    return {
      ..._ownerEditableFields(draft),
      'ownerId': ownerId,
      'status': EquipmentStatus.available,
      'rating': 0.0,
      'bookingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> update(ListingDraft draft) {
    return {
      ..._ownerEditableFields(draft),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> status({required bool paused}) {
    return {
      'status': paused ? EquipmentStatus.paused : EquipmentStatus.available,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _ownerEditableFields(ListingDraft draft) {
    return {
      'name': draft.name.trim(),
      'category': draft.category,
      'description': draft.description.trim(),
      'pricePerDay': draft.pricePerDay,
      'pricePerMonth': draft.pricePerMonth,
      'location': draft.location.trim(),
      'image': draft.imageUrl.trim(),
    };
  }
}
