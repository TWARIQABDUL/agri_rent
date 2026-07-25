import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/owner_rental.dart';

/// One movement on the earnings trail. Completed rentals read as money in;
/// rentals still running read as money on the way.
class ActivityRow extends StatelessWidget {
  final OwnerRental rental;

  const ActivityRow({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final cleared = rental.isCompleted;
    final wellColor = cleared ? AppColors.greenTint : AppColors.amberTint;
    final iconColor = cleared ? AppColors.greenDeep : AppColors.amberText;
    final amountColor = cleared ? AppColors.green : AppColors.amberText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: wellColor, shape: BoxShape.circle),
            child: Icon(
              cleared ? Icons.arrow_upward : Icons.schedule,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rental · ${rental.equipmentName}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${rental.renterName} · ${Dates.day(rental.endDate)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+ ${Money.amount(rental.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
