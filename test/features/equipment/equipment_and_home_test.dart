import 'package:agri_rent/features/auth/domain/entities/user.dart';
import 'package:agri_rent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agri_rent/features/equipment/data/datasources/equipment_remote_data_source.dart';
import 'package:agri_rent/features/equipment/data/models/equipment_model.dart';
import 'package:agri_rent/features/equipment/data/repositories/equipment_repository_impl.dart';
import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/equipment/domain/repositories/equipment_repository.dart';
import 'package:agri_rent/features/equipment/domain/usecases/get_equipment.dart';
import 'package:agri_rent/features/equipment/presentation/bloc/equipment_bloc.dart';
import 'package:agri_rent/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:agri_rent/features/home/presentation/pages/home_page.dart';
import 'package:agri_rent/features/home/presentation/widgets/active_rental_banner.dart';
import 'package:agri_rent/features/home/presentation/widgets/category_chip.dart';
import 'package:agri_rent/features/home/presentation/widgets/equipment_card.dart';
import 'package:agri_rent/features/home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/auth_test_helpers.dart';
import '../../support/feature_test_helpers.dart';

const equipment = [
  Equipment(
    id: 'equipment-1',
    name: 'John Deere 5050D',
    ownerId: 'Patrick',
    description: 'Reliable tractor',
    pricePerDay: 25000,
    pricePerMonth: 500000,
    status: 'available',
    category: 'Tractors',
    image: '',
    location: 'Musanze',
    rating: 4.8,
  ),
  Equipment(
    id: 'equipment-2',
    name: 'Irrigation Pump X2',
    ownerId: 'Alice',
    description: 'Water pump',
    pricePerDay: 8000,
    pricePerMonth: 160000,
    status: 'available',
    category: 'Pumps',
    image: '',
    location: 'Kigali',
    rating: 4.6,
  ),
];

class FakeEquipmentRepository implements EquipmentRepository {
  String? category;

  @override
  Future<List<Equipment>> getEquipment({String? category}) async {
    this.category = category;
    if (category == null || category == 'All') return equipment;
    return equipment.where((item) => item.category == category).toList();
  }
}

class FakeEquipmentRemoteDataSource implements EquipmentRemoteDataSource {
  String? category;

  @override
  Future<List<EquipmentModel>> getEquipment({String? category}) async {
    this.category = category;
    return const [
      EquipmentModel(
        id: 'model-1',
        name: 'Model Tractor',
        ownerId: 'owner',
        description: 'description',
        pricePerDay: 100,
        pricePerMonth: 2000,
        status: 'available',
        category: 'Tractors',
        image: '',
        location: 'Kigali',
        rating: 4.5,
      ),
    ];
  }
}

