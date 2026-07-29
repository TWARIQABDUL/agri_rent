import 'package:agri_rent/features/auth/domain/entities/user.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agri_rent/features/booking/domain/entities/booking.dart'
    as create_domain;
import 'package:agri_rent/features/booking/domain/repositories/booking_repository.dart'
    as create_domain;
import 'package:agri_rent/features/booking/domain/usecases/calculate_rental_cost.dart';
import 'package:agri_rent/features/booking/domain/usecases/create_booking.dart';
import 'package:agri_rent/features/booking/presentation/bloc/booking_bloc.dart'
    as create_presentation;
import 'package:agri_rent/features/booking/presentation/pages/checkout_page.dart';
import 'package:agri_rent/features/booking/presentation/pages/equipment_detail_page.dart';
import 'package:agri_rent/features/booking/presentation/pages/request_to_rent_page.dart';
import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:agri_rent/features/main_shell/farmer_navigation_cubit.dart';
import 'package:agri_rent/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:agri_rent/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/auth_test_helpers.dart';
import '../../support/feature_test_helpers.dart';

const equipment = Equipment(
  id: 'equipment-1',
  name: 'John Deere 5050D',
  ownerId: 'owner-1',
  ownerName: 'Patrick Mugisha',
  description:
      'A dependable tractor for ploughing, planting, and general farm work.',
  pricePerDay: 25000,
  pricePerMonth: 500000,
  pricePerHour: 5000,
  pricePerHectare: 18000,
  status: EquipmentStatus.available,
  category: 'Tractors',
  image: '',
  location: 'Musanze',
  rating: 4.8,
  reviewCount: 12,
  specs: {'Power': '50 HP', 'Year': '2024', 'Fuel': 'Diesel'},
);

class FakeCreateBookingRepository implements create_domain.BookingRepository {
  create_domain.Booking? submitted;
  Object? error;

  @override
  Future<create_domain.Booking> createBooking(
    create_domain.Booking booking,
  ) async {
    if (error != null) throw error!;
    submitted = booking;
    return booking;
  }
}

void main() {
  late FakeAuthRepository authRepository;
  late AuthBloc authBloc;
  late FakeCreateBookingRepository bookingRepository;
  late FakeFavoritesRepository favoritesRepository;
  late FavoritesCubit favoritesCubit;
  late FakeWalletRepository walletRepository;
  late WalletCubit walletCubit;
  late FarmerNavigationCubit navigationCubit;

  setUp(() async {
    await sl.reset();
    authRepository = FakeAuthRepository()
      ..currentUser = const User(
        id: 'farmer-1',
        email: 'alice@example.com',
        displayName: 'Alice Farmer',
        emailVerified: true,
      );
    authBloc = makeAuthBloc(authRepository);
    await authenticate(authBloc);
    bookingRepository = FakeCreateBookingRepository();
    favoritesRepository = FakeFavoritesRepository();
    favoritesCubit = FavoritesCubit(favoritesRepository)..watch('farmer-1');
    walletRepository = FakeWalletRepository();
    walletCubit = WalletCubit(walletRepository)..watch('farmer-1');
    navigationCubit = FarmerNavigationCubit();
    await Future<void>.delayed(Duration.zero);
    sl.registerFactory<create_presentation.BookingBloc>(
      () => create_presentation.BookingBloc(
        CreateBooking(bookingRepository, const CalculateRentalCost()),
      ),
    );
  });

  tearDown(() async {
    await authBloc.close();
    await authRepository.close();
    await favoritesCubit.close();
    await favoritesRepository.close();
    await walletCubit.close();
    await walletRepository.close();
    await navigationCubit.close();
    await sl.reset();
  });

  Widget app(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
        BlocProvider<WalletCubit>.value(value: walletCubit),
        BlocProvider<FarmerNavigationCubit>.value(value: navigationCubit),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('equipment detail opens the real request form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(const EquipmentDetailPage(equipment: equipment)),
    );
    await tester.pump();

    expect(find.text('John Deere 5050D'), findsOneWidget);
    expect(find.text('Musanze'), findsWidgets);
    expect(find.text('Request to Rent'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.text('Request to Rent'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RequestToRentPage), findsOneWidget);
    expect(find.text('Choose rate'), findsOneWidget);
    expect(find.text('Continue to Checkout'), findsOneWidget);
  });

  testWidgets('request form validates then submits through checkout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(
        const RequestToRentPage(
          equipment: equipment,
          initialRateType: create_domain.RateType.day,
          initialRate: 25000,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Continue to Checkout'));
    await tester.pump();
    expect(find.text('Please choose a start date.'), findsOneWidget);

    await tester.tap(find.text('dd/mm/yyyy'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();

    await tester.tap(find.text('Continue to Checkout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(find.text('Order summary'), findsOneWidget);

    await tester.tap(find.textContaining('Pay RWF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(bookingRepository.submitted?.farmerId, 'farmer-1');
    expect(bookingRepository.submitted?.farmerName, 'Alice Farmer');
    expect(bookingRepository.submitted?.ownerId, 'owner-1');
    expect(
      bookingRepository.submitted?.status,
      create_domain.BookingStatus.pending,
    );
    expect(find.text('Booking Confirmed!'), findsOneWidget);
  });

  testWidgets('checkout surfaces a Firestore submission failure', (
    tester,
  ) async {
    bookingRepository.error = StateError('permission denied');
    final params = CreateBookingParams(
      equipment: equipment,
      farmerId: 'farmer-1',
      farmerName: 'Alice Farmer',
      rateType: create_domain.RateType.hour,
      rate: 5000,
      duration: 2,
      startDate: DateTime(2026, 7, 30),
    );

    await tester.pumpWidget(
      app(
        BlocProvider<create_presentation.BookingBloc>(
          create: (_) => sl<create_presentation.BookingBloc>(),
          child: CheckoutPage(params: params),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.textContaining('Pay RWF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('permission denied'), findsOneWidget);
  });
}
