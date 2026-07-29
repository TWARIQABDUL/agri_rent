import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingModel booking);
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl(this.firestore);

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    // Collection is `rentals`, matching the deployed Firestore security
    // rules — not `bookings`; anything else falls through to those rules'
    // final catch-all and gets denied.
    final docRef = await firestore.collection('rentals').add(booking.toJson());
    final snapshot = await docRef.get();
    return BookingModel.fromFirestore(snapshot);
  }
}
