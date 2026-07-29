import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/booking_ui_helpers.dart';

class RequestDetailPage extends StatelessWidget {
  final String bookingId;
  final String ownerId;

  const RequestDetailPage({
    super.key,
    required this.bookingId,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
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
        if (error == null && loaded.notice != null) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final booking = _findBooking(state);
        if (booking == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: BookingEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Request not found',
              subtitle: 'This request may have been removed.',
            ),
          );
        }
        final isWorking =
            state is BookingLoaded && state.actionBookingId == booking.id;
        return _content(context, booking, isWorking);
      },
    );
  }

  Booking? _findBooking(BookingState state) {
    if (state is! BookingLoaded) return null;
    for (final item in state.bookings) {
      if (item.id == bookingId) return item;
    }
    return null;
  }

  Widget _content(BuildContext context, Booking booking, bool isWorking) {
    final canReview = booking.status == BookingStatus.pending;
    return Scaffold(
      key: const Key('request-detail-page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: bookingText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Request Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: bookingBorder),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
        children: [
          _farmerCard(booking),
          const SizedBox(height: 18),
          _label('Equipment'),
          const SizedBox(height: 9),
          _equipmentCard(booking),
          const SizedBox(height: 18),
          _label('Rental'),
          const SizedBox(height: 9),
          _detailsCard([
            _infoRow('Request ID', '#REQ-${booking.id.toUpperCase()}'),
            _infoRow('Dates', formatDateRange(booking)),
            _infoRow('Duration', booking.durationLabel),
            _infoRow(booking.rateLabel, formatRwf(booking.dailyRate)),
          ]),
          if (booking.renterNote.isNotEmpty) ...[
            const SizedBox(height: 18),
            _label("Renter's note"),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bookingAmberTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.renterNote,
                style: const TextStyle(
                  color: bookingText,
                  height: 1.45,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _label('Your payout'),
          const SizedBox(height: 9),
          _detailsCard([
            _infoRow('Rental subtotal', formatRwf(booking.subtotal)),
            _infoRow(
              'Platform fee (10%)',
              '- ${formatRwf(booking.subtotal * 0.10)}',
            ),
            _infoRow(
              'You receive',
              formatRwf(booking.subtotal * 0.90),
              valueColor: bookingGreen,
            ),
          ]),
        ],
      ),
      bottomNavigationBar: canReview
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          key: const Key('decline-request-button'),
                          onPressed: isWorking
                              ? null
                              : () => _review(
                                  context,
                                  booking,
                                  BookingStatus.declined,
                                ),
                          icon: const Icon(Icons.close, size: 17),
                          label: const Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: bookingRed,
                            side: const BorderSide(color: bookingRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          key: const Key('accept-request-button'),
                          onPressed: isWorking
                              ? null
                              : () => _review(
                                  context,
                                  booking,
                                  BookingStatus.accepted,
                                ),
                          icon: isWorking
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, size: 17),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bookingGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _farmerCard(Booking booking) {
    final initials = booking.farmerName
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: bookingBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: bookingGreenTint,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                color: bookingGreenDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.farmerName,
                  style: const TextStyle(
                    color: bookingText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(Icons.star, size: 13, color: bookingAmber),
                    SizedBox(width: 4),
                    Text(
                      'New rental request',
                      style: TextStyle(color: bookingMuted, fontSize: 11.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: bookingBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: bookingGreen,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipmentCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F8),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          EquipmentThumbnail(booking: booking, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.equipmentName,
                  style: const TextStyle(
                    color: bookingText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  booking.equipmentCategory,
                  style: const TextStyle(color: bookingMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          BookingStatusChip(status: booking.status),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: bookingText,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    );
  }

  Widget _detailsCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: bookingBorder),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: bookingMuted, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? bookingText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _review(BuildContext context, Booking booking, BookingStatus status) {
    context.read<BookingBloc>().add(
      BookingStatusUpdateRequested(
        bookingId: booking.id,
        ownerId: ownerId,
        status: status,
      ),
    );
  }
}
