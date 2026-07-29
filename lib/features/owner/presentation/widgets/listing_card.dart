import 'package:flutter/material.dart';

import '../../../../core/constants/equipment_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../equipment/domain/entities/equipment.dart';
import 'owner_buttons.dart';
import 'owner_card.dart';
import 'status_pill.dart';

/// One machine on the owner's shelf, with the two actions the design gives it:
/// take it off the market, or change its details.
class ListingCard extends StatelessWidget {
  final Equipment listing;
  final bool busy;
  final VoidCallback onTogglePaused;
  final VoidCallback onEdit;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTogglePaused,
    required this.onEdit,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final paused = listing.isPaused;

    return OwnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EquipmentThumb(
                icon: EquipmentCategory.iconFor(listing.category),
                imageUrl: listing.image,
              ),
              const SizedBox(width: 14),
              Expanded(child: _details()),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: 14),
          _footer(paused),
        ],
      ),
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                listing.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            listing.isPaused
                ? const StatusPill.paused()
                : const StatusPill.listed(),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '${EquipmentCategory.labelFor(listing.category)} · '
          '${listing.location.isEmpty ? 'Rwanda' : listing.location}',
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Money.format(listing.pricePerDay),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.green,
              ),
            ),
            const Text(
              ' / day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footer(bool paused) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 15,
          color: AppColors.muted,
        ),
        const SizedBox(width: 6),
        Text(
          '${listing.bookingCount}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const Text(
          ' bookings',
          style: TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(width: 14),
        const Icon(Icons.star, size: 15, color: AppColors.amber),
        const SizedBox(width: 5),
        Text(
          listing.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const Spacer(),
        OwnerSecondaryButton(
          label: paused ? 'Activate' : 'Pause',
          emphasised: paused,
          busy: busy,
          onPressed: onTogglePaused,
        ),
        const SizedBox(width: 10),
        OwnerSecondaryButton(
          label: 'Edit',
          emphasised: !paused,
          onPressed: busy ? null : onEdit,
        ),
      ],
    );
  }
}
