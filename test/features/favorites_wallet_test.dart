import 'dart:async';

import 'package:agri_rent/features/booking/domain/entities/booking.dart';
import 'package:agri_rent/features/booking/presentation/pages/insufficient_balance_page.dart';
import 'package:agri_rent/features/booking/presentation/pages/payment_success_page.dart';
import 'package:agri_rent/features/equipment/data/models/equipment_model.dart';
import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:agri_rent/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:agri_rent/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:agri_rent/features/favorites/presentation/pages/favorites_page.dart';
import 'package:agri_rent/features/main_shell/farmer_navigation_cubit.dart';
import 'package:agri_rent/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:agri_rent/features/wallet/data/models/wallet_models.dart';
import 'package:agri_rent/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:agri_rent/features/wallet/domain/entities/wallet.dart';
import 'package:agri_rent/features/wallet/domain/exceptions/wallet_exception.dart';
import 'package:agri_rent/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:agri_rent/features/wallet/presentation/pages/top_up_wallet_page.dart';
import 'package:agri_rent/features/wallet/presentation/pages/wallet_page.dart';
import 'package:agri_rent/features/wallet/presentation/pages/wallet_processing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/feature_test_helpers.dart';

const tractor = Equipment(
  id: 'equipment-1',
  name: 'John Deere 5050D',
  ownerId: 'owner-1',
  ownerName: 'Patrick Mugisha',
  description: 'A dependable tractor for ploughing and planting.',
  pricePerDay: 25000,
  pricePerMonth: 500000,
  status: EquipmentStatus.available,
  category: 'Tractors',
  image: '',
  location: 'Musanze',
  rating: 4.8,
);

class FakeFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  final controller = StreamController<List<EquipmentModel>>.broadcast();
  var added = false;
  var removed = false;

  @override
  Stream<List<EquipmentModel>> watchFavorites(String userId) =>
      controller.stream;

  @override
  Future<void> addFavorite({
    required String userId,
    required Equipment equipment,
  }) async {
    added = userId == 'farmer-1' && equipment.id == tractor.id;
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String equipmentId,
  }) async {
    removed = userId == 'farmer-1' && equipmentId == tractor.id;
  }
}

class FakeWalletRemoteDataSource implements WalletRemoteDataSource {
  var ensured = false;
  var toppedUp = false;

  @override
  Future<void> ensureWallet(String userId) async {
    ensured = userId == 'farmer-1';
  }

  @override
  Stream<WalletAccountModel> watchWallet(String userId) =>
      Stream.value(const WalletAccountModel(userId: 'farmer-1', balance: 5000));

  @override
  Stream<List<WalletActivityModel>> watchActivities(String userId) =>
      Stream.value(const <WalletActivityModel>[]);

  @override
  Future<void> topUp({required String userId, required double amount}) async {
    toppedUp = userId == 'farmer-1' && amount == 5000;
  }
}

