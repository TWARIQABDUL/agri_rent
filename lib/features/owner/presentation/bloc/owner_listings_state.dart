part of 'owner_listings_bloc.dart';

abstract class OwnerListingsState extends Equatable {
  const OwnerListingsState();

  @override
  List<Object?> get props => [];
}

class OwnerListingsInitial extends OwnerListingsState {}

class OwnerListingsLoading extends OwnerListingsState {}

class OwnerListingsLoaded extends OwnerListingsState {
  final List<Equipment> listings;

  /// The listing currently being written, if any.
  final String? busyListingId;

  /// Set when a write failed while the shelf itself is still valid.
  final String? failureMessage;

  const OwnerListingsLoaded(
    this.listings, {
    this.busyListingId,
    this.failureMessage,
  });

  bool get isEmpty => listings.isEmpty;

  List<Equipment> get listed => listings.where((e) => !e.isPaused).toList();

  List<Equipment> get paused => listings.where((e) => e.isPaused).toList();

  @override
  List<Object?> get props => [listings, busyListingId, failureMessage];
}

class OwnerListingsError extends OwnerListingsState {
  final String message;

  const OwnerListingsError(this.message);

  @override
  List<Object?> get props => [message];
}
