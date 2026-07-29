import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/booking.dart';
import '../widgets/rate_option_selector.dart';
import 'request_to_rent_page.dart';

class EquipmentDetailPage extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailPage({super.key, required this.equipment});

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  late String _selectedRateType;

  @override
  void initState() {
    super.initState();
    _selectedRateType = RateType.day;
  }

  bool get _isTractor {
    final category = widget.equipment.category.toLowerCase();
    return category == 'tractor' || category == 'tractors';
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tractor':
      case 'tractors':
        return Icons.agriculture_outlined;
      case 'pump':
      case 'pumps':
        return Icons.water_drop_outlined;
      case 'sprayer':
      case 'sprayers':
        return Icons.shower_outlined;
      case 'harvester':
      case 'harvesters':
        return Icons.grass_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  IconData _iconForSpecKey(String key) {
    switch (key.toLowerCase()) {
      case 'power':
        return Icons.bolt;
      case 'year':
        return Icons.calendar_today_outlined;
      case 'fuel':
        return Icons.local_gas_station_outlined;
      case 'weight':
        return Icons.fitness_center;
      case 'capacity':
        return Icons.speed_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _initialsFrom(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  List<RateOption> get _rateOptions => buildRateOptions(widget.equipment);

  double get _selectedRate {
    return _rateOptions
        .firstWhere((option) => option.type == _selectedRateType)
        .price;
  }

  @override
  Widget build(BuildContext context) {
    final equipment = widget.equipment;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageHeader(equipment),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _iconForCategory(equipment.category),
                                      size: 14,
                                      color: AppColors.primaryDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      equipment.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppColors.accentYellow,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        equipment.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (equipment.reviewCount > 0)
                                    Text(
                                      '${equipment.reviewCount} reviews',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            equipment.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  equipment.location.isNotEmpty
                                      ? equipment.location
                                      : 'Rwanda',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildOwnerRow(equipment),
                          if (equipment.specs.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            _buildSpecsRow(equipment),
                          ],
                          const SizedBox(height: 20),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            equipment.description.isNotEmpty
                                ? equipment.description
                                : 'No description provided by the owner yet.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Choose rental rate',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RateOptionSelector(
                            options: _rateOptions,
                            selectedType: _selectedRateType,
                            onChanged: (type) {
                              setState(() => _selectedRateType = type);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(equipment),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(Equipment equipment) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFE4EDE1)),
            child: equipment.image.isNotEmpty
                ? Image.network(
                    equipment.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryDark,
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _imageFallback(equipment),
                  )
                : _imageFallback(equipment),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _circleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    final isFavorite = state.contains(equipment.id);
                    return _circleButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorite
                          ? Colors.redAccent
                          : AppColors.textPrimary,
                      onTap: () =>
                          context.read<FavoritesCubit>().toggle(equipment),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _circleButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing coming soon.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(Equipment equipment) {
    if (_isTractor) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SvgPicture.asset(
            'assets/images/tractor.svg',
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return Center(
      child: Icon(
        _iconForCategory(equipment.category),
        size: 96,
        color: AppColors.primaryDark,
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: AppColors.white.withValues(alpha: 0.9),
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  Widget _buildOwnerRow(Equipment equipment) {
    final ownerName = equipment.ownerName.isNotEmpty
        ? equipment.ownerName
        : 'Equipment Owner';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryDark,
            child: Text(
              _initialsFrom(ownerName),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 13,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Verified Owner',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messaging coming soon.')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsRow(Equipment equipment) {
    final entries = equipment.specs.entries.toList();
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _specCard(entries[i].key, entries[i].value)),
        ],
      ],
    );
  }

  Widget _specCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(_iconForSpecKey(label), size: 20, color: AppColors.primaryDark),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Equipment equipment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total / ${rateUnitLabel(_selectedRateType)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'RWF ${_selectedRate.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RequestToRentPage(
                    equipment: equipment,
                    initialRateType: _selectedRateType,
                    initialRate: _selectedRate,
                  ),
                ),
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Request to Rent',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
