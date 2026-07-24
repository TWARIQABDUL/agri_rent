// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

import 'core/services/preferences_service.dart' as _i811;
import 'features/auth/data/datasources/auth_remote_data_source.dart' as _i767;
import 'features/auth/data/repositories/auth_repository_impl.dart' as _i111;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/get_current_user.dart' as _i191;
import 'features/auth/domain/usecases/sign_in_with_email.dart' as _i509;
import 'features/auth/domain/usecases/sign_in_with_google.dart' as _i648;
import 'features/auth/domain/usecases/sign_out.dart' as _i872;
import 'features/auth/domain/usecases/sign_up_with_email.dart' as _i784;
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
    gh.lazySingleton<_i811.PreferencesService>(
      () => _i811.PreferencesService(),
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i767.AuthRemoteDataSource>(
      () => _i767.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i415.EquipmentRemoteDataSource>(
      () => _i415.EquipmentRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i1015.AuthRepository>(
      () => _i111.AuthRepositoryImpl(gh<_i767.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i683.EquipmentRepository>(
      () =>
          _i822.EquipmentRepositoryImpl(gh<_i415.EquipmentRemoteDataSource>()),
    );
    gh.lazySingleton<_i613.GetEquipment>(
      () => _i613.GetEquipment(gh<_i683.EquipmentRepository>()),
    );
    gh.lazySingleton<_i191.GetCurrentUser>(
      () => _i191.GetCurrentUser(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i509.SignInWithEmail>(
      () => _i509.SignInWithEmail(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i648.SignInWithGoogle>(
      () => _i648.SignInWithGoogle(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i872.SignOut>(
      () => _i872.SignOut(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i784.SignUpWithEmail>(
      () => _i784.SignUpWithEmail(gh<_i1015.AuthRepository>()),
    );
    gh.factory<_i825.EquipmentBloc>(
      () => _i825.EquipmentBloc(gh<_i613.GetEquipment>()),
    );
    gh.factory<_i363.AuthBloc>(
      () => _i363.AuthBloc(
        gh<_i509.SignInWithEmail>(),
        gh<_i784.SignUpWithEmail>(),
        gh<_i648.SignInWithGoogle>(),
        gh<_i872.SignOut>(),
        gh<_i191.GetCurrentUser>(),
        gh<_i1015.AuthRepository>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i809.FirebaseModule {}
