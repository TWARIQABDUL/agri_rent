import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/owner_listings_bloc.dart';
import '../widgets/listing_card.dart';
import '../widgets/owner_states.dart';
import 'add_equipment_page.dart';

/// The owner's shelf: every machine they have published, live or paused.
class MyListingsPage extends StatelessWidget {
  final String ownerId;

  const MyListingsPage({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Listings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _addButton(context),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: BlocConsumer<OwnerListingsBloc, OwnerListingsState>(
        listener: (context, state) {
          if (state is OwnerListingsLoaded && state.failureMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failureMessage!),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) => _body(context, state),
      ),
    );
  }

  Widget _addButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openForm(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18, color: AppColors.white),
            SizedBox(width: 6),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, OwnerListingsState state) {
    if (state is OwnerListingsLoading || state is OwnerListingsInitial) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    if (state is OwnerListingsError) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
        child: ErrorRetry(
          message: state.message,
          onRetry: () => _reload(context),
        ),
      );
    }

    final loaded = state as OwnerListingsLoaded;

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () async => _reload(context),
      child: loaded.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 120),
              children: [
                EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Nothing listed yet',
                  message:
                      'Publish a machine and farmers nearby can start booking '
                      'it. You can pause a listing whenever it is unavailable.',
                  actionLabel: 'Add equipment',
                  onAction: () => _openForm(context),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: loaded.listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final listing = loaded.listings[index];
                return ListingCard(
                  listing: listing,
                  busy: loaded.busyListingId == listing.id,
                  onTogglePaused: () => context.read<OwnerListingsBloc>().add(
                    ListingPauseToggled(ownerId: ownerId, listing: listing),
                  ),
                  onEdit: () => _openForm(context, listing: listing),
                );
              },
            ),
    );
  }

  Future<void> _openForm(BuildContext context, {Equipment? listing}) async {
    final saved = await AddEquipmentPage.push(
      context,
      ownerId: ownerId,
      listing: listing,
    );
    if (saved != true || !context.mounted) return;
    _reload(context);
  }

  /// A listing write moves both the shelf and the dashboard counters.
  void _reload(BuildContext context) {
    context.read<OwnerListingsBloc>().add(
      LoadOwnerListings(ownerId, silent: true),
    );
    context.read<OwnerDashboardBloc>().add(
      LoadOwnerDashboard(ownerId: ownerId, silent: true),
    );
  }
}
