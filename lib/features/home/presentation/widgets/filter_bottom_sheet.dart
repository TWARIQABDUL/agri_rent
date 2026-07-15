import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialCategory;
  final String? initialLocation;
  final double? initialMaxPrice;
  final Function(String category, String location, double maxPrice) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialCategory,
    this.initialLocation,
    this.initialMaxPrice,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedLocation;
  late double _maxPrice;

  final List<String> _categories = ['All', 'Tractors', 'Pumps', 'Harvesters'];
  final List<String> _locations = ['Anywhere', 'Kigali', 'Muhanga', 'Musanze', 'Rubavu'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _selectedLocation = widget.initialLocation ?? 'Anywhere';
    _maxPrice = widget.initialMaxPrice ?? 100000.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category Section
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.primaryDark,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = category);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Location Section
          const Text(
            'Distance / Location',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedLocation,
                items: _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedLocation = value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Price Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Max Price (per day)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'RWF ${_maxPrice.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 5000,
            max: 100000,
            divisions: 19,
            activeColor: AppColors.primaryDark,
            inactiveColor: AppColors.borderColor,
            label: 'RWF ${_maxPrice.toInt()}',
            onChanged: (value) {
              setState(() => _maxPrice = value);
            },
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                widget.onApply(_selectedCategory, _selectedLocation, _maxPrice);
                Navigator.pop(context);
              },
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
