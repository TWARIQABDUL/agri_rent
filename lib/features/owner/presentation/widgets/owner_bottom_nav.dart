import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Floating navigation for the owner workspace, matching the farmer shell's
/// green pill but carrying the owner's five destinations.
class OwnerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Draws the amber dot on the requests tab while answers are outstanding.
  final int pendingRequestCount;

  const OwnerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.pendingRequestCount = 0,
  });

  static const List<IconData> _icons = [
    Icons.grid_view_rounded,
    Icons.inventory_2_outlined,
    Icons.inbox_outlined,
    Icons.trending_up,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var index = 0; index < _icons.length; index++)
            _item(index, badged: index == 2 && pendingRequestCount > 0),
        ],
      ),
    );
  }

  Widget _item(int index, {required bool badged}) {
    final selected = currentIndex == index;
    final icon = Icon(
      _icons[index],
      color: selected ? AppColors.green : AppColors.white,
      size: 23,
    );

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: selected
            ? const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              )
            : null,
        child: badged
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  icon,
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              )
            : icon,
      ),
    );
  }
}
