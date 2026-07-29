import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/booking_ui_helpers.dart';

class RentalDetailPage extends StatelessWidget {
  final String bookingId;
  final String farmerId;

  const RentalDetailPage({
    super.key,
    required this.bookingId,
    required this.farmerId,
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
        if (error == null && loaded.notice?.contains('cancelled') == true) {
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
              title: 'Booking not found',
              subtitle: 'This request may have been cancelled or removed.',
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
    return Scaffold(
      key: const Key('rental-detail-page'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: bookingText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Rental Detail',
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
          _equipmentCard(booking),
          const SizedBox(height: 18),
          _statusTracking(booking),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Booking Info',
            children: [
              _infoRow('Booking ID', '#AGR-${booking.id.toUpperCase()}'),
              _infoRow('Rental dates', formatDateRange(booking)),
              _infoRow('Duration', booking.durationLabel),
              _infoRow('Owner', booking.ownerName),
              _infoRow('Payment', booking.paymentMethod),
              _infoRow(
                'Total paid',
                formatRwf(booking.totalAmount),
                valueColor: bookingGreen,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: booking.status == BookingStatus.pending
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    key: const Key('cancel-booking-button'),
                    onPressed: isWorking
                        ? null
                        : () => _confirmCancellation(context, booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: bookingRed,
                      side: const BorderSide(color: bookingRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: isWorking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Cancel Request',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _equipmentCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F8),
        border: Border.all(color: bookingBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          EquipmentThumbnail(booking: booking, size: 58),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.equipmentName,
                  style: const TextStyle(
                    color: bookingText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.equipmentCategory} · by ${booking.ownerName}',
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

  Widget _statusTracking(Booking booking) {
    final accepted =
        booking.status == BookingStatus.accepted ||
        booking.status == BookingStatus.active ||
        booking.status == BookingStatus.completed;
    final active =
        booking.status == BookingStatus.active ||
        booking.status == BookingStatus.completed;
    final completed = booking.status == BookingStatus.completed;
    final failed =
        booking.status == BookingStatus.declined ||
        booking.status == BookingStatus.cancelled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Tracking',
          style: TextStyle(fontWeight: FontWeight.w800, color: bookingText),
        ),
        const SizedBox(height: 12),
        _timelineStep(
          title: 'Booking requested',
          subtitle: 'Your request was sent to the owner.',
          complete: true,
          isLast: false,
        ),
        _timelineStep(
          title: failed ? booking.status.label : 'Approved by owner',
          subtitle: failed
              ? 'This request will not proceed.'
              : accepted
              ? 'The owner accepted your request.'
              : 'Waiting for the owner to confirm.',
          complete: accepted || failed,
          isLast: false,
          failed: failed,
        ),
        _timelineStep(
          title: 'In use',
          subtitle: 'Equipment picked up and in service.',
          complete: active,
          isLast: false,
        ),
        _timelineStep(
          title: 'Completed',
          subtitle: 'Equipment returned and rental closed.',
          complete: completed,
          isLast: true,
        ),
      ],
    );
  }

  Widget _timelineStep({
    required String title,
    required String subtitle,
    required bool complete,
    required bool isLast,
    bool failed = false,
  }) {
    final color = failed
        ? bookingRed
        : complete
        ? bookingGreen
        : bookingBorder;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: complete || failed
                      ? Icon(
                          failed ? Icons.close : Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: failed ? bookingRed : bookingText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: bookingMuted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: bookingBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: bookingText,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
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

  Future<void> _confirmCancellation(
    BuildContext context,
    Booking booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: const Text(
          'The pending booking will be permanently removed. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Request'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: bookingRed),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<BookingBloc>().add(
      BookingDeleteRequested(bookingId: booking.id, farmerId: farmerId),
    );
  }
}
