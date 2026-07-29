import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/owner_rental.dart';
import 'owner_card.dart';

/// A machine that is out with a farmer right now.
class ActiveRentalTile extends StatelessWidget {
  final OwnerRental rental;

  const ActiveRentalTile({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return OwnerCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const EquipmentThumb(icon: Icons.inventory_2_outlined, size: 52),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rental.equipmentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${rental.renterName} · '
                  '${Dates.range(rental.startDate, rental.endDate)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.format(rental.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Back ${Dates.day(rental.endDate)}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
