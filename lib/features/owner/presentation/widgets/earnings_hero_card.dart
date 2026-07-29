import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/payout_schedule.dart';

/// The green balance card: what the owner can take out, when it leaves, and one
/// action. The dashboard and the earnings screen share it with different calls
/// to action.
class EarningsHeroCard extends StatelessWidget {
  final double availableForPayout;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final DateTime? asOf;

  const EarningsHeroCard({
    super.key,
    required this.availableForPayout,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.asOf,
  });

  @override
  Widget build(BuildContext context) {
    final nextPayout = PayoutSchedule.nextPayoutAfter(asOf ?? DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Available for payout',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Money.format(availableForPayout),
              style: const TextStyle(
                fontSize: 34,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Next auto-payout: ${Dates.day(nextPayout)}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(actionIcon, size: 19),
                  const SizedBox(width: 10),
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
