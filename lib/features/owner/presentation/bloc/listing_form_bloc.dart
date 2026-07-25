import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/entities/listing_draft.dart';
import '../../domain/usecases/publish_listing.dart';
import '../../domain/usecases/update_listing.dart';

part 'listing_form_event.dart';
part 'listing_form_state.dart';

/// Drives the multi-step Add New Equipment form.
///
/// Unlike the other blocs in the app this one carries a single state object:
/// a wizard needs the draft, the step, and the submission outcome visible at
/// the same time, which a set of mutually exclusive states cannot express.
@injectable
class ListingFormBloc extends Bloc<ListingFormEvent, ListingFormState> {
  final PublishListing publishListing;
  final UpdateListing updateListing;

  ListingFormBloc(this.publishListing, this.updateListing)
    : super(const ListingFormState()) {
    on<ListingFormStarted>(_onStarted);
    on<ListingDraftChanged>(_onDraftChanged);
    on<ListingStepAdvanced>(_onStepAdvanced);
    on<ListingStepReversed>(_onStepReversed);
    on<ListingSubmitted>(_onSubmitted);
  }

  void _onStarted(ListingFormStarted event, Emitter<ListingFormState> emit) {
    final existing = event.existing;
    emit(
      ListingFormState(
        draft: existing == null
            ? const ListingDraft()
            : ListingDraft.fromEquipment(existing),
        listingId: existing?.id,
      ),
    );
  }

  void _onDraftChanged(
    ListingDraftChanged event,
    Emitter<ListingFormState> emit,
  ) {
    emit(
      state.copyWith(
        draft: event.draft,
        clearError: true,
        // Editing after a rejected submission puts the form back in hand.
        status: state.status == ListingFormStatus.failure
            ? ListingFormStatus.editing
            : null,
      ),
    );
  }

  void _onStepAdvanced(
    ListingStepAdvanced event,
    Emitter<ListingFormState> emit,
  ) {
    if (!state.isCurrentStepComplete) {
      emit(state.copyWith(showStepErrors: true));
      return;
    }
    if (state.isLastStep) return;
    emit(state.copyWith(step: state.step + 1, showStepErrors: false));
  }

  void _onStepReversed(
    ListingStepReversed event,
    Emitter<ListingFormState> emit,
  ) {
    if (state.isFirstStep) return;
    emit(state.copyWith(step: state.step - 1, showStepErrors: false));
  }

  Future<void> _onSubmitted(
    ListingSubmitted event,
    Emitter<ListingFormState> emit,
  ) async {
    if (state.isSubmitting) return;
    if (!state.draft.isPublishable) {
      emit(state.copyWith(showStepErrors: true));
      return;
    }

    emit(
      state.copyWith(status: ListingFormStatus.submitting, clearError: true),
    );
    try {
      final listingId = state.listingId;
      if (listingId == null) {
        await publishListing(
          PublishListingParams(ownerId: event.ownerId, draft: state.draft),
        );
      } else {
        await updateListing(
          UpdateListingParams(listingId: listingId, draft: state.draft),
        );
      }
      emit(state.copyWith(status: ListingFormStatus.success));
    } catch (error) {
      emit(
        state.copyWith(
          status: ListingFormStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
