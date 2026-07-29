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
import 'features/booking/data/datasources/booking_remote_data_source.dart'
    as _i97;
import 'features/booking/data/repositories/booking_repository_impl.dart'
    as _i703;
import 'features/booking/domain/repositories/booking_repository.dart' as _i829;
import 'features/booking/domain/usecases/calculate_rental_cost.dart' as _i738;
import 'features/booking/domain/usecases/create_booking.dart' as _i46;
import 'features/booking/presentation/bloc/booking_bloc.dart' as _i393;
import 'features/equipment/data/datasources/equipment_remote_data_source.dart'
    as _i415;
import 'features/equipment/data/repositories/equipment_repository_impl.dart'
    as _i822;
import 'features/equipment/domain/repositories/equipment_repository.dart'
    as _i683;
import 'features/equipment/domain/usecases/get_equipment.dart' as _i613;
import 'features/equipment/presentation/bloc/equipment_bloc.dart' as _i825;
import 'features/owner/data/datasources/owner_remote_data_source.dart' as _i301;
import 'features/owner/data/repositories/owner_repository_impl.dart' as _i1063;
import 'features/owner/domain/repositories/owner_repository.dart' as _i676;
import 'features/owner/domain/usecases/ensure_owner_profile.dart' as _i721;
import 'features/owner/domain/usecases/get_owner_listings.dart' as _i608;
import 'features/owner/domain/usecases/get_owner_summary.dart' as _i475;
import 'features/owner/domain/usecases/publish_listing.dart' as _i158;
import 'features/owner/domain/usecases/set_listing_paused.dart' as _i582;
import 'features/owner/domain/usecases/update_listing.dart' as _i454;
import 'features/owner/presentation/bloc/listing_form_bloc.dart' as _i68;
import 'features/owner/presentation/bloc/owner_dashboard_bloc.dart' as _i624;
import 'features/owner/presentation/bloc/owner_listings_bloc.dart' as _i595;
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
    gh.lazySingleton<_i738.CalculateRentalCost>(
      () => const _i738.CalculateRentalCost(),
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i301.OwnerRemoteDataSource>(
      () => _i301.OwnerRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i767.AuthRemoteDataSource>(
      () => _i767.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i116.GoogleSignIn>(),
        gh<_i974.FirebaseFirestore>(),
        gh<_i811.PreferencesService>(),
      ),
    );
    gh.lazySingleton<_i97.BookingRemoteDataSource>(
      () => _i97.BookingRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i829.BookingRepository>(
      () => _i703.BookingRepositoryImpl(gh<_i97.BookingRemoteDataSource>()),
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
    gh.lazySingleton<_i46.CreateBooking>(
      () => _i46.CreateBooking(
        gh<_i829.BookingRepository>(),
        gh<_i738.CalculateRentalCost>(),
      ),
    gh.lazySingleton<_i676.OwnerRepository>(
      () => _i1063.OwnerRepositoryImpl(gh<_i301.OwnerRemoteDataSource>()),
    );
    gh.lazySingleton<_i721.EnsureOwnerProfile>(
      () => _i721.EnsureOwnerProfile(gh<_i676.OwnerRepository>()),
    );
    gh.lazySingleton<_i608.GetOwnerListings>(
      () => _i608.GetOwnerListings(gh<_i676.OwnerRepository>()),
    );
    gh.lazySingleton<_i475.GetOwnerSummary>(
      () => _i475.GetOwnerSummary(gh<_i676.OwnerRepository>()),
    );
    gh.lazySingleton<_i158.PublishListing>(
      () => _i158.PublishListing(gh<_i676.OwnerRepository>()),
    );
    gh.lazySingleton<_i582.SetListingPaused>(
      () => _i582.SetListingPaused(gh<_i676.OwnerRepository>()),
    );
    gh.lazySingleton<_i454.UpdateListing>(
      () => _i454.UpdateListing(gh<_i676.OwnerRepository>()),
    );
    gh.lazySingleton<_i613.GetEquipment>(
      () => _i613.GetEquipment(gh<_i683.EquipmentRepository>()),
    );
    gh.factory<_i68.ListingFormBloc>(
      () => _i68.ListingFormBloc(
        gh<_i158.PublishListing>(),
        gh<_i454.UpdateListing>(),
      ),
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
    gh.factory<_i393.BookingBloc>(
      () => _i393.BookingBloc(gh<_i46.CreateBooking>()),
    );
    gh.factory<_i825.EquipmentBloc>(
      () => _i825.EquipmentBloc(gh<_i613.GetEquipment>()),
    );
    gh.factory<_i624.OwnerDashboardBloc>(
      () => _i624.OwnerDashboardBloc(
        gh<_i475.GetOwnerSummary>(),
        gh<_i721.EnsureOwnerProfile>(),
      ),
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
    gh.factory<_i595.OwnerListingsBloc>(
      () => _i595.OwnerListingsBloc(
        gh<_i608.GetOwnerListings>(),
        gh<_i582.SetListingPaused>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i809.FirebaseModule {}
