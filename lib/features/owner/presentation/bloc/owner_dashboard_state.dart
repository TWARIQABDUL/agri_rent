part of 'owner_dashboard_bloc.dart';

abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {}

class OwnerDashboardLoading extends OwnerDashboardState {}

class OwnerDashboardLoaded extends OwnerDashboardState {
  final OwnerSummary summary;

  /// Set when a silent refresh failed while the previous summary is still on
  /// screen.  The UI shows it as a snackbar rather than a blocking error.
  final String? failureMessage;

  const OwnerDashboardLoaded(this.summary, {this.failureMessage});

  @override
  List<Object?> get props => [summary, failureMessage];
}

class OwnerDashboardError extends OwnerDashboardState {
  final String message;

  const OwnerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
