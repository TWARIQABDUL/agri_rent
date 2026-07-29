import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/wallet.dart';

class WalletAccountModel extends WalletAccount {
  const WalletAccountModel({
    required super.userId,
    required super.balance,
    super.currency,
  });

  factory WalletAccountModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return WalletAccountModel(
      userId: data['userId'] ?? snapshot.id,
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] ?? 'RWF',
    );
  }
}

class WalletActivityModel extends WalletActivity {
  const WalletActivityModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.balanceAfter,
    required super.title,
    required super.createdAt,
    super.rentalId,
  });

  factory WalletActivityModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    return WalletActivityModel(
      id: snapshot.id,
      type: data['type'] ?? WalletActivityType.topUp,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (data['balanceAfter'] as num?)?.toDouble() ?? 0,
      title: data['title'] ?? 'Wallet activity',
      rentalId: data['rentalId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }
}
