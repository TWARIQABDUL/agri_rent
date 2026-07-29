import '../../../equipment/domain/entities/equipment.dart';

abstract class FavoritesRepository {
  Stream<List<Equipment>> watchFavorites(String userId);

  Future<void> addFavorite({
    required String userId,
    required Equipment equipment,
  });

  Future<void> removeFavorite({
    required String userId,
    required String equipmentId,
  });
}
