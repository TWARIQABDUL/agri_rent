/// Cleared earnings leave for the owner's bank on the 5th of every month.
class PayoutSchedule {
  const PayoutSchedule._();

  static const int payoutDayOfMonth = 5;

  /// The next payout date strictly after [from].
  static DateTime nextPayoutAfter(DateTime from) {
    if (from.day < payoutDayOfMonth) {
      return DateTime(from.year, from.month, payoutDayOfMonth);
    }
    return DateTime(from.year, from.month + 1, payoutDayOfMonth);
  }
}