void main() {
  test(
    'favorites repository delegates and cubit toggles optimistically',
    () async {
      final remote = FakeFavoritesRemoteDataSource();
      final repository = FavoritesRepositoryImpl(remote);
      final cubit = FavoritesCubit(repository);
      addTearDown(() async {
        await cubit.close();
        await remote.controller.close();
      });

      cubit.watch('farmer-1');
      remote.controller.add(const [
        EquipmentModel(
          id: 'equipment-1',
          name: 'John Deere 5050D',
          ownerId: 'owner-1',
          description: 'description',
          pricePerDay: 25000,
          pricePerMonth: 500000,
          status: EquipmentStatus.available,
          category: 'Tractors',
          image: '',
          location: 'Musanze',
          rating: 4.8,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.contains(tractor.id), isTrue);

      await cubit.toggle(tractor);
      expect(remote.removed, isTrue);
      await cubit.toggle(tractor);
      expect(remote.added, isTrue);
      expect(cubit.state.equipmentIds, {tractor.id});
    },
  );

  test('favorites cubit reports sign-in and repository errors', () async {
    final repository = FakeFavoritesRepository();
    final cubit = FavoritesCubit(repository);
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });

    await cubit.toggle(tractor);
    expect(cubit.state.error, contains('Sign in'));

    cubit.watch('farmer-1');
    await Future<void>.delayed(Duration.zero);
    repository.error = StateError('offline');
    await cubit.toggle(tractor);
    expect(cubit.state.error, contains('offline'));
    expect(cubit.state.equipment, isEmpty);
  });

  test(
    'wallet repository delegates and wallet values expose useful state',
    () async {
      final remote = FakeWalletRemoteDataSource();
      final repository = WalletRepositoryImpl(remote);
      await repository.ensureWallet('farmer-1');
      expect(remote.ensured, isTrue);
      expect((await repository.watchWallet('farmer-1').first).balance, 5000);
      expect(await repository.watchActivities('farmer-1').first, isEmpty);
      await repository.topUp(userId: 'farmer-1', amount: 5000);
      expect(remote.toppedUp, isTrue);

      final activity = WalletActivity(
        id: 'activity-1',
        type: WalletActivityType.rentalPayment,
        amount: -2500,
        balanceAfter: 2500,
        title: 'Rental',
        rentalId: 'rental-1',
        createdAt: DateTime(2026, 7, 29),
      );
      expect(activity.isCredit, isFalse);
      expect(activity.props, contains('rental-1'));
      expect(WalletAccount.empty('user').balance, 0);

      const error = InsufficientWalletBalanceException(
        amountDue: 10000,
        availableBalance: 3500,
      );
      expect(error.shortfall, 6500);
      expect(error.toString(), contains('not enough'));
    },
  );

  test('wallet cubit watches, tops up, and exposes failures', () async {
    final repository = FakeWalletRepository(
      wallet: const WalletAccount(userId: 'farmer-1', balance: 5000),
    );
    final cubit = WalletCubit(repository)..watch('farmer-1');
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.balance, 5000);
    expect(repository.ensureCalls, 1);

    cubit.watch('farmer-1');
    expect(repository.ensureCalls, 1);
    await cubit.topUp(5000);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.balance, 10000);
    expect(cubit.state.activities.single.isCredit, isTrue);

    repository.error = StateError('provider unavailable');
    await expectLater(cubit.topUp(1000), throwsStateError);
    expect(cubit.state.error, contains('provider unavailable'));

    final signedOutCubit = WalletCubit(repository);
    await expectLater(signedOutCubit.topUp(1000), throwsStateError);
    await signedOutCubit.close();
  });

  testWidgets('favorites page renders saved equipment and removes it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeFavoritesRepository([tractor]);
    final cubit = FavoritesCubit(repository)..watch('farmer-1');
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });
    await tester.pumpWidget(
      BlocProvider<FavoritesCubit>.value(
        value: cubit,
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );
    await tester.pump();
    expect(find.text('John Deere 5050D'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('favorite-equipment-1')));
    await tester.pump();
    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('favorites page shows its empty state', (tester) async {
    final repository = FakeFavoritesRepository();
    final cubit = FavoritesCubit(repository)..watch('farmer-1');
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });
    await tester.pumpWidget(
      BlocProvider<FavoritesCubit>.value(
        value: cubit,
        child: const MaterialApp(home: FavoritesPage()),
      ),
    );
    await tester.pump();
    expect(find.text('No favorites yet'), findsOneWidget);
  });

  testWidgets('wallet page displays activity and completes a top-up', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeWalletRepository(
      wallet: const WalletAccount(userId: 'farmer-1', balance: 5000),
      activities: [
        WalletActivity(
          id: 'rental-activity',
          type: WalletActivityType.rentalPayment,
          amount: -7000,
          balanceAfter: 5000,
          title: 'Rental • Knapsack Sprayer',
          createdAt: DateTime(2026, 5, 30),
        ),
      ],
    );
    final cubit = WalletCubit(repository)..watch('farmer-1');
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });
    await tester.pumpWidget(
      BlocProvider<WalletCubit>.value(
        value: cubit,
        child: const MaterialApp(home: WalletPage()),
      ),
    );
    await tester.pump();
    expect(find.text('RWF 5,000'), findsOneWidget);
    expect(find.text('Rental • Knapsack Sprayer'), findsOneWidget);

    await tester.tap(find.text('Top Up'));
    await tester.pumpAndSettle();
    expect(find.byType(TopUpWalletPage), findsOneWidget);
    await tester.tap(find.text('RWF 5,000').last);
    await tester.pump();
    repository.topUpCompleter = Completer<void>();
    final submit = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(submit.onPressed, isNotNull);
    submit.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WalletProcessingPage), findsOneWidget);
    repository.topUpCompleter!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(WalletPage), findsOneWidget);
    expect(find.text('RWF 10,000'), findsOneWidget);
  });

  testWidgets('wallet page renders empty activity', (tester) async {
    final repository = FakeWalletRepository();
    final cubit = WalletCubit(repository)..watch('farmer-1');
    addTearDown(() async {
      await cubit.close();
      await repository.close();
    });
    await tester.pumpWidget(
      BlocProvider<WalletCubit>.value(
        value: cubit,
        child: const MaterialApp(home: WalletPage()),
      ),
    );
    await tester.pump();
    expect(find.text('No wallet activity yet'), findsOneWidget);
  });

  testWidgets('insufficient and successful payment screens navigate tabs', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final navigation = FarmerNavigationCubit();
    addTearDown(navigation.close);

    await tester.pumpWidget(
      BlocProvider<FarmerNavigationCubit>.value(
        value: navigation,
        child: const MaterialApp(
          home: InsufficientBalancePage(
            amountDue: 52500,
            availableBalance: 5000,
          ),
        ),
      ),
    );
    expect(find.text('Insufficient Balance'), findsOneWidget);
    expect(find.text('RWF 47,500'), findsOneWidget);
    await tester.tap(find.text('Go to Wallet'));
    expect(navigation.state, 2);

    final booking = Booking(
      id: 'agri-000001',
      equipmentId: tractor.id,
      equipmentName: tractor.name,
      equipmentCategory: tractor.category,
      equipmentImage: '',
      farmerId: 'farmer-1',
      farmerName: 'Alice',
      ownerId: tractor.ownerId,
      ownerName: tractor.ownerName,
      rateType: RateType.day,
      rate: 25000,
      duration: 2,
      startDate: DateTime(2026, 7, 30),
      subtotal: 50000,
      serviceFee: 2500,
      total: 52500,
      status: BookingStatus.pending,
      createdAt: DateTime(2026, 7, 29),
    );
    await tester.pumpWidget(
      BlocProvider<FarmerNavigationCubit>.value(
        value: navigation,
        child: MaterialApp(home: PaymentSuccessPage(booking: booking)),
      ),
    );
    await tester.pump();
    expect(find.text('Booking Confirmed!'), findsOneWidget);
    expect(find.text('RWF 52,500'), findsOneWidget);
    await tester.tap(find.text('View My Bookings'));
    expect(navigation.state, 1);
  });
}
