import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/owner_summary.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_listings_bloc.dart';
import '../widgets/active_rental_tile.dart';
import '../widgets/earnings_hero_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/owner_buttons.dart';
import '../widgets/owner_card.dart';
import '../widgets/owner_states.dart';
import 'add_equipment_page.dart';

/// What the owner sees first: the money, the machines that are out, and the
/// shortest path to listing another one.
class OwnerDashboardPage extends StatelessWidget {
  final String ownerId;
  final String ownerName;

  /// Jumps the shell to another tab, so the dashboard can hand off to Listings
  /// or Earnings without stacking a second copy of them on the navigator.
  final ValueChanged<int> onOpenTab;

  const OwnerDashboardPage({
    super.key,
    required this.ownerId,
    required this.ownerName,
    required this.onOpenTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              ownerName,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 72,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
        builder: (context, state) {
          if (state is OwnerDashboardLoading ||
              state is OwnerDashboardInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }

          if (state is OwnerDashboardError) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
              child: ErrorRetry(
                message: state.message,
                onRetry: () => _reload(context),
              ),
            );
          }

          return _loaded(context, (state as OwnerDashboardLoaded).summary);
        },
      ),
    );
  }

  Widget _loaded(BuildContext context, OwnerSummary summary) {
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () async => _reload(context),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          EarningsHeroCard(
            availableForPayout: summary.earnings.availableForPayout,
            actionLabel: 'View earnings',
            actionIcon: Icons.trending_up,
            onAction: () => onOpenTab(3),
          ),
          const SizedBox(height: 16),
          _counters(summary),
          const SizedBox(height: 24),
          _quickActions(context),
          const SizedBox(height: 26),
          SectionTitle(
            title: 'Out on rent',
            actionLabel: summary.activeRentals.isEmpty ? null : 'Requests',
            onAction: () => onOpenTab(2),
          ),
          const SizedBox(height: 12),
          if (summary.activeRentals.isEmpty)
            const EmptyState(
              icon: Icons.agriculture_outlined,
              title: 'Nothing is out right now',
              message:
                  'When a farmer books one of your machines it shows up here '
                  'with the return date.',
            )
          else
            for (final rental in summary.activeRentals)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActiveRentalTile(rental: rental),
              ),
        ],
      ),
    );
  }

  Widget _counters(OwnerSummary summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Out on rent',
                value: '${summary.activeRentalCount}',
                icon: Icons.local_shipping_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'New requests',
                value: '${summary.pendingRequestCount}',
                icon: Icons.inbox_outlined,
                valueColor: summary.pendingRequestCount > 0
                    ? AppColors.amberText
                    : AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Listed',
                value: '${summary.listedCount}',
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Paused',
                value: '${summary.pausedCount}',
                icon: Icons.pause_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricTile(
          label: 'Pending clearance',
          value: Money.format(summary.earnings.pendingClearance),
          icon: Icons.hourglass_bottom,
          valueColor: AppColors.amberText,
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OwnerPrimaryButton(
          label: 'Add new equipment',
          icon: Icons.add,
          onPressed: () => _openForm(context),
        ),
        const SizedBox(height: 12),
        OwnerSecondaryButton(
          label: 'Manage my listings',
          height: 54,
          onPressed: () => onOpenTab(1),
        ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final saved = await AddEquipmentPage.push(context, ownerId: ownerId);
    if (saved != true || !context.mounted) return;
    _reload(context);
  }

  void _reload(BuildContext context) {
    context.read<OwnerDashboardBloc>().add(
      LoadOwnerDashboard(ownerId: ownerId, silent: true),
    );
    context.read<OwnerListingsBloc>().add(
      LoadOwnerListings(ownerId, silent: true),
    );
  }
}
