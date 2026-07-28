import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../booking/presentation/pages/equipment_detail_page.dart';
import '../../../equipment/presentation/bloc/equipment_bloc.dart';
import '../widgets/active_rental_banner.dart';
import '../widgets/category_chip.dart';
import '../widgets/equipment_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;

  String _initialsFrom(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // Filter States
  String _currentLocationFilter = 'Anywhere';
  double _currentMaxPriceFilter = 100000.0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Tractors', 'icon': Icons.agriculture_outlined},
    {'label': 'Pumps', 'icon': Icons.water_drop_outlined},
    {'label': 'Harvesters', 'icon': Icons.grass_outlined},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch initial equipment (All)
    context.read<EquipmentBloc>().add(
      const FetchEquipmentEvent(category: 'All'),
    );
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });

    final category = _categories[index]['label'] as String;
    context.read<EquipmentBloc>().add(
      FetchEquipmentEvent(
        category: category,
        location: _currentLocationFilter,
        maxPrice: _currentMaxPriceFilter,
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FilterBottomSheet(
            initialCategory:
                _categories[_selectedCategoryIndex]['label'] as String,
            initialLocation: _currentLocationFilter,
            initialMaxPrice: _currentMaxPriceFilter,
            onApply: (category, location, maxPrice) {
              setState(() {
                _selectedCategoryIndex = _categories.indexWhere(
                  (c) => c['label'] == category,
                );
                if (_selectedCategoryIndex == -1) _selectedCategoryIndex = 0;
                _currentLocationFilter = location;
                _currentMaxPriceFilter = maxPrice;
              });

              context.read<EquipmentBloc>().add(
                FetchEquipmentEvent(
                  category: category,
                  location: location,
                  maxPrice: maxPrice,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 100,
          ), // Padding for bottom nav overlay
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state is Authenticated ? state.user : null;
                    final name = user?.displayName?.trim().isNotEmpty == true
                        ? user!.displayName!
                        : (user?.email.split('@').first ?? 'there');
                    final initials = _initialsFrom(name);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hello, welcome 👋',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: AppColors.primaryDark,
                          radius: 24,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _currentLocationFilter = value.isEmpty
                                  ? 'Anywhere'
                                  : value;
                            });
                            // Add location filter based on search input
                            final category =
                                _categories[_selectedCategoryIndex]['label']
                                    as String;
                            context.read<EquipmentBloc>().add(
                              FetchEquipmentEvent(
                                category: category,
                                location: _currentLocationFilter,
                                maxPrice: _currentMaxPriceFilter,
                              ),
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search by location...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _openFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Categories
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return CategoryChip(
                        label: category['label'] as String,
                        icon: category['icon'] as IconData,
                        isSelected: _selectedCategoryIndex == index,
                        onTap: () => _onCategorySelected(index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Active Rental Banner
                const ActiveRentalBanner(),
                const SizedBox(height: 24),

                // Equipment Grid with BLoC Builder
                BlocBuilder<EquipmentBloc, EquipmentState>(
                  builder: (context, state) {
                    if (state is EquipmentLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    } else if (state is EquipmentError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is EquipmentLoaded) {
                      if (state.equipment.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No equipment found.'),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: state.equipment.length,
                        itemBuilder: (context, index) {
                          final equipment = state.equipment[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EquipmentDetailPage(
                                    equipment: equipment,
                                  ),
                                ),
                              );
                            },
                            child: EquipmentCard(
                              name: equipment.name,
                              ownerId: equipment.ownerId,
                              pricePerDay: equipment.pricePerDay,
                              location: equipment.location,
                              rating: equipment.rating,
                              type: equipment.category,
                              image: equipment.image,
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