void main() {
  test('equipment model and repository map data cleanly', () async {
    const model = EquipmentModel(
      id: 'model-1',
      name: 'Model Tractor',
      ownerId: 'owner',
      description: 'description',
      pricePerDay: 100,
      pricePerMonth: 2000,
      status: 'available',
      category: 'Tractors',
      image: 'image',
      location: 'Kigali',
      rating: 4.5,
    );
    expect(model.toJson(), {
      'name': 'Model Tractor',
      'ownerId': 'owner',
      'description': 'description',
      'pricePerDay': 100.0,
      'pricePerMonth': 2000.0,
      'status': 'available',
      'category': 'Tractors',
      'image': 'image',
      'location': 'Kigali',
      'rating': 4.5,
      'ownerName': '',
      'reviewCount': 0,
      'pricePerHour': 0.0,
      'pricePerHectare': 0.0,
      'specs': <String, String>{},
      'bookingCount': 0,
    });

    final remote = FakeEquipmentRemoteDataSource();
    final repository = EquipmentRepositoryImpl(remote);
    final result = await repository.getEquipment(category: 'Tractors');
    expect(result.single.name, 'Model Tractor');
    expect(remote.category, 'Tractors');
  });

  testWidgets('Home renders authenticated user and fetched equipment', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1300));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final authRepository = FakeAuthRepository()
      ..currentUser = const User(
        id: 'farmer-1',
        email: 'jean@example.com',
        displayName: 'Jean Bosco',
      );
    final authBloc = makeAuthBloc(authRepository);
    await authenticate(authBloc);
    final equipmentRepository = FakeEquipmentRepository();
    final equipmentBloc = EquipmentBloc(GetEquipment(equipmentRepository));
    final favoritesRepository = FakeFavoritesRepository();
    final favoritesCubit = FavoritesCubit(favoritesRepository)
      ..watch('farmer-1');
    addTearDown(() async {
      await equipmentBloc.close();
      await favoritesCubit.close();
      await favoritesRepository.close();
      await authBloc.close();
      await authRepository.close();
    });

    final loaded = equipmentBloc.stream.firstWhere(
      (state) => state is EquipmentLoaded,
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<EquipmentBloc>.value(value: equipmentBloc),
          BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.runAsync(() => loaded);
    await tester.pump();

    expect(find.text('Jean Bosco'), findsOneWidget);
    expect(find.text('Search by location...'), findsOneWidget);
    expect(find.text('Active Rental'), findsOneWidget);
    expect(find.text('John Deere 5050D'), findsOneWidget);
    expect(find.text('Irrigation Pump X2'), findsOneWidget);
    expect(find.text('Musanze'), findsOneWidget);

    final pumpLoaded = equipmentBloc.stream.firstWhere(
      (state) => state is EquipmentLoaded,
    );
    await tester.tap(find.text('Pumps').first);
    await tester.runAsync(() => pumpLoaded);
    await tester.pump();
    expect(equipmentRepository.category, 'Pumps');
    expect(find.text('Irrigation Pump X2'), findsOneWidget);
  });

  testWidgets('Filter sheet applies category, location, and price', (
    tester,
  ) async {
    String? category;
    String? location;
    double? price;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => FilterBottomSheet(
                    initialCategory: 'All',
                    initialLocation: 'Anywhere',
                    initialMaxPrice: 50000,
                    onApply: (c, l, p) {
                      category = c;
                      location = l;
                      price = p;
                    },
                  ),
                ),
                child: const Text('Open filters'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    expect(find.text('Filters'), findsOneWidget);
    await tester.tap(find.text('Tractors'));
    await tester.pump();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Musanze').last);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Slider), const Offset(100, 0));
    await tester.pump();
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(category, 'Tractors');
    expect(location, 'Musanze');
    expect(price, greaterThan(50000));
  });

  testWidgets('shared home widgets render their variants and callbacks', (
    tester,
  ) async {
    var tapped = false;
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 170,
                height: 300,
                child: EquipmentCard(
                  name: 'Tractor',
                  ownerId: 'owner',
                  pricePerDay: 25000,
                  location: '',
                  rating: 4.8,
                  type: 'tractor',
                  image: '',
                ),
              ),
              SizedBox(
                width: 170,
                height: 300,
                child: EquipmentCard(
                  name: 'Sprayer',
                  ownerId: 'owner',
                  pricePerDay: 3500,
                  location: 'Kigali',
                  rating: 4.6,
                  type: 'sprayer',
                  image: '',
                ),
              ),
              Column(
                children: [
                  CategoryChip(
                    label: 'Selected',
                    icon: Icons.agriculture,
                    isSelected: true,
                    onTap: () => tapped = true,
                  ),
                  CategoryChip(
                    label: 'Not selected',
                    icon: Icons.water_drop,
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 420, child: ActiveRentalBanner()),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Rwanda'), findsOneWidget);
    expect(find.text('Kigali'), findsOneWidget);
    expect(find.text('Track →'), findsOneWidget);
    await tester.tap(find.text('Selected'));
    expect(tapped, isTrue);
    await tester.tap(find.text('Track →'));
  });
}
