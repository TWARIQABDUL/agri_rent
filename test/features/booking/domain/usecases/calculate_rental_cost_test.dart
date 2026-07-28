import 'package:flutter_test/flutter_test.dart';
import 'package:agri_rent/features/booking/domain/usecases/calculate_rental_cost.dart';

void main() {
  const calculateRentalCost = CalculateRentalCost();

  test(
    'computes subtotal, 5% service fee, and total for a multi-day rental',
    () {
      final result = calculateRentalCost(rate: 25000, duration: 2);

      expect(result.subtotal, 50000);
      expect(result.serviceFee, 2500);
      expect(result.total, 52500);
    },
  );

  test('computes cost correctly for a single-unit rental', () {
    final result = calculateRentalCost(rate: 3500, duration: 1);

    expect(result.subtotal, 3500);
    expect(result.serviceFee, 175);
    expect(result.total, 3675);
  });

  test('scales linearly with duration', () {
    final result = calculateRentalCost(rate: 8000, duration: 5);

    expect(result.subtotal, 40000);
    expect(result.serviceFee, 2000);
    expect(result.total, 42000);
  });
}
