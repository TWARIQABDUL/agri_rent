import 'package:equatable/equatable.dart';

import '../../../equipment/domain/entities/equipment.dart';
import 'owner_rental.dart';

/// Where an owner's money currently sits.
class EarningsBreakdown extends Equatable {
  /// Completed rentals that have not been paid out yet.
  final double availableForPayout;

  /// Money committed by accepted or running rentals, not yet earned.
  final double pendingClearance;

  /// Everything ever earned, paid out or not.
  final double lifetime;

  const EarningsBreakdown({
    this.availableForPayout = 0,
    this.pendingClearance = 0,
    this.lifetime = 0,
  });

  @override
  List<Object?> get props => [availableForPayout, pendingClearance, lifetime];
}

/// The read model behind the owner dashboard and the earnings screen.
///
/// One fetch feeds both screens: the dashboard shows the counters and the
/// running rentals, earnings shows the money and the activity trail.
class OwnerSummary extends Equatable {
  final EarningsBreakdown earnings;
  final int listedCount;
  final int pausedCount;
  final int pendingRequestCount;

  /// Rentals that are out with a farmer right now, soonest return first.
  final List<OwnerRental> activeRentals;

  /// Latest movements on the account, newest first.
  final List<OwnerRental> recentActivity;

  const OwnerSummary({
    this.earnings = const EarningsBreakdown(),
    this.listedCount = 0,
    this.pausedCount = 0,
    this.pendingRequestCount = 0,
    this.activeRentals = const [],
    this.recentActivity = const [],
  });

  /// Projects the owner's raw rentals and listings into the numbers the
  /// dashboard shows. Kept here rather than in the repository so the rules for
  /// what counts as earned money live with the domain and stay testable.
  factory OwnerSummary.from({
    required List<OwnerRental> rentals,
    required List<Equipment> listings,
    int recentActivityLimit = 8,
  }) {
    final completed = rentals.where((r) => r.isCompleted);
    final inFlight = rentals.where(
      (r) => RentalStatus.inFlight.contains(r.status),
    );

    double total(Iterable<OwnerRental> source) =>
        source.fold(0, (sum, rental) => sum + rental.amount);

    final active = rentals.where((r) => r.isActive).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));

    final activity = rentals.where((r) => r.isCompleted || r.isActive).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return OwnerSummary(
      earnings: EarningsBreakdown(
        availableForPayout: total(completed.where((r) => !r.paidOut)),
        pendingClearance: total(inFlight),
        lifetime: total(completed),
      ),
      listedCount: listings.where((e) => !e.isPaused).length,
      pausedCount: listings.where((e) => e.isPaused).length,
      pendingRequestCount: rentals.where((r) => r.isPending).length,
      activeRentals: active,
      recentActivity: activity.take(recentActivityLimit).toList(),
    );
  }

  int get activeRentalCount => activeRentals.length;

  int get totalListingCount => listedCount + pausedCount;

  @override
  List<Object?> get props => [
    earnings,
    listedCount,
    pausedCount,
    pendingRequestCount,
    activeRentals,
    recentActivity,
  ];
}
