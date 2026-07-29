import 'package:equatable/equatable.dart';

class WalletAccount extends Equatable {
  final String userId;
  final double balance;
  final String currency;

  const WalletAccount({
    required this.userId,
    required this.balance,
    this.currency = 'RWF',
  });

  factory WalletAccount.empty(String userId) =>
      WalletAccount(userId: userId, balance: 0);

  @override
  List<Object?> get props => [userId, balance, currency];
}

abstract class WalletActivityType {
  static const topUp = 'topUp';
  static const rentalPayment = 'rentalPayment';
}

class WalletActivity extends Equatable {
  final String id;
  final String type;
  final double amount;
  final double balanceAfter;
  final String title;
  final String? rentalId;
  final DateTime createdAt;

  const WalletActivity({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.title,
    required this.createdAt,
    this.rentalId,
  });

  bool get isCredit => amount >= 0;

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    balanceAfter,
    title,
    rentalId,
    createdAt,
  ];
}
