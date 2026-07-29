import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Stream<List<BookingModel>> watchFarmerBookings(String farmerId);

  Stream<List<BookingModel>> watchOwnerBookings(String ownerId);

  Future<void> updateBookingStatus({
    required String bookingId,
    required String ownerId,
    required BookingStatus status,
  });

  Future<void> deleteBooking({
    required String bookingId,
    required String farmerId,
  });
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _rentals =>
      firestore.collection('rentals');

  @override
  Stream<List<BookingModel>> watchFarmerBookings(String farmerId) {
    return _rentals
        .where('renterId', isEqualTo: farmerId)
        .snapshots()
        .map(_mapAndSort);
  }

  @override
  Stream<List<BookingModel>> watchOwnerBookings(String ownerId) {
    return _rentals
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(_mapAndSort);
  }

  List<BookingModel> _mapAndSort(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final bookings = snapshot.docs.map(BookingModel.fromFirestore).toList();
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required String ownerId,
    required BookingStatus status,
  }) async {
    if (status != BookingStatus.accepted && status != BookingStatus.declined) {
      throw ArgumentError.value(
        status,
        'status',
        'Owners can only accept or decline pending requests.',
      );
    }

    final reference = _rentals.doc(bookingId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw StateError('This booking request no longer exists.');
      }

      final data = snapshot.data() ?? const <String, dynamic>{};
      if (data['ownerId'] != ownerId) {
        throw StateError('You can only manage requests for your equipment.');
      }
      if (BookingStatus.fromValue(data['status']) != BookingStatus.pending) {
        throw StateError('Only pending requests can be changed.');
      }

      transaction.update(reference, {
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> deleteBooking({
    required String bookingId,
    required String farmerId,
  }) async {
    final reference = _rentals.doc(bookingId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? const <String, dynamic>{};
      if (data['renterId'] != farmerId) {
        throw StateError('You can only cancel your own booking request.');
      }
      if (BookingStatus.fromValue(data['status']) != BookingStatus.pending) {
        throw StateError('Only pending requests can be cancelled.');
      }
      transaction.delete(reference);
    });
  }
}
