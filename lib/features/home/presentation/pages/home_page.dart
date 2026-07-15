import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../equipment/presentation/bloc/equipment_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    // Fetch initial equipment (All)
    context.read<EquipmentBloc>().add(const FetchEquipmentEvent(category: 'All'));
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    
    final category = _categories[index]['label'];
    context.read<EquipmentBloc>().add(FetchEquipmentEvent(category: category));
  }

  void _seedDummyData() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    
    final items = [
      {
        'name': 'John Deere 5050D',
        'ownerId': 'Patrick M.',
        'description': 'Reliable tractor for heavy farming tasks.',
        'pricePerDay': 25000.0,
        'pricePerMonth': 600000.0,
        'status': 'available',
        'category': 'Tractors',
        'image': '',
        'location': 'Kigali',
        'rating': 4.8,
      },
      {
        'name': 'Irrigation Pump X2',
        'ownerId': 'Alice U.',
        'description': 'High capacity water pump.',
        'pricePerDay': 8000.0,
        'pricePerMonth': 200000.0,
        'status': 'available',
        'category': 'Pumps',
        'image': '',
        'location': 'Muhanga',
        'rating': 4.6,
      },
      {
        'name': 'Massey Ferguson 240',
        'ownerId': 'Eric N.',
        'description': 'Efficient and easy to use.',
        'pricePerDay': 30000.0,
        'pricePerMonth': 750000.0,
        'status': 'available',
        'category': 'Tractors',
        'image': '',
        'location': 'Kigali',
        'rating': 4.9,
      }
    ];

    for (var item in items) {
      final docRef = firestore.collection('equipment').doc();
      batch.set(docRef, item);
    }
    
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testing Equipment Added to Firestore! Refreshing...'))
      );
      // Refresh the list
      context.read<EquipmentBloc>().add(const FetchEquipmentEvent(category: 'All'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _seedDummyData,
        backgroundColor: AppColors.accentYellow,
        child: const Icon(Icons.add_box),
      ),
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
                            child: TextField(
                              onChanged: (value) {
                                // Add location filter based on search input
                                final category = _categories[_selectedCategoryIndex]['label'];
                                context.read<EquipmentBloc>().add(FetchEquipmentEvent(
                                  category: category,
                                  location: value,
                                ));
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search by location...',
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
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.equipment.length,
                            itemBuilder: (context, index) {
                              final equipment = state.equipment[index];
                              return EquipmentCard(
                                name: equipment.name,
                                ownerId: equipment.ownerId,
                                pricePerDay: equipment.pricePerDay,
                                location: equipment.location,
                                rating: equipment.rating,
                                type: equipment.category,
                                image: equipment.image,
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
