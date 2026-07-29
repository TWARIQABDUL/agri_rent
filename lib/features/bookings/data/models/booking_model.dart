import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.farmerId,
    required super.farmerName,
    required super.ownerId,
    required super.ownerName,
    required super.equipmentId,
    required super.equipmentName,
    required super.equipmentCategory,
    required super.equipmentImage,
    required super.startDate,
    required super.endDate,
    super.rateType,
    required super.durationDays,
    required super.dailyRate,
    required super.subtotal,
    required super.serviceFee,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    super.renterNote,
    super.paymentMethod,
    super.updatedAt,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return BookingModel.fromMap(document.id, document.data() ?? const {});
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    final startDate = _date(data['startDate']) ?? DateTime.now();
    final rateType = _text(data['rateType'], fallback: 'day');
    final rawDuration = _integer(data['duration'] ?? data['durationDays']);
    final duration = rawDuration != null && rawDuration > 0 ? rawDuration : 1;
    final endDate =
        _date(data['endDate']) ??
        startDate.add(_durationSpan(rateType, duration));
    final dailyRate = _number(
      data['rate'] ?? data['dailyRate'] ?? data['pricePerDay'],
    );
    final subtotal = _number(data['subtotal'], fallback: dailyRate * duration);
    final serviceFee = _number(data['serviceFee'], fallback: subtotal * 0.05);

    return BookingModel(
      id: id,
      farmerId: _text(data['farmerId'] ?? data['renterId']),
      farmerName: _text(
        data['farmerName'] ?? data['renterName'],
        fallback: 'Farmer',
      ),
      ownerId: _text(data['ownerId']),
      ownerName: _text(data['ownerName'], fallback: 'Equipment owner'),
      equipmentId: _text(data['equipmentId']),
      equipmentName: _text(
        data['equipmentName'] ?? data['name'],
        fallback: 'Farm equipment',
      ),
      equipmentCategory: _text(
        data['equipmentCategory'] ?? data['category'],
        fallback: 'Equipment',
      ),
      equipmentImage: _text(
        data['equipmentImage'] ?? data['image'] ?? data['imageUrl'],
      ),
      startDate: startDate,
      endDate: endDate,
      rateType: rateType,
      durationDays: duration,
      dailyRate: dailyRate,
      subtotal: subtotal,
      serviceFee: serviceFee,
      totalAmount: _number(
        data['totalAmount'] ?? data['total'],
        fallback: subtotal + serviceFee,
      ),
      status: BookingStatus.fromValue(data['status']),
      renterNote: _text(data['renterNote'] ?? data['note']),
      paymentMethod: _text(data['paymentMethod'], fallback: 'AgriRent Wallet'),
      createdAt: _date(data['createdAt']) ?? startDate,
      updatedAt: _date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'renterId': farmerId,
      'renterName': farmerName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'equipmentCategory': equipmentCategory,
      'equipmentImage': equipmentImage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'rateType': rateType,
      'duration': durationDays,
      'rate': dailyRate,
      'subtotal': subtotal,
      'serviceFee': serviceFee,
      'totalAmount': totalAmount,
      'paidOut': false,
      'status': status.value,
      'renterNote': renterNote,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static double _number(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _integer(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Duration _durationSpan(String rateType, int duration) {
    return switch (rateType) {
      'hour' => Duration(hours: duration),
      'hectare' => const Duration(days: 1),
      _ => Duration(days: duration),
    };
  }
}
