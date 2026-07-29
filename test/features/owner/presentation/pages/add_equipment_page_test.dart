import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/owner/domain/entities/listing_draft.dart';
import 'package:agri_rent/features/owner/domain/entities/owner_summary.dart';
import 'package:agri_rent/features/owner/domain/repositories/owner_repository.dart';
import 'package:agri_rent/features/owner/domain/usecases/publish_listing.dart';
import 'package:agri_rent/features/owner/domain/usecases/update_listing.dart';
import 'package:agri_rent/features/owner/presentation/bloc/listing_form_bloc.dart';
import 'package:agri_rent/features/owner/presentation/pages/add_equipment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the form asked the domain to write, so the assertions can be
/// about the payload rather than about Firestore.
class _RecordingOwnerRepository implements OwnerRepository {
  ListingDraft? publishedDraft;
  String? publishedOwnerId;

  @override
  Future<String> publishListing({
    required String ownerId,
    required ListingDraft draft,
  }) async {
    publishedOwnerId = ownerId;
    publishedDraft = draft;
    return 'listing-1';
  }

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  }) async {}

  @override
  Future<List<Equipment>> getListings(String ownerId) async => [];

  @override
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  }) async {}

  @override
  Future<OwnerSummary> getSummary(String ownerId) async => const OwnerSummary();

  @override
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  }) async {}
}

void main() {
  const ownerId = 'owner-1';
  const description =
      'Serviced 50 hp tractor with plough and trailer included in the rate.';

  late _RecordingOwnerRepository repository;
  late ListingFormBloc bloc;

  /// Built inside the test body on purpose. A bloc constructed in `setUp`
  /// belongs to the zone outside the widget test's fake clock, and its state
  /// stream then never reaches the widgets under test.
  void createBloc() {
    repository = _RecordingOwnerRepository();
    bloc = ListingFormBloc(
      PublishListing(repository),
      UpdateListing(repository),
    );
    addTearDown(bloc.close);
  }

  /// Mirrors how the app opens the wizard: the bloc is provided inside the
  /// pushed route, and the route underneath gives the form somewhere to pop
  /// back to once it saves.
  Widget makeTestable() {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider<ListingFormBloc>.value(
                    value: bloc,
                    child: const AddEquipmentPage(ownerId: ownerId),
                  ),
                ),
              ),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );
  }

  /// The wizard is laid out for a phone; on the 800x600 default test surface its
  /// footer falls off screen and taps on the primary button miss.
  Future<void> openForm(WidgetTester tester) async {
    createBloc();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(makeTestable());
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
  }

  Future<void> tapPrimary(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(ElevatedButton, label));
    await tester.pumpAndSettle();
  }

  Future<void> pickCategory(WidgetTester tester, String label) async {
    final chip = find.text(label);
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, Finder field, String value) async {
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  group('AddEquipmentPage', () {
    testWidgets('publishes the draft collected across the three steps', (
      WidgetTester tester,
    ) async {
      await openForm(tester);

      // Step one: what the machine is.
      await fill(tester, find.byType(TextField), 'John Deere 5050D');
      await pickCategory(tester, 'Tractor');
      await tapPrimary(tester, 'Continue');

      // Step two: daily rate, optional monthly rate, and location.
      expect(find.text('Step 2 of 3 · Rate & location'), findsOneWidget);
      final terms = find.byType(TextField);
      await fill(tester, terms.at(0), '25000');
      await fill(tester, terms.at(1), '450000');
      await fill(tester, terms.at(2), 'Musanze');
      await tapPrimary(tester, 'Continue');

      // Step three: the description farmers read.
      expect(find.text('Step 3 of 3 · Details'), findsOneWidget);
      await fill(tester, find.byType(TextField), description);
      await tapPrimary(tester, 'Publish Listing');

      final published = repository.publishedDraft;
      expect(published, isNotNull);
      expect(repository.publishedOwnerId, ownerId);
      expect(published!.name, 'John Deere 5050D');
      expect(published.category, 'Tractors');
      expect(published.pricePerDay, 25000);
      expect(published.pricePerMonth, 450000);
      expect(published.location, 'Musanze');
      expect(published.description, description);

      // The wizard closes itself once the write lands.
      expect(find.text('Open form'), findsOneWidget);
    });

    testWidgets('stays on a step until its required fields are filled', (
      WidgetTester tester,
    ) async {
      await openForm(tester);
      await tapPrimary(tester, 'Continue');

      expect(
        find.text('Give the machine a name farmers will recognise.'),
        findsOneWidget,
      );
      expect(
        find.text('Pick the category this machine belongs to.'),
        findsOneWidget,
      );
      expect(find.text('Step 1 of 3 · Basics'), findsOneWidget);
      expect(repository.publishedDraft, isNull);
    });

    testWidgets('rejects a description that is too short to be useful', (
      WidgetTester tester,
    ) async {
      await openForm(tester);

      await fill(tester, find.byType(TextField), 'Irrigation Pump X2');
      await pickCategory(tester, 'Pump');
      await tapPrimary(tester, 'Continue');

      final terms = find.byType(TextField);
      await fill(tester, terms.at(0), '8000');
      await fill(tester, terms.at(2), 'Musanze');
      await tapPrimary(tester, 'Continue');

      await fill(tester, find.byType(TextField), 'Good pump');
      await tapPrimary(tester, 'Publish Listing');

      expect(find.textContaining('Add at least 20 characters'), findsOneWidget);
      expect(repository.publishedDraft, isNull);
    });
  });
}
