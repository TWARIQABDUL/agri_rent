import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/owner/domain/entities/listing_draft.dart';
import 'package:agri_rent/features/owner/domain/entities/owner_rental.dart';
import 'package:agri_rent/features/owner/domain/entities/owner_summary.dart';
import 'package:agri_rent/features/owner/domain/repositories/owner_repository.dart';
import 'package:agri_rent/features/owner/domain/usecases/ensure_owner_profile.dart';
import 'package:agri_rent/features/owner/domain/usecases/get_owner_listings.dart';
import 'package:agri_rent/features/owner/domain/usecases/get_owner_summary.dart';
import 'package:agri_rent/features/owner/domain/usecases/set_listing_paused.dart';
import 'package:agri_rent/features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:agri_rent/features/owner/presentation/bloc/owner_listings_bloc.dart';
import 'package:agri_rent/features/owner/presentation/pages/earnings_page.dart';
import 'package:agri_rent/features/owner/presentation/pages/my_listings_page.dart';
import 'package:agri_rent/features/owner/presentation/pages/owner_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const activeListing = Equipment(
  id: 'equipment-1',
  name: 'John Deere 5050D',
  ownerId: 'owner-1',
  description: 'A reliable tractor with enough detail for farmers to decide.',
  pricePerDay: 25000,
  pricePerMonth: 500000,
  status: EquipmentStatus.available,
  category: 'Tractors',
  image: '',
  location: 'Musanze',
  rating: 4.8,
  bookingCount: 7,
);

const pausedListing = Equipment(
  id: 'equipment-2',
  name: 'Irrigation Pump X2',
  ownerId: 'owner-1',
  description: 'A portable irrigation pump for fields and vegetable gardens.',
  pricePerDay: 12000,
  pricePerMonth: 240000,
  status: EquipmentStatus.paused,
  category: 'Pumps',
  image: '',
  location: 'Rubavu',
  rating: 4.2,
  bookingCount: 3,
);

final activeRental = OwnerRental(
  id: 'rental-1',
  equipmentId: 'equipment-1',
  equipmentName: 'John Deere 5050D',
  renterName: 'Alice Farmer',
  startDate: DateTime(2026, 7, 29),
  endDate: DateTime(2026, 7, 31),
  amount: 52500,
  status: RentalStatus.active,
  updatedAt: DateTime(2026, 7, 29),
);

final completedRental = OwnerRental(
  id: 'rental-2',
  equipmentId: 'equipment-2',
  equipmentName: 'Irrigation Pump X2',
  renterName: 'Jean Farmer',
  startDate: DateTime(2026, 7, 20),
  endDate: DateTime(2026, 7, 21),
  amount: 24000,
  status: RentalStatus.completed,
  updatedAt: DateTime(2026, 7, 22),
);

final pendingRental = OwnerRental(
  id: 'rental-3',
  equipmentId: 'equipment-1',
  equipmentName: 'John Deere 5050D',
  renterName: 'Eric Farmer',
  startDate: DateTime(2026, 8, 2),
  endDate: DateTime(2026, 8, 3),
  amount: 52500,
  status: RentalStatus.pending,
  updatedAt: DateTime(2026, 7, 29),
);

class FakeOwnerRepository implements OwnerRepository {
  List<Equipment> listings = [activeListing, pausedListing];
  late OwnerSummary summary;
  String? pausedListingId;
  bool? pausedValue;
  Object? error;

  FakeOwnerRepository() {
    summary = OwnerSummary.from(
      rentals: [activeRental, completedRental, pendingRental],
      listings: listings,
    );
  }

  @override
  Future<void> ensureOwnerProfile({
    required String ownerId,
    String? displayName,
    String? email,
  }) async {
    if (error != null) throw error!;
  }

  @override
  Future<List<Equipment>> getListings(String ownerId) async {
    if (error != null) throw error!;
    return listings;
  }

  @override
  Future<OwnerSummary> getSummary(String ownerId) async {
    if (error != null) throw error!;
    return summary;
  }

  @override
  Future<String> publishListing({
    required String ownerId,
    required ListingDraft draft,
  }) async {
    if (error != null) throw error!;
    return 'new-listing';
  }

  @override
  Future<void> setListingPaused({
    required String listingId,
    required bool paused,
  }) async {
    if (error != null) throw error!;
    pausedListingId = listingId;
    pausedValue = paused;
  }

  @override
  Future<void> updateListing({
    required String listingId,
    required ListingDraft draft,
  }) async {
    if (error != null) throw error!;
  }
}

