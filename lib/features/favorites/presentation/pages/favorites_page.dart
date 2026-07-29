import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/pages/equipment_detail_page.dart';
import '../../../home/presentation/widgets/equipment_card.dart';
import '../cubit/favorites_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Favorites',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        },
        builder: (context, state) {
          if (state.isLoading && state.equipment.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }
          if (state.equipment.isEmpty) {
            return const _EmptyFavorites();
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.equipment.length,
            itemBuilder: (context, index) {
              final equipment = state.equipment[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EquipmentDetailPage(equipment: equipment),
                  ),
                ),
                child: EquipmentCard(
                  equipmentId: equipment.id,
                  name: equipment.name,
                  ownerId: equipment.ownerId,
                  pricePerDay: equipment.pricePerDay,
                  location: equipment.location,
                  rating: equipment.rating,
                  type: equipment.category,
                  image: equipment.image,
                  isFavorite: true,
                  onFavoriteTap: () =>
                      context.read<FavoritesCubit>().toggle(equipment),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(32, 32, 32, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.favorite_border,
                size: 42,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the heart on equipment you want to save. It will appear here instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
