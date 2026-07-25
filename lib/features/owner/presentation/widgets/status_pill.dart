import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Small rounded label: solid green when a listing is live, amber tint when it
/// has been taken off the market.
class StatusPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  const StatusPill.listed({super.key})
    : label = 'Listed',
      background = AppColors.green,
      foreground = AppColors.white;

  const StatusPill.paused({super.key})
    : label = 'Paused',
      background = AppColors.amberTint,
      foreground = AppColors.amberText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
