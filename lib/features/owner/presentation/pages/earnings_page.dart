import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/owner_summary.dart';
import '../../domain/entities/payout_schedule.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../widgets/activity_row.dart';
import '../widgets/earnings_hero_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/owner_card.dart';
import '../widgets/owner_states.dart';

/// Money in, money waiting, and the trail of rentals behind both.
class EarningsPage extends StatelessWidget {
  final String ownerId;

  const EarningsPage({super.key, required this.ownerId});

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
          'Earnings',
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
    final earnings = summary.earnings;

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () async => _reload(context),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          EarningsHeroCard(
            availableForPayout: earnings.availableForPayout,
            actionLabel: 'Withdraw to Bank',
            actionIcon: Icons.arrow_downward,
            onAction: () =>
                _explainPayouts(context, earnings.availableForPayout),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Lifetime earnings',
                  value: Money.compact(earnings.lifetime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricTile(
                  label: 'Pending clearance',
                  value: Money.compact(earnings.pendingClearance),
                  valueColor: AppColors.amberText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const SectionTitle(title: 'Recent activity'),
          const SizedBox(height: 4),
          if (summary.recentActivity.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No activity yet',
              message:
                  'Completed rentals and the money they bring in will appear '
                  'here.',
            )
          else
            for (var index = 0; index < summary.recentActivity.length; index++)
              Column(
                children: [
                  ActivityRow(rental: summary.recentActivity[index]),
                  if (index != summary.recentActivity.length - 1)
                    const Divider(height: 1, color: AppColors.outline),
                ],
              ),
        ],
      ),
    );
  }

  /// Payouts run on a schedule rather than on demand, so the action explains
  /// the schedule instead of pretending to move money.
  void _explainPayouts(BuildContext context, double available) {
    final nextPayout = PayoutSchedule.nextPayoutAfter(DateTime.now());

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.greenTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_outlined,
                color: AppColors.greenDeep,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payouts run automatically',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              available <= 0
                  ? 'You have nothing waiting for payout yet. Cleared earnings '
                        'are sent to your bank on ${Dates.day(nextPayout)}.'
                  : '${Money.format(available)} is cleared and will be sent to '
                        'your registered bank account on '
                        '${Dates.day(nextPayout)}. Add your bank details under '
                        'Profile to change where it goes.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reload(BuildContext context) {
    context.read<OwnerDashboardBloc>().add(
      LoadOwnerDashboard(ownerId: ownerId, silent: true),
    );
  }
}
