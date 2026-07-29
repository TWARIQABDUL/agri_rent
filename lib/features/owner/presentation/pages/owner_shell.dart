import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../auth/presentation/pages/splash_page.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_listings_bloc.dart';
import '../widgets/owner_bottom_nav.dart';
import '../widgets/owner_states.dart';
import 'earnings_page.dart';
import 'my_listings_page.dart';
import 'owner_dashboard_page.dart';

/// The owner workspace. Both owner blocs are provided here rather than per
/// page, so publishing from the dashboard refreshes the shelf behind it.
class OwnerShell extends StatelessWidget {
  const OwnerShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Route guard: sign-out (or token loss) shouldn't leave an owner
        // sitting on the earnings screen looking at a stale spinner.
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashPage()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }

        final user = state.user;
        return MultiBlocProvider(
          key: ValueKey(user.id),
          providers: [
            BlocProvider(
              create: (_) => sl<OwnerDashboardBloc>()
                ..add(
                  LoadOwnerDashboard(
                    ownerId: user.id,
                    displayName: user.displayName,
                    email: user.email,
                  ),
                ),
            ),
            BlocProvider(
              create: (_) =>
                  sl<OwnerListingsBloc>()..add(LoadOwnerListings(user.id)),
            ),
          ],
          child: _OwnerShellView(user: user),
        );
      },
    );
  }
}

class _OwnerShellView extends StatefulWidget {
  final User user;

  const _OwnerShellView({required this.user});

  @override
  State<_OwnerShellView> createState() => _OwnerShellViewState();
}

class _OwnerShellViewState extends State<_OwnerShellView> {
  int _tab = 0;

  void _openTab(int index) => setState(() => _tab = index);

  String get _ownerName {
    final name = widget.user.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return widget.user.email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = widget.user.id;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tab,
        children: [
          OwnerDashboardPage(
            ownerId: ownerId,
            ownerName: _ownerName,
            onOpenTab: _openTab,
          ),
          MyListingsPage(ownerId: ownerId),
          const _RequestsTab(),
          EarningsPage(ownerId: ownerId),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
        builder: (context, state) {
          final pending = state is OwnerDashboardLoaded
              ? state.summary.pendingRequestCount
              : 0;
          return OwnerBottomNav(
            currentIndex: _tab,
            onTap: _openTab,
            pendingRequestCount: pending,
          );
        },
      ),
    );
  }
}

/// Placeholder for the rental requests inbox, which ships with the rentals
/// module. The counter is real so an owner is not left unaware of waiting
/// requests.
class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rental Requests',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
        builder: (context, state) {
          final pending = state is OwnerDashboardLoaded
              ? state.summary.pendingRequestCount
              : 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
            children: [
              EmptyState(
                icon: Icons.inbox_outlined,
                title: pending == 0
                    ? 'No requests waiting'
                    : '$pending request${pending == 1 ? '' : 's'} waiting',
                message:
                    'Reviewing, accepting and declining requests is delivered '
                    'by the rentals module.',
              ),
            ],
          );
        },
      ),
    );
  }
}
