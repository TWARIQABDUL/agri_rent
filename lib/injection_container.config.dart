// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'features/auth/presentation/bloc/auth_bloc.dart' as _i363;
import 'features/equipment/data/datasources/equipment_remote_data_source.dart'
    as _i415;
import 'features/equipment/data/repositories/equipment_repository_impl.dart'
    as _i822;
import 'features/equipment/domain/repositories/equipment_repository.dart'
    as _i683;
import 'features/equipment/domain/usecases/get_equipment.dart' as _i613;
import 'features/equipment/presentation/bloc/equipment_bloc.dart' as _i825;
import 'injection_container.dart' as _i809;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.factory<_i363.AuthBloc>(() => _i363.AuthBloc());
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i415.EquipmentRemoteDataSource>(
      () => _i415.EquipmentRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i683.EquipmentRepository>(
      () =>
          _i822.EquipmentRepositoryImpl(gh<_i415.EquipmentRemoteDataSource>()),
    );
    gh.lazySingleton<_i613.GetEquipment>(
      () => _i613.GetEquipment(gh<_i683.EquipmentRepository>()),
    );
    gh.factory<_i825.EquipmentBloc>(
      () => _i825.EquipmentBloc(gh<_i613.GetEquipment>()),
    );
    return this;
  }
}

class _$FirebaseModule extends _i809.FirebaseModule {}
