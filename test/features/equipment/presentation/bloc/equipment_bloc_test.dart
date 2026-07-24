import 'package:flutter_test/flutter_test.dart';
import 'package:agri_rent/features/equipment/domain/entities/equipment.dart';
import 'package:agri_rent/features/equipment/domain/usecases/get_equipment.dart';
import 'package:agri_rent/features/equipment/presentation/bloc/equipment_bloc.dart';
import 'package:agri_rent/features/equipment/domain/repositories/equipment_repository.dart';

class FakeEquipmentRepository implements EquipmentRepository {
  final List<Equipment> mockData = [
    const Equipment(
      id: '1',
      name: 'Tractor A',
      ownerId: 'owner1',
      description: 'Desc',
      pricePerDay: 100,
      pricePerMonth: 2000,
      status: 'available',
      category: 'Tractors',
      image: '',
      location: 'Kigali',
      rating: 4.5,
    ),
    const Equipment(
      id: '2',
      name: 'Pump B',
      ownerId: 'owner2',
      description: 'Desc',
      pricePerDay: 50,
      pricePerMonth: 1000,
      status: 'available',
      category: 'Pumps',
      image: '',
      location: 'Muhanga',
      rating: 4.2,
    ),
    const Equipment(
      id: '3',
      name: 'Tractor C',
      ownerId: 'owner3',
      description: 'Desc',
      pricePerDay: 120,
      pricePerMonth: 2200,
      status: 'available',
      category: 'Tractors',
      image: '',
      location: 'Muhanga',
      rating: 4.8,
    ),
  ];

  @override
  Future<List<Equipment>> getEquipment({String? category}) async {
    if (category != null && category != 'All') {
      return mockData.where((e) => e.category == category).toList();
    }
    return mockData;
  }
}

void main() {
  late EquipmentBloc bloc;
  late GetEquipment getEquipment;
  late FakeEquipmentRepository repository;

  setUp(() {
    repository = FakeEquipmentRepository();
    getEquipment = GetEquipment(repository);
    bloc = EquipmentBloc(getEquipment);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be EquipmentInitial', () {
    expect(bloc.state, isA<EquipmentInitial>());
  });

  test(
    'emits [Loading, Loaded] with ALL data when fetching with no filters',
    () async {
      // Assert later
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EquipmentLoading>(),
          isA<EquipmentLoaded>().having(
            (state) => state.equipment.length,
            'equipment list length',
            3,
          ),
        ]),
      );

      // Act
      bloc.add(const FetchEquipmentEvent(category: 'All'));
    },
  );

  test(
    'emits [Loading, Loaded] with filtered data when category filter is applied',
    () async {
      // Assert later
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EquipmentLoading>(),
          isA<EquipmentLoaded>()
              .having(
                (state) => state.equipment.length,
                'equipment list length',
                2, // 2 Tractors
              )
              .having(
                (state) =>
                    state.equipment.every((e) => e.category == 'Tractors'),
                'all are Tractors',
                true,
              ),
        ]),
      );

      // Act
      bloc.add(const FetchEquipmentEvent(category: 'Tractors'));
    },
  );

  test(
    'emits [Loading, Loaded] with filtered data when location search is applied',
    () async {
      // Assert later
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EquipmentLoading>(),
          isA<EquipmentLoaded>()
              .having(
                (state) => state.equipment.length,
                'equipment list length',
                1, // 1 equipment in Kigali
              )
              .having(
                (state) => state.equipment.first.location,
                'location is Kigali',
                'Kigali',
              ),
        ]),
      );

      // Act
      bloc.add(const FetchEquipmentEvent(category: 'All', location: 'Kigali'));
    },
  );

  test(
    'emits [Loading, Loaded] combining category AND location filters',
    () async {
      // Assert later
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<EquipmentLoading>(),
          isA<EquipmentLoaded>()
              .having(
                (state) => state.equipment.length,
                'equipment list length',
                1, // 1 Tractor in Muhanga
              )
              .having(
                (state) => state.equipment.first.name,
                'name is Tractor C',
                'Tractor C',
              ),
        ]),
      );

      // Act
      bloc.add(
        const FetchEquipmentEvent(category: 'Tractors', location: 'Muhanga'),
      );
    },
  );
}
