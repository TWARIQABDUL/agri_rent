part of 'owner_dashboard_bloc.dart';

abstract class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnerDashboard extends OwnerDashboardEvent {
  final String ownerId;
  final String? displayName;
  final String? email;

  /// Refreshes without flashing the loading state, used for pull to refresh.
  final bool silent;

  const LoadOwnerDashboard({
    required this.ownerId,
    this.displayName,
    this.email,
    this.silent = false,
  });

  @override
  List<Object?> get props => [ownerId, displayName, email, silent];
}
