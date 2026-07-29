import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<void> ensureWallet(String userId);

  Stream<WalletAccount> watchWallet(String userId);

  Stream<List<WalletActivity>> watchActivities(String userId);

  Future<void> topUp({required String userId, required double amount});
}
