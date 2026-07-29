import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/booking_ui_helpers.dart';
import 'request_detail_page.dart';

class RentalRequestsPage extends StatefulWidget {
  final String ownerId;

  const RentalRequestsPage({super.key, required this.ownerId});

  @override
  State<RentalRequestsPage> createState() => _RentalRequestsPageState();
}

class _RentalRequestsPageState extends State<RentalRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(
      WatchOwnerBookingsRequested(widget.ownerId),
    );
  }

  @override
  void didUpdateWidget(covariant RentalRequestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) {
      context.read<BookingBloc>().add(
        WatchOwnerBookingsRequested(widget.ownerId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: OwnerBookingGroup.values.length,
      child: Scaffold(
        key: const Key('rental-requests-page'),
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Rental Requests',
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
                return _OwnerTabBar(bookings: bookings);
              },
            ),
          ),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listenWhen: (_, current) =>
              current is BookingLoaded &&
              (current.notice != null || current.errorMessage != null),
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
                title: 'Requests unavailable',
                subtitle: state.message,
              );
            }

            final bookings = (state as BookingLoaded).bookings;
            return TabBarView(
              children: OwnerBookingGroup.values
                  .map(
                    (group) => _RequestList(
                      bookings: bookings
                          .where((item) => item.belongsToOwnerGroup(group))
                          .toList(),
                      group: group,
                      onTap: _openRequest,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  void _openRequest(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RequestDetailPage(bookingId: booking.id, ownerId: widget.ownerId),
      ),
    );
  }
}

class _OwnerTabBar extends StatelessWidget {
  final List<Booking> bookings;

  const _OwnerTabBar({required this.bookings});

  @override
  Widget build(BuildContext context) {
    const labels = ['Pending', 'Accepted', 'Declined'];
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
        tabs: List.generate(OwnerBookingGroup.values.length, (index) {
          final group = OwnerBookingGroup.values[index];
          final count = bookings
              .where((item) => item.belongsToOwnerGroup(group))
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

class _RequestList extends StatelessWidget {
  final List<Booking> bookings;
  final OwnerBookingGroup group;
  final ValueChanged<Booking> onTap;

  const _RequestList({
    required this.bookings,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      final content = switch (group) {
        OwnerBookingGroup.pending => (
          Icons.inbox_outlined,
          'No pending requests',
          'New farmer rental requests will appear here in real time.',
        ),
        OwnerBookingGroup.accepted => (
          Icons.check_circle_outline,
          'No accepted requests',
          'Requests you approve will move here automatically.',
        ),
        OwnerBookingGroup.declined => (
          Icons.cancel_outlined,
          'No declined requests',
          'Declined and farmer-cancelled requests will appear here.',
        ),
      };
      return BookingEmptyState(
        icon: content.$1,
        title: content.$2,
        subtitle: content.$3,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 124),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _RequestCard(
          key: Key('owner-request-card-${booking.id}'),
          booking: booking,
          onTap: () => onTap(booking),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _RequestCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: bookingBorder),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 13,
                              color: bookingMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                booking.farmerName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: bookingMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: bookingMuted,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${formatDateRange(booking)} · '
                                '${booking.durationLabel}',
                                style: const TextStyle(
                                  color: bookingMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BookingStatusChip(status: booking.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: bookingBorder),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatRwf(booking.subtotal),
                      style: const TextStyle(
                        color: bookingGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    booking.status == BookingStatus.pending
                        ? 'Review'
                        : 'View details',
                    style: const TextStyle(
                      color: bookingGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: bookingGreen,
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
