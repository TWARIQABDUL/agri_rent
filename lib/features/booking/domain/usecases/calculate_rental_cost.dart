import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

class RentalCostBreakdown extends Equatable {
  final double subtotal;
  final double serviceFee;
  final double total;

  const RentalCostBreakdown({
    required this.subtotal,
    required this.serviceFee,
    required this.total,
  });

  @override
  List<Object?> get props => [subtotal, serviceFee, total];
}

/// Pure calculator: rate (per hour/day/hectare) x duration, plus AgriRent's
/// flat 5% service fee, matching the pricing shown in the Figma checkout flow.
@lazySingleton
class CalculateRentalCost {
  static const double serviceFeeRate = 0.05;

  const CalculateRentalCost();

  RentalCostBreakdown call({required double rate, required int duration}) {
    final subtotal = rate * duration;
    final serviceFee = subtotal * serviceFeeRate;
    return RentalCostBreakdown(
      subtotal: subtotal,
      serviceFee: serviceFee,
      total: subtotal + serviceFee,
    );
  }
}
