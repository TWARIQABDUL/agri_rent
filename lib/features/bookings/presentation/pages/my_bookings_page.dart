import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/booking_ui_helpers.dart';
import 'rental_detail_page.dart';

class MyBookingsPage extends StatefulWidget {
  final String farmerId;

  const MyBookingsPage({super.key, required this.farmerId});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(
      WatchFarmerBookingsRequested(widget.farmerId),
    );
  }

  @override
  void didUpdateWidget(covariant MyBookingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.farmerId != widget.farmerId) {
      context.read<BookingBloc>().add(
        WatchFarmerBookingsRequested(widget.farmerId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: FarmerBookingGroup.values.length,
      child: Scaffold(
        key: const Key('my-bookings-page'),
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'My Bookings',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: bookingText,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                final bookings = state is BookingLoaded
                    ? state.bookings
                    : const <Booking>[];
                return _FarmerTabBar(bookings: bookings);
              },
            ),
          ),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listenWhen: (previous, current) {
            return current is BookingLoaded &&
                (current.notice != null || current.errorMessage != null);
          },
          listener: (context, state) {
            final loaded = state as BookingLoaded;
            final error = loaded.errorMessage;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(error ?? loaded.notice!),
                  backgroundColor: error == null ? bookingGreen : bookingRed,
                ),
              );
          },
          builder: (context, state) {
            if (state is BookingLoading || state is BookingInitial) {
              return const Center(
                child: CircularProgressIndicator(color: bookingGreen),
              );
            }
            if (state is BookingFailure) {
              return BookingEmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Bookings unavailable',
                subtitle: state.message,
              );
            }
            final bookings = (state as BookingLoaded).bookings;
            return TabBarView(
              children: FarmerBookingGroup.values
                  .map(
                    (group) => _BookingList(
                      bookings: bookings
                          .where((item) => item.belongsToFarmerGroup(group))
                          .toList(),
                      group: group,
                      onTap: _openDetails,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  void _openDetails(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RentalDetailPage(bookingId: booking.id, farmerId: widget.farmerId),
      ),
    );
  }
}

class _FarmerTabBar extends StatelessWidget {
  final List<Booking> bookings;

  const _FarmerTabBar({required this.bookings});

  @override
  Widget build(BuildContext context) {
    const labels = ['Pending', 'Active', 'History'];
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F7),
        border: Border.all(color: bookingBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: bookingGreen,
          borderRadius: BorderRadius.circular(9),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: bookingMuted,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        tabs: List.generate(FarmerBookingGroup.values.length, (index) {
          final group = FarmerBookingGroup.values[index];
          final count = bookings
              .where((item) => item.belongsToFarmerGroup(group))
              .length;
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(labels[index]),
                if (count > 0) ...[
                  const SizedBox(width: 5),
                  Text('$count', style: const TextStyle(fontSize: 10)),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final FarmerBookingGroup group;
  final ValueChanged<Booking> onTap;

  const _BookingList({
    required this.bookings,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      final content = switch (group) {
        FarmerBookingGroup.pending => (
          Icons.hourglass_empty_rounded,
          'No pending requests',
          'New rental requests will appear here while owners review them.',
        ),
        FarmerBookingGroup.active => (
          Icons.agriculture_outlined,
          'No active rentals',
          'Accepted and in-use equipment will appear here.',
        ),
        FarmerBookingGroup.history => (
          Icons.history_rounded,
          'No booking history',
          'Completed, declined, and cancelled bookings will appear here.',
        ),
      };
      return BookingEmptyState(
        icon: content.$1,
        title: content.$2,
        subtitle: content.$3,
      );
    }

    return RefreshIndicator(
      color: bookingGreen,
      onRefresh: () async {
        context.read<BookingBloc>().add(
          WatchFarmerBookingsRequested(bookings.first.farmerId),
        );
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 124),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _FarmerBookingCard(
            key: Key('farmer-booking-card-${booking.id}'),
            booking: booking,
            onTap: () => onTap(booking),
          );
        },
      ),
    );
  }
}

class _FarmerBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _FarmerBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: bookingBorder),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              EquipmentThumbnail(booking: booking, size: 54),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.equipmentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: bookingText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${booking.equipmentCategory} · by ${booking.ownerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: bookingMuted,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateRange(booking)} · '
                      '${booking.durationLabel}',
                      style: const TextStyle(
                        color: bookingMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BookingStatusChip(status: booking.status),
                  const SizedBox(height: 11),
                  Text(
                    formatRwf(booking.totalAmount),
                    style: const TextStyle(
                      color: bookingGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
