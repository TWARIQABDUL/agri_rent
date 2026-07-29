import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The white outlined surface every owner screen is built from.
class OwnerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const OwnerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.outline, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );

    if (onTap == null) return surface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: surface,
    );
  }
}

/// Section heading with an optional trailing action, as used above every list.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rounded well holding a category icon, standing in until listing photos are
/// uploaded to storage.
class EquipmentThumb extends StatelessWidget {
  final IconData icon;
  final String? imageUrl;
  final double size;

  const EquipmentThumb({
    super.key,
    required this.icon,
    this.imageUrl,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 4.5);
    final url = imageUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? Icon(icon, color: AppColors.greenDeep, size: size * 0.42)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Icon(icon, color: AppColors.greenDeep, size: size * 0.42),
            ),
    );
  }
}
