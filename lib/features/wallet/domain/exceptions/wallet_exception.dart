class InsufficientWalletBalanceException implements Exception {
  final double amountDue;
  final double availableBalance;

  const InsufficientWalletBalanceException({
    required this.amountDue,
    required this.availableBalance,
  });

  double get shortfall => amountDue - availableBalance;

  @override
  String toString() => 'Your wallet balance is not enough for this booking.';
}
