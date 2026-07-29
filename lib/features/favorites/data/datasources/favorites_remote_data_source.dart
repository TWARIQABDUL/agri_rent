import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../equipment/data/models/equipment_model.dart';
import '../../../equipment/domain/entities/equipment.dart';

abstract class FavoritesRemoteDataSource {
  Stream<List<EquipmentModel>> watchFavorites(String userId);

  Future<void> addFavorite({
    required String userId,
    required Equipment equipment,
  });

  Future<void> removeFavorite({
    required String userId,
    required String equipmentId,
  });
}

@LazySingleton(as: FavoritesRemoteDataSource)
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoritesRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> _favorites(String userId) =>
      firestore.collection('users').doc(userId).collection('favorites');

  @override
  Stream<List<EquipmentModel>> watchFavorites(String userId) {
    return _favorites(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => EquipmentModel.fromMap(
                  id: document.id,
                  data: document.data(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> addFavorite({
    required String userId,
    required Equipment equipment,
  }) {
    final data = EquipmentModel.fromEntity(equipment).toJson()
      ..addAll({
        'equipmentId': equipment.id,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    return _favorites(userId).doc(equipment.id).set(data);
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String equipmentId,
  }) {
    return _favorites(userId).doc(equipmentId).delete();
  }
}