void main() {
  late FakeOwnerRepository repository;
  late OwnerDashboardBloc dashboardBloc;
  late OwnerListingsBloc listingsBloc;

  setUp(() async {
    repository = FakeOwnerRepository();
    dashboardBloc = OwnerDashboardBloc(
      GetOwnerSummary(repository),
      EnsureOwnerProfile(repository),
    );
    listingsBloc = OwnerListingsBloc(
      GetOwnerListings(repository),
      SetListingPaused(repository),
    );

    final dashboardLoaded = dashboardBloc.stream.firstWhere(
      (state) => state is OwnerDashboardLoaded,
    );
    dashboardBloc.add(
      const LoadOwnerDashboard(
        ownerId: 'owner-1',
        displayName: 'Patrick Mugisha',
        email: 'patrick@example.com',
      ),
    );
    await dashboardLoaded;

    final listingsLoaded = listingsBloc.stream.firstWhere(
      (state) => state is OwnerListingsLoaded,
    );
    listingsBloc.add(const LoadOwnerListings('owner-1'));
    await listingsLoaded;
  });

  tearDown(() async {
    await dashboardBloc.close();
    await listingsBloc.close();
  });

  Widget app(Widget page) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OwnerDashboardBloc>.value(value: dashboardBloc),
        BlocProvider<OwnerListingsBloc>.value(value: listingsBloc),
      ],
      child: MaterialApp(home: page),
    );
  }

  test('owner summary derives counters, earnings, and activity', () {
    final summary = repository.summary;
    expect(summary.activeRentalCount, 1);
    expect(summary.totalListingCount, 2);
    expect(summary.pendingRequestCount, 1);
    expect(summary.earnings.pendingClearance, 52500);
    expect(summary.earnings.availableForPayout, 24000);
    expect(summary.earnings.lifetime, 24000);
    expect(activeRental.days, 3);
  });

  testWidgets('dashboard renders real owner summary and quick actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    int? openedTab;

    await tester.pumpWidget(
      app(
        OwnerDashboardPage(
          ownerId: 'owner-1',
          ownerName: 'Patrick Mugisha',
          onOpenTab: (index) => openedTab = index,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Patrick Mugisha'), findsOneWidget);
    expect(find.text('John Deere 5050D'), findsOneWidget);
    expect(find.text('New requests'), findsOneWidget);

    await tester.tap(find.text('View earnings'));
    expect(openedTab, 3);
    await tester.tap(find.text('Manage my listings'));
    expect(openedTab, 1);
  });

  testWidgets('listings page renders active and paused cards and pauses', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(const MyListingsPage(ownerId: 'owner-1')));
    await tester.pump();

    expect(find.text('My Listings'), findsOneWidget);
    expect(find.text('John Deere 5050D'), findsOneWidget);
    expect(find.text('Irrigation Pump X2'), findsOneWidget);
    expect(find.text('Listed'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(repository.pausedListingId, 'equipment-1');
    expect(repository.pausedValue, isTrue);
  });

  testWidgets('earnings page renders activity and explains payouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(app(const EarningsPage(ownerId: 'owner-1')));
    await tester.pump();

    expect(find.text('Earnings'), findsOneWidget);
    expect(find.text('Lifetime earnings'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.textContaining('Rental ·'), findsWidgets);

    await tester.tap(find.text('Withdraw to Bank'));
    await tester.pump();
    expect(find.text('Payouts run automatically'), findsOneWidget);
  });

  testWidgets('owner pages expose retry and empty states', (tester) async {
    repository.error = StateError('offline');
    final dashboardError = dashboardBloc.stream.firstWhere(
      (state) => state is OwnerDashboardError,
    );
    dashboardBloc.add(const LoadOwnerDashboard(ownerId: 'owner-1'));
    await tester.runAsync(() => dashboardError);

    await tester.pumpWidget(
      app(
        OwnerDashboardPage(
          ownerId: 'owner-1',
          ownerName: 'Patrick',
          onOpenTab: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('offline'), findsOneWidget);

    repository.error = null;
    repository.listings = const [];
    final listingsLoaded = listingsBloc.stream.firstWhere(
      (state) => state is OwnerListingsLoaded && state.isEmpty,
    );
    listingsBloc.add(const LoadOwnerListings('owner-1'));
    await tester.runAsync(() => listingsLoaded);
    await tester.pumpWidget(app(const MyListingsPage(ownerId: 'owner-1')));
    await tester.pump();
    expect(find.text('Nothing listed yet'), findsOneWidget);
  });
}
