part of 'listing_form_bloc.dart';

abstract class ListingFormEvent extends Equatable {
  const ListingFormEvent();

  @override
  List<Object?> get props => [];
}

/// Opens the form empty, or loaded with [existing] when editing a listing.
class ListingFormStarted extends ListingFormEvent {
  final Equipment? existing;

  const ListingFormStarted({this.existing});

  @override
  List<Object?> get props => [existing];
}

class ListingDraftChanged extends ListingFormEvent {
  final ListingDraft draft;

  const ListingDraftChanged(this.draft);

  @override
  List<Object?> get props => [draft];
}

class ListingStepAdvanced extends ListingFormEvent {
  const ListingStepAdvanced();
}

class ListingStepReversed extends ListingFormEvent {
  const ListingStepReversed();
}

class ListingSubmitted extends ListingFormEvent {
  final String ownerId;

  const ListingSubmitted(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}
