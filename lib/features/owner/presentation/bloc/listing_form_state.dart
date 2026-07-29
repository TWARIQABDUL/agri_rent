part of 'listing_form_bloc.dart';

enum ListingFormStatus { editing, submitting, success, failure }

class ListingFormState extends Equatable {
  static const int stepCount = 3;
  static const int lastStepIndex = stepCount - 1;

  final ListingDraft draft;
  final int step;

  /// Errors stay hidden until the owner tries to move on, so a fresh step does
  /// not open covered in red.
  final bool showStepErrors;

  final ListingFormStatus status;
  final String? errorMessage;

  /// Set when the form was opened on an existing listing.
  final String? listingId;

  const ListingFormState({
    this.draft = const ListingDraft(),
    this.step = 0,
    this.showStepErrors = false,
    this.status = ListingFormStatus.editing,
    this.errorMessage,
    this.listingId,
  });

  bool get isEditing => listingId != null;

  bool get isFirstStep => step == 0;

  bool get isLastStep => step == lastStepIndex;

  bool get isSubmitting => status == ListingFormStatus.submitting;

  bool get isCurrentStepComplete => switch (step) {
    0 => draft.hasIdentity,
    1 => draft.hasTerms,
    _ => draft.hasDetails,
  };

  ListingFormState copyWith({
    ListingDraft? draft,
    int? step,
    bool? showStepErrors,
    ListingFormStatus? status,
    String? errorMessage,
    String? listingId,
    bool clearError = false,
  }) {
    return ListingFormState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      showStepErrors: showStepErrors ?? this.showStepErrors,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      listingId: listingId ?? this.listingId,
    );
  }

  @override
  List<Object?> get props => [
    draft,
    step,
    showStepErrors,
    status,
    errorMessage,
    listingId,
  ];
}
