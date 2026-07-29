import 'package:injectable/injectable.dart';

import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> ensureWallet(String userId) =>
      remoteDataSource.ensureWallet(userId);

  @override
  Stream<WalletAccount> watchWallet(String userId) =>
      remoteDataSource.watchWallet(userId);

  @override
  Stream<List<WalletActivity>> watchActivities(String userId) =>
      remoteDataSource.watchActivities(userId);

  @override
  Future<void> topUp({required String userId, required double amount}) =>
      remoteDataSource.topUp(userId: userId, amount: amount);
}
