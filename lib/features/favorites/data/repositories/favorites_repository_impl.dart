import 'package:injectable/injectable.dart';

import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<Equipment>> watchFavorites(String userId) {
    return remoteDataSource.watchFavorites(userId);
  }

  @override
  Future<void> addFavorite({
    required String userId,
    required Equipment equipment,
  }) {
    return remoteDataSource.addFavorite(userId: userId, equipment: equipment);
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String equipmentId,
  }) {
    return remoteDataSource.removeFavorite(
      userId: userId,
      equipmentId: equipmentId,
    );
  }
}
