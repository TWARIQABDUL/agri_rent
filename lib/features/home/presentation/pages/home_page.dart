import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/active_rental_banner.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/equipment_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  final List<Map<String, String>> _categories = [
    {'label': 'All', 'icon': '🗂️'},
    {'label': 'Tractors', 'icon': '🚜'},
    {'label': 'Pumps', 'icon': '💧'},
    {'label': 'Harvesters', 'icon': '🌾'},
  ];

  final List<Map<String, dynamic>> _equipmentList = [
    {
      'title': 'John Deere 5050D',
      'owner': 'Patrick M.',
      'price': 'RWF 25,000/day',
      'rating': '4.8',
      'type': 'Tractor',
      'emoji': '🚜',
    },
    {
      'title': 'Massey Ferguson 240',
      'owner': 'Eric N.',
      'price': 'RWF 30,000/day',
      'rating': '4.9',
      'type': 'Tractor',
      'emoji': '🚜',
    },
    {
      'title': 'Irrigation Pump X2',
      'owner': 'Alice U.',
      'price': 'RWF 8,000/day',
      'rating': '4.6',
      'type': 'Pump',
      'emoji': '💧',
    },
    {
      'title': 'Knapsack Sprayer',
      'owner': 'Claudine M.',
      'price': 'RWF 3,500/day',
      'rating': '4.7',
      'type': 'Sprayer',
      'emoji': '🎒',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Padding for bottom nav
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, welcome 👋',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Jean Bosco',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: AppColors.primaryDark,
                          radius: 24,
                          child: const Text(
                            'JB',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
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
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Search equipment...',
                                hintStyle: TextStyle(color: AppColors.textSecondary),
                                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.tune, color: AppColors.white),
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
                            label: category['label']!,
                            icon: category['icon']!,
                            isSelected: _selectedCategoryIndex == index,
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Active Rental Banner
                    const ActiveRentalBanner(),
                    const SizedBox(height: 24),

                    // Equipment Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _equipmentList.length,
                      itemBuilder: (context, index) {
                        final equipment = _equipmentList[index];
                        return EquipmentCard(
                          title: equipment['title'],
                          owner: equipment['owner'],
                          price: equipment['price'],
                          rating: equipment['rating'],
                          type: equipment['type'],
                          emoji: equipment['emoji'],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNav(
                currentIndex: _currentNavIndex,
                onTap: (index) {
                  setState(() {
                    _currentNavIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
