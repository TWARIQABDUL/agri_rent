import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/usecases/get_owner_listings.dart';
import '../../domain/usecases/set_listing_paused.dart';

part 'owner_listings_event.dart';
part 'owner_listings_state.dart';

@injectable
class OwnerListingsBloc extends Bloc<OwnerListingsEvent, OwnerListingsState> {
  final GetOwnerListings getOwnerListings;
  final SetListingPaused setListingPaused;

  OwnerListingsBloc(this.getOwnerListings, this.setListingPaused)
    : super(OwnerListingsInitial()) {
    on<LoadOwnerListings>(_onLoad);
    on<ListingPauseToggled>(_onPauseToggled);
  }

  Future<void> _onLoad(
    LoadOwnerListings event,
    Emitter<OwnerListingsState> emit,
  ) async {
    if (!event.silent) emit(OwnerListingsLoading());
    try {
      final listings = await getOwnerListings(event.ownerId);
      emit(OwnerListingsLoaded(listings));
    } catch (error) {
      emit(OwnerListingsError(error.toString()));
    }
  }

  /// Keeps the shelf on screen while one card works, so pausing a listing does
  /// not blank the whole page.
  Future<void> _onPauseToggled(
    ListingPauseToggled event,
    Emitter<OwnerListingsState> emit,
  ) async {
    final current = state;
    if (current is! OwnerListingsLoaded) return;

    emit(
      OwnerListingsLoaded(current.listings, busyListingId: event.listing.id),
    );
    try {
      await setListingPaused(
        SetListingPausedParams(
          listingId: event.listing.id,
          paused: !event.listing.isPaused,
        ),
      );
      add(LoadOwnerListings(event.ownerId, silent: true));
    } catch (error) {
      emit(
        OwnerListingsLoaded(current.listings, failureMessage: error.toString()),
      );
    }
  }
}
