import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/pages/profile_page.dart';
import '../auth/presentation/pages/splash_page.dart';
import '../bookings/presentation/pages/my_bookings_page.dart';
import '../favorites/presentation/cubit/favorites_cubit.dart';
import '../favorites/presentation/pages/favorites_page.dart';
import '../home/presentation/pages/home_page.dart';
import '../home/presentation/widgets/custom_bottom_nav.dart';
import '../wallet/presentation/cubit/wallet_cubit.dart';
import '../wallet/presentation/pages/wallet_page.dart';
import 'farmer_navigation_cubit.dart';

/// The farmer workspace.
///
/// [RoleHome] routes owner accounts to OwnerShell, so this shell only exposes
/// farmer tabs. Booking queries always receive the authenticated Firebase UID.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) =>
            current is Authenticated ||
            current is Unauthenticated ||
            current is AuthInitial ||
            current is AuthLoading,
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              ),
            );
          }

          context.read<FavoritesCubit>().watch(state.user.id);
          context.read<WalletCubit>().watch(state.user.id);

          final pages = <Widget>[
            const HomePage(),
            MyBookingsPage(farmerId: state.user.id),
            const WalletPage(),
            const FavoritesPage(),
            const ProfilePage(),
          ];

          return BlocBuilder<FarmerNavigationCubit, int>(
            builder: (context, tab) => Scaffold(
              extendBody: true,
              backgroundColor: AppColors.background,
              body: IndexedStack(index: tab, children: pages),
              bottomNavigationBar: CustomBottomNav(
                currentIndex: tab,
                onTap: context.read<FarmerNavigationCubit>().select,
              ),
            ),
          );
        },
      ),
    );
  }
}
