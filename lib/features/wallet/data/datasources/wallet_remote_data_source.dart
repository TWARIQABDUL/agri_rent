import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/wallet.dart';
import '../models/wallet_models.dart';

abstract class WalletRemoteDataSource {
  Future<void> ensureWallet(String userId);

  Stream<WalletAccountModel> watchWallet(String userId);

  Stream<List<WalletActivityModel>> watchActivities(String userId);

  Future<void> topUp({required String userId, required double amount});
}

@LazySingleton(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final FirebaseFirestore firestore;

  WalletRemoteDataSourceImpl(this.firestore);

  DocumentReference<Map<String, dynamic>> _wallet(String userId) =>
      firestore.collection('wallets').doc(userId);

  @override
  Future<void> ensureWallet(String userId) async {
    final reference = _wallet(userId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.exists) return;
      transaction.set(reference, {
        'userId': userId,
        'balance': 0,
        'currency': 'RWF',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<WalletAccountModel> watchWallet(String userId) {
    return _wallet(userId).snapshots().map(WalletAccountModel.fromFirestore);
  }

  @override
  Stream<List<WalletActivityModel>> watchActivities(String userId) {
    return _wallet(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(WalletActivityModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Future<void> topUp({required String userId, required double amount}) async {
    if (amount <= 0 || amount > 10000000) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Top-up must be between RWF 1 and RWF 10,000,000.',
      );
    }

    final wallet = _wallet(userId);
    final activity = wallet.collection('transactions').doc();
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(wallet);
      if (!snapshot.exists) {
        throw StateError('Wallet is not ready. Please try again.');
      }

      final current = (snapshot.data()?['balance'] as num?)?.toDouble() ?? 0;
      final updated = current + amount;
      transaction.update(wallet, {
        'balance': updated,
        'lastTransactionId': activity.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(activity, {
        'userId': userId,
        'type': WalletActivityType.topUp,
        'amount': amount,
        'balanceAfter': updated,
        'title': 'Wallet top-up',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
