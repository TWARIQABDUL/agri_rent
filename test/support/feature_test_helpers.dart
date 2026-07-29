import 'dart:async';

import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:agri_rent/features/wallet/domain/entities/wallet.dart';
import 'package:agri_rent/features/wallet/domain/repositories/wallet_repository.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  final _controller = StreamController<List<Equipment>>.broadcast(sync: true);
  final List<Equipment> favorites;
  Object? error;

  FakeFavoritesRepository([Iterable<Equipment> initial = const []])
    : favorites = [...initial];

  @override
  Stream<List<Equipment>> watchFavorites(String userId) {
    scheduleMicrotask(() {
      if (!_controller.isClosed) {
        _controller.add(List.unmodifiable(favorites));
      }
    });
    return _controller.stream;
  }

  @override
  Future<void> addFavorite({
    required String userId,
    required Equipment equipment,
  }) async {
    if (error != null) throw error!;
    favorites.removeWhere((item) => item.id == equipment.id);
    favorites.insert(0, equipment);
    _controller.add(List.unmodifiable(favorites));
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String equipmentId,
  }) async {
    if (error != null) throw error!;
    favorites.removeWhere((item) => item.id == equipmentId);
    _controller.add(List.unmodifiable(favorites));
  }

  Future<void> close() => _controller.close();
}

class FakeWalletRepository implements WalletRepository {
  final _walletController = StreamController<WalletAccount>.broadcast(
    sync: true,
  );
  final _activityController = StreamController<List<WalletActivity>>.broadcast(
    sync: true,
  );

  WalletAccount wallet;
  List<WalletActivity> activities;
  Object? error;
  Completer<void>? topUpCompleter;
  var ensureCalls = 0;

  FakeWalletRepository({
    this.wallet = const WalletAccount(userId: 'farmer-1', balance: 1000000),
    this.activities = const [],
  });

  @override
  Future<void> ensureWallet(String userId) async {
    ensureCalls++;
    if (error != null) throw error!;
  }

  @override
  Stream<WalletAccount> watchWallet(String userId) {
    scheduleMicrotask(() {
      if (!_walletController.isClosed) _walletController.add(wallet);
    });
    return _walletController.stream;
  }

  @override
  Stream<List<WalletActivity>> watchActivities(String userId) {
    scheduleMicrotask(() {
      if (!_activityController.isClosed) {
        _activityController.add(List.unmodifiable(activities));
      }
    });
    return _activityController.stream;
  }

  @override
  Future<void> topUp({required String userId, required double amount}) async {
    if (error != null) throw error!;
    if (topUpCompleter != null) await topUpCompleter!.future;
    wallet = WalletAccount(userId: userId, balance: wallet.balance + amount);
    activities = [
      WalletActivity(
        id: 'top-up-${activities.length + 1}',
        type: WalletActivityType.topUp,
        amount: amount,
        balanceAfter: wallet.balance,
        title: 'Wallet top-up',
        createdAt: DateTime(2026, 7, 29),
      ),
      ...activities,
    ];
    _walletController.add(wallet);
    _activityController.add(List.unmodifiable(activities));
  }

  void emitWallet(WalletAccount value) {
    wallet = value;
    _walletController.add(value);
  }

  Future<void> close() async {
    await _walletController.close();
    await _activityController.close();
  }
}
