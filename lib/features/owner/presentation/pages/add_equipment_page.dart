import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/equipment_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../../injection_container.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/entities/listing_draft.dart';
import '../bloc/listing_form_bloc.dart';
import '../widgets/listing_form_fields.dart';
import '../widgets/owner_buttons.dart';
import '../widgets/owner_card.dart';

/// Add New Equipment, split into three steps: what the machine is, what it
/// costs, and how it is described.
///
/// The same page edits an existing listing; only the wording and the write it
/// performs change.
class AddEquipmentPage extends StatefulWidget {
  final String ownerId;

  /// Present when editing rather than publishing.
  final Equipment? listing;

  const AddEquipmentPage({super.key, required this.ownerId, this.listing});

  static const List<String> stepTitles = [
    'Basics',
    'Rate & location',
    'Details',
  ];

  /// Opens the wizard with its own bloc. Resolves to true when a listing was
  /// written, so the caller knows to refresh.
  static Future<bool?> push(
    BuildContext context, {
    required String ownerId,
    Equipment? listing,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ListingFormBloc>(),
          child: AddEquipmentPage(ownerId: ownerId, listing: listing),
        ),
      ),
    );
  }

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  late final TextEditingController _name;
  late final TextEditingController _dailyRate;
  late final TextEditingController _monthlyRate;
  late final TextEditingController _location;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    final draft = listing == null
        ? const ListingDraft()
        : ListingDraft.fromEquipment(listing);

    _name = TextEditingController(text: draft.name);
    _dailyRate = TextEditingController(text: _rateText(draft.pricePerDay));
    _monthlyRate = TextEditingController(text: _rateText(draft.pricePerMonth));
    _location = TextEditingController(text: draft.location);
    _description = TextEditingController(text: draft.description);

    context.read<ListingFormBloc>().add(ListingFormStarted(existing: listing));
  }

  @override
  void dispose() {
    _name.dispose();
    _dailyRate.dispose();
    _monthlyRate.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  static String _rateText(double value) =>
      value <= 0 ? '' : value.round().toString();

  static double _parseRate(String raw) =>
      double.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  ListingFormBloc get _bloc => context.read<ListingFormBloc>();

  void _change(ListingDraft draft) => _bloc.add(ListingDraftChanged(draft));

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingFormBloc, ListingFormState>(
      listener: _onStateChange,
      child: BlocBuilder<ListingFormBloc, ListingFormState>(
        builder: (context, state) {
          // Guard: once the form is submitting or done the controllers must not
          // be touched.  The listener handles navigation / errors at that point.
          if (state.isSubmitting || state.status == ListingFormStatus.success) {
            return Scaffold(
              backgroundColor: AppColors.white,
              appBar: _appBar(state),
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: _appBar(state),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: StepIndicator(
                      currentStep: state.step,
                      stepCount: ListingFormState.stepCount,
                      stepTitle: AddEquipmentPage.stepTitles[state.step],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: _stepContent(state),
                    ),
                  ),
                  _footer(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onStateChange(BuildContext context, ListingFormState state) {
    if (state.status == ListingFormStatus.success) {
      Navigator.of(context).pop(true);
      return;
    }
    if (state.status == ListingFormStatus.failure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  AppBar _appBar(ListingFormState state) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.ink,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: InkWell(
          onTap: _handleBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left, size: 24),
          ),
        ),
      ),
      title: Text(
        state.isEditing ? 'Edit Listing' : 'Add New Equipment',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      centerTitle: false,
      titleSpacing: 4,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.outline),
      ),
    );
  }

  /// Back walks the wizard before it leaves the page, so a half-filled form is
  /// never lost to a single tap.
  void _handleBack() {
    final state = _bloc.state;
    if (state.isSubmitting) return;
    if (!state.isFirstStep) {
      _bloc.add(const ListingStepReversed());
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _stepContent(ListingFormState state) {
    return switch (state.step) {
      0 => _identityStep(state),
      1 => _termsStep(state),
      _ => _detailsStep(state),
    };
  }

  Widget _identityStep(ListingFormState state) {
    final draft = state.draft;
    final nameMissing = state.showStepErrors && draft.name.trim().isEmpty;
    final categoryMissing = state.showStepErrors && draft.category.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel(
          'Photo',
          hint: 'Optional, but listings with one book faster',
        ),
        const SizedBox(height: 10),
        PhotoLinkBox(
          imageUrl: draft.imageUrl,
          onTap: () => _editPhotoLink(draft),
          onClear: () => _change(draft.copyWith(imageUrl: '')),
        ),
        const SizedBox(height: 24),
        const FieldLabel('Equipment name'),
        const SizedBox(height: 10),
        OwnerTextField(
          controller: _name,
          hintText: 'e.g. John Deere 5050D',
          errorText: nameMissing
              ? 'Give the machine a name farmers will recognise.'
              : null,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => _change(draft.copyWith(name: value)),
        ),
        const SizedBox(height: 24),
        const FieldLabel('Category'),
        const SizedBox(height: 12),
        CategorySelector(
          selectedValue: draft.category,
          onSelected: (value) => _change(draft.copyWith(category: value)),
        ),
        if (categoryMissing) ...[
          const SizedBox(height: 10),
          const _InlineError('Pick the category this machine belongs to.'),
        ],
      ],
    );
  }

  Widget _termsStep(ListingFormState state) {
    final draft = state.draft;
    final rateMissing = state.showStepErrors && draft.pricePerDay <= 0;
    final locationMissing =
        state.showStepErrors && draft.location.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel('Daily rate'),
        const SizedBox(height: 10),
        RateField(
          controller: _dailyRate,
          errorText: rateMissing ? 'Set a daily rate above zero.' : null,
          onChanged: (value) =>
              _change(draft.copyWith(pricePerDay: _parseRate(value))),
        ),
        const SizedBox(height: 24),
        const FieldLabel(
          'Monthly rate',
          hint: 'Optional. Leave empty if you only rent by the day',
        ),
        const SizedBox(height: 10),
        RateField(
          controller: _monthlyRate,
          unitLabel: '/ month',
          onChanged: (value) =>
              _change(draft.copyWith(pricePerMonth: _parseRate(value))),
        ),
        const SizedBox(height: 24),
        const FieldLabel('Location'),
        const SizedBox(height: 10),
        OwnerTextField(
          controller: _location,
          hintText: 'e.g. Musanze, Northern Province',
          errorText: locationMissing
              ? 'Tell farmers where the machine is.'
              : null,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) => _change(draft.copyWith(location: value)),
        ),
      ],
    );
  }

  Widget _detailsStep(ListingFormState state) {
    final draft = state.draft;
    final length = draft.description.trim().length;
    final tooShort = state.showStepErrors && !draft.hasDetails;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel('Description'),
        const SizedBox(height: 10),
        OwnerTextField(
          controller: _description,
          hintText:
              "Tell renters about the condition, capacity, and what's "
              'included...',
          maxLines: 5,
          errorText: tooShort
              ? 'Add at least ${ListingDraft.minDescriptionLength} characters '
                    'so farmers know what they are getting.'
              : null,
          onChanged: (value) => _change(draft.copyWith(description: value)),
        ),
        const SizedBox(height: 8),
        Text(
          '$length / ${ListingDraft.minDescriptionLength} characters',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            color: draft.hasDetails ? AppColors.green : AppColors.muted,
          ),
        ),
        const SizedBox(height: 24),
        const FieldLabel('Review'),
        const SizedBox(height: 10),
        _reviewCard(draft),
      ],
    );
  }

  Widget _reviewCard(ListingDraft draft) {
    return OwnerCard(
      child: Column(
        children: [
          _reviewRow('Machine', draft.name.isEmpty ? 'Not set' : draft.name),
          _reviewRow(
            'Category',
            draft.category.isEmpty
                ? 'Not set'
                : EquipmentCategory.labelFor(draft.category),
          ),
          _reviewRow('Daily rate', Money.format(draft.pricePerDay)),
          if (draft.pricePerMonth > 0)
            _reviewRow('Monthly rate', Money.format(draft.pricePerMonth)),
          _reviewRow(
            'Location',
            draft.location.isEmpty ? 'Not set' : draft.location,
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(ListingFormState state) {
    final primaryLabel = state.isLastStep
        ? (state.isEditing ? 'Save Changes' : 'Publish Listing')
        : 'Continue';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Row(
        children: [
          if (!state.isFirstStep) ...[
            Expanded(
              child: OwnerSecondaryButton(
                label: 'Back',
                height: 54,
                onPressed: state.isSubmitting
                    ? null
                    : () => _bloc.add(const ListingStepReversed()),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: OwnerPrimaryButton(
              label: primaryLabel,
              busy: state.isSubmitting,
              // Stays tappable while muted: the tap is what reveals which
              // fields are still missing.
              inactive: !state.isCurrentStepComplete,
              onPressed: () => _bloc.add(
                state.isLastStep
                    ? ListingSubmitted(widget.ownerId)
                    : const ListingStepAdvanced(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPhotoLink(ListingDraft draft) async {
    final controller = TextEditingController(text: draft.imageUrl);
    final link = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          22,
          20,
          22 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FieldLabel(
              'Photo link',
              hint: 'Uploading from the gallery arrives with storage support',
            ),
            const SizedBox(height: 12),
            OwnerTextField(
              controller: controller,
              hintText: 'https://...',
              keyboardType: TextInputType.url,
              textCapitalization: TextCapitalization.none,
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            OwnerPrimaryButton(
              label: 'Use this photo',
              onPressed: () =>
                  Navigator.of(sheetContext).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
    );

    controller.dispose();
    if (link == null || !mounted) return;
    _change(draft.copyWith(imageUrl: link));
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(fontSize: 12.5, color: AppColors.danger),
    );
  }
}
