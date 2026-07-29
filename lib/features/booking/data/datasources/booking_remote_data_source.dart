import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/domain/exceptions/wallet_exception.dart';
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
    final wallet = firestore.collection('wallets').doc(booking.farmerId);
    final rental = firestore.collection('rentals').doc();
    final walletActivity = wallet.collection('transactions').doc();
    final paidBooking = BookingModel.fromEntity(
      booking,
      id: rental.id,
      walletTransactionId: walletActivity.id,
    );

    await firestore.runTransaction((transaction) async {
      final walletSnapshot = await transaction.get(wallet);
      final available =
          (walletSnapshot.data()?['balance'] as num?)?.toDouble() ?? 0;
      if (!walletSnapshot.exists || available < booking.total) {
        throw InsufficientWalletBalanceException(
          amountDue: booking.total,
          availableBalance: available,
        );
      }

      final balanceAfter = available - booking.total;
      transaction.update(wallet, {
        'balance': balanceAfter,
        'lastTransactionId': walletActivity.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(walletActivity, {
        'userId': booking.farmerId,
        'type': WalletActivityType.rentalPayment,
        'amount': -booking.total,
        'balanceAfter': balanceAfter,
        'title': 'Rental • ${booking.equipmentName}',
        'rentalId': rental.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(rental, paidBooking.toJson());
    });

    return paidBooking;
  }
}
