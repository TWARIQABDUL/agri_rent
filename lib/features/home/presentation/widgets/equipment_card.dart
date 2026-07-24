import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EquipmentCard extends StatelessWidget {
  final String name;
  final String ownerId;
  final double pricePerDay;
  final String location;
  final double rating;
  final String type;
  final String image;

  const EquipmentCard({
    super.key,
    required this.name,
    required this.ownerId,
    required this.pricePerDay,
    required this.location,
    required this.rating,
    required this.type,
    required this.image,
  });

  String _getEmojiForType() {
    switch (type.toLowerCase()) {
      case 'tractor':
      case 'tractors':
        return '🚜';
      case 'pump':
      case 'pumps':
        return '💧';
      case 'sprayer':
      case 'sprayers':
        return '🎒';
      case 'harvester':
      case 'harvesters':
        return '🌾';
      default:
        return '🔧';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area Placeholder
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F4F8), // Light placeholder background
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getEmojiForType(),
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryDark,
                    radius: 14,
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details Area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 10,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        location.isNotEmpty ? location : 'Rwanda',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RWF ${pricePerDay.toInt()}/day',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.accentYellow,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
