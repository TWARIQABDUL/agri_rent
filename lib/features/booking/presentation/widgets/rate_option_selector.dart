import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/entities/booking.dart';

class RateOption {
  final String type;
  final String label;
  final double price;

  const RateOption({
    required this.type,
    required this.label,
    required this.price,
  });
}

/// Only offers rate types the owner has actually priced; Per Day always
/// shows since it is the one rate required on every Equipment record.
List<RateOption> buildRateOptions(Equipment equipment) {
  return [
    if (equipment.pricePerHour > 0)
      RateOption(
        type: RateType.hour,
        label: 'Per Hour',
        price: equipment.pricePerHour,
      ),
    RateOption(
      type: RateType.day,
      label: 'Per Day',
      price: equipment.pricePerDay,
    ),
    if (equipment.pricePerHectare > 0)
      RateOption(
        type: RateType.hectare,
        label: 'Per Hectare',
        price: equipment.pricePerHectare,
      ),
  ];
}

String rateUnitLabel(String rateType) {
  switch (rateType) {
    case RateType.hour:
      return 'hour';
    case RateType.hectare:
      return 'hectare';
    case RateType.day:
    default:
      return 'day';
  }
}

class RateOptionSelector extends StatelessWidget {
  final List<RateOption> options;
  final String selectedType;
  final ValueChanged<String> onChanged;

  const RateOptionSelector({
    super.key,
    required this.options,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = option.type == selectedType;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option.type),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.borderColor,
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.price.toInt().toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
