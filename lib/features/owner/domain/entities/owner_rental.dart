import 'package:equatable/equatable.dart';

/// Lifecycle of a booking as stored in the `status` field of `rentals`.
class RentalStatus {
  const RentalStatus._();

  /// Farmer asked, owner has not answered yet.
  static const String pending = 'pending';

  /// Owner said yes, the rental has not started.
  static const String accepted = 'accepted';

  /// Equipment is out with the farmer right now.
  static const String active = 'active';

  /// Equipment came back and the money is earned.
  static const String completed = 'completed';

  static const String declined = 'declined';
  static const String cancelled = 'cancelled';

  /// Statuses that hold money the owner has not cleared yet.
  static const List<String> inFlight = [accepted, active];
}

/// A booking on one of the owner's machines, from the owner's side of the deal.
class OwnerRental extends Equatable {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String renterName;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final String status;

  /// True once the money has been paid out to the owner's bank.
  final bool paidOut;

  /// Last write to the rental document, treated as the movement timestamp for
  /// activity sorting. Firestore enforces it on every status change.
  final DateTime updatedAt;

  const OwnerRental({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.renterName,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.status,
    required this.updatedAt,
    this.paidOut = false,
  });

  /// Inclusive of both the pick-up and the return day, which is how the rate
  /// is quoted to the farmer.
  int get days => endDate.difference(startDate).inDays + 1;

  bool get isActive => status == RentalStatus.active;

  bool get isPending => status == RentalStatus.pending;

  bool get isCompleted => status == RentalStatus.completed;

  @override
  List<Object?> get props => [
    id,
    equipmentId,
    equipmentName,
    renterName,
    startDate,
    endDate,
    amount,
    status,
    paidOut,
    updatedAt,
  ];
}
