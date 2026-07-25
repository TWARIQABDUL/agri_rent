import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/owner_summary.dart';
import '../../domain/usecases/ensure_owner_profile.dart';
import '../../domain/usecases/get_owner_summary.dart';

part 'owner_dashboard_event.dart';
part 'owner_dashboard_state.dart';

@injectable
class OwnerDashboardBloc
    extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  final GetOwnerSummary getOwnerSummary;
  final EnsureOwnerProfile ensureOwnerProfile;

  OwnerDashboardBloc(this.getOwnerSummary, this.ensureOwnerProfile)
    : super(OwnerDashboardInitial()) {
    on<LoadOwnerDashboard>(_onLoad);
  }

  Future<void> _onLoad(
    LoadOwnerDashboard event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    if (!event.silent) emit(OwnerDashboardLoading());
    try {
      // The profile document is what the security rules read before allowing a
      // listing write, so it is created here rather than at publish time.
      await ensureOwnerProfile(
        EnsureOwnerProfileParams(
          ownerId: event.ownerId,
          displayName: event.displayName,
          email: event.email,
        ),
      );
      emit(OwnerDashboardLoaded(await getOwnerSummary(event.ownerId)));
    } catch (error) {
      emit(OwnerDashboardError(error.toString()));
    }
  }
}
