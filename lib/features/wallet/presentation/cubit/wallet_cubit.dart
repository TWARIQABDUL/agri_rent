import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletState extends Equatable {
  final WalletAccount? wallet;
  final List<WalletActivity> activities;
  final bool isLoading;
  final bool isProcessing;
  final String? error;

  const WalletState({
    this.wallet,
    this.activities = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
  });

  double get balance => wallet?.balance ?? 0;

  WalletState copyWith({
    WalletAccount? wallet,
    List<WalletActivity>? activities,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    bool clearError = false,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    wallet,
    activities,
    isLoading,
    isProcessing,
    error,
  ];
}

@injectable
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository;

  StreamSubscription<WalletAccount>? _walletSubscription;
  StreamSubscription<List<WalletActivity>>? _activitySubscription;
  String? _userId;

  WalletCubit(this.repository) : super(const WalletState());

  void watch(String userId) {
    if (_userId == userId && _walletSubscription != null) return;
    _userId = userId;
    emit(state.copyWith(isLoading: true, clearError: true));
    unawaited(_start(userId));
  }

  Future<void> _start(String userId) async {
    await _walletSubscription?.cancel();
    await _activitySubscription?.cancel();
    try {
      await repository.ensureWallet(userId);
      if (_userId != userId) return;
      _walletSubscription = repository
          .watchWallet(userId)
          .listen(
            (wallet) => emit(
              state.copyWith(
                wallet: wallet,
                isLoading: false,
                clearError: true,
              ),
            ),
            onError: _onError,
          );
      _activitySubscription = repository
          .watchActivities(userId)
          .listen(
            (activities) =>
                emit(state.copyWith(activities: activities, clearError: true)),
            onError: _onError,
          );
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(Object error, [StackTrace? stackTrace]) {
    emit(
      state.copyWith(
        isLoading: false,
        isProcessing: false,
        error: error.toString(),
      ),
    );
  }

  Future<void> topUp(double amount) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('Sign in before topping up a wallet.');
    }
    emit(state.copyWith(isProcessing: true, clearError: true));
    try {
      await repository.topUp(userId: userId, amount: amount);
      emit(state.copyWith(isProcessing: false, clearError: true));
    } catch (error) {
      _onError(error);
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _walletSubscription?.cancel();
    await _activitySubscription?.cancel();
    return super.close();
  }
}
