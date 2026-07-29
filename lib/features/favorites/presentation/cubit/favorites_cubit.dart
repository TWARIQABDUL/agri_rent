import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesState extends Equatable {
  final List<Equipment> equipment;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.equipment = const [],
    this.isLoading = false,
    this.error,
  });

  Set<String> get equipmentIds => equipment.map((item) => item.id).toSet();

  bool contains(String equipmentId) => equipmentIds.contains(equipmentId);

  @override
  List<Object?> get props => [equipment, isLoading, error];
}

@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;

  StreamSubscription<List<Equipment>>? _subscription;
  String? _userId;

  FavoritesCubit(this.repository) : super(const FavoritesState());

  void watch(String userId) {
    if (_userId == userId && _subscription != null) return;
    _userId = userId;
    emit(FavoritesState(equipment: state.equipment, isLoading: true));
    _subscription?.cancel();
    _subscription = repository
        .watchFavorites(userId)
        .listen(
          (equipment) => emit(FavoritesState(equipment: equipment)),
          onError: (Object error, StackTrace stackTrace) => emit(
            FavoritesState(equipment: state.equipment, error: error.toString()),
          ),
        );
  }

  Future<void> toggle(Equipment equipment) async {
    final userId = _userId;
    if (userId == null) {
      emit(
        FavoritesState(
          equipment: state.equipment,
          error: 'Sign in before saving favorites.',
        ),
      );
      return;
    }

    final wasFavorite = state.contains(equipment.id);
    final previous = state.equipment;
    final optimistic = wasFavorite
        ? previous.where((item) => item.id != equipment.id).toList()
        : [equipment, ...previous];
    emit(FavoritesState(equipment: optimistic));

    try {
      if (wasFavorite) {
        await repository.removeFavorite(
          userId: userId,
          equipmentId: equipment.id,
        );
      } else {
        await repository.addFavorite(userId: userId, equipment: equipment);
      }
    } catch (error) {
      emit(FavoritesState(equipment: previous, error: error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
