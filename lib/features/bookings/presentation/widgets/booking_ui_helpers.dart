import 'package:flutter/material.dart';

import '../../domain/entities/booking.dart';

const bookingGreen = Color(0xFF2E7D32);
const bookingGreenDark = Color(0xFF1B5E20);
const bookingGreenTint = Color(0xFFE8F1E5);
const bookingAmber = Color(0xFFF5A623);
const bookingAmberTint = Color(0xFFFFF4D6);
const bookingRed = Color(0xFFD14343);
const bookingRedTint = Color(0xFFFDECEC);
const bookingText = Color(0xFF1A1A1A);
const bookingMuted = Color(0xFF6B7280);
const bookingBorder = Color(0xFFE5E7EB);

String formatRwf(double amount) {
  final rounded = amount.round().toString();
  final output = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final remaining = rounded.length - i;
    output.write(rounded[i]);
    if (remaining > 1 && remaining % 3 == 1) output.write(',');
  }
  return 'RWF $output';
}

String formatShortDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String formatDateRange(Booking booking) {
  if (booking.startDate.year == booking.endDate.year &&
      booking.startDate.month == booking.endDate.month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${booking.startDate.day}-${booking.endDate.day} '
        '${months[booking.startDate.month - 1]} ${booking.startDate.year}';
  }
  return '${formatShortDate(booking.startDate)} - '
      '${formatShortDate(booking.endDate)}';
}

IconData categoryIcon(String category) {
  final value = category.toLowerCase();
  if (value.contains('pump')) return Icons.water_drop_outlined;
  if (value.contains('spray')) return Icons.sanitizer_outlined;
  if (value.contains('harvest')) return Icons.grass_outlined;
  return Icons.agriculture_outlined;
}

Color statusColor(BookingStatus status) => switch (status) {
  BookingStatus.pending => bookingAmber,
  BookingStatus.accepted ||
  BookingStatus.active ||
  BookingStatus.completed => bookingGreen,
  BookingStatus.declined || BookingStatus.cancelled => bookingRed,
};

Color statusBackground(BookingStatus status) => switch (status) {
  BookingStatus.pending => bookingAmberTint,
  BookingStatus.accepted ||
  BookingStatus.active ||
  BookingStatus.completed => bookingGreenTint,
  BookingStatus.declined || BookingStatus.cancelled => bookingRedTint,
};

class EquipmentThumbnail extends StatelessWidget {
  final Booking booking;
  final double size;

  const EquipmentThumbnail({super.key, required this.booking, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      categoryIcon(booking.equipmentCategory),
      color: bookingGreenDark,
      size: size * 0.5,
    );
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bookingGreenTint,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: booking.equipmentImage.startsWith('http')
          ? Image.network(
              booking.equipmentImage,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status == BookingStatus.pending ? 'Pending' : status.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: statusBackground(status),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: statusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class BookingEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const BookingEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: bookingGreenTint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: bookingGreenDark),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: bookingText,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: bookingMuted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
