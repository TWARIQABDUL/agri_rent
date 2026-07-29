part of 'owner_listings_bloc.dart';

abstract class OwnerListingsEvent extends Equatable {
  const OwnerListingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnerListings extends OwnerListingsEvent {
  final String ownerId;

  /// Refreshes without dropping back to the loading state, used after a write.
  final bool silent;

  const LoadOwnerListings(this.ownerId, {this.silent = false});

  @override
  List<Object?> get props => [ownerId, silent];
}

class ListingPauseToggled extends OwnerListingsEvent {
  final String ownerId;
  final Equipment listing;

  const ListingPauseToggled({required this.ownerId, required this.listing});

  @override
  List<Object?> get props => [ownerId, listing];
}
