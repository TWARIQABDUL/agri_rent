import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/calculate_rental_cost.dart';
import '../../domain/usecases/create_booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/rate_option_selector.dart';

class CheckoutPage extends StatelessWidget {
  final CreateBookingParams params;

  static const _calculateRentalCost = CalculateRentalCost();

  const CheckoutPage({super.key, required this.params});

  void _submit(BuildContext context) {
    context.read<BookingBloc>().add(SubmitBookingRequest(params));
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tractor':
      case 'tractors':
        return Icons.agriculture_outlined;
      case 'pump':
      case 'pumps':
        return Icons.water_drop_outlined;
      case 'sprayer':
      case 'sprayers':
        return Icons.shower_outlined;
      case 'harvester':
      case 'harvesters':
        return Icons.grass_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _calculateRentalCost(
      rate: params.rate,
      duration: params.duration,
    );
    final unit = rateUnitLabel(params.rateType);
    final startDate = params.startDate;
    final formattedDate =
        '${startDate.day.toString().padLeft(2, '0')}/'
        '${startDate.month.toString().padLeft(2, '0')}/'
        '${startDate.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingSuccess) {
              debugPrint(
                '[AgriRent] Booking created in Firestore -> '
                'id: ${state.booking.id}, '
                'equipment: ${state.booking.equipmentName}, '
                'farmerId: ${state.booking.farmerId}, '
                'status: ${state.booking.status}, '
                'total: ${state.booking.total}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primaryDark,
                  content: Text(
                    'Booking request sent! You\'ll be notified once the owner responds.',
                  ),
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (state is BookingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Could not send request: ${state.message}'),
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is BookingSubmitting;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                        params.equipment.category
                                            .toLowerCase()
                                            .contains('tractor')
                                        ? Padding(
                                            padding: const EdgeInsets.all(7),
                                            child: SvgPicture.asset(
                                              'assets/images/tractor.svg',
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : Icon(
                                            _iconForCategory(
                                              params.equipment.category,
                                            ),
                                            color: AppColors.primaryDark,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          params.equipment.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${params.equipment.category}'
                                          '${params.equipment.ownerName.isNotEmpty ? ' • by ${params.equipment.ownerName}' : ''}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _row('Duration', '${params.duration} $unit${params.duration > 1 ? 's' : ''}'),
                              const SizedBox(height: 8),
                              _row('Start date', formattedDate),
                              const SizedBox(height: 8),
                              _row(
                                'RWF ${params.rate.toInt()} × ${params.duration} $unit${params.duration > 1 ? 's' : ''}',
                                'RWF ${breakdown.subtotal.toInt()}',
                              ),
                              const SizedBox(height: 8),
                              _row(
                                'Service fee (${(CalculateRentalCost.serviceFeeRate * 100).toInt()}%)',
                                'RWF ${breakdown.serviceFee.toInt()}',
                              ),
                              const Divider(height: 24),
                              _row(
                                'Total',
                                'RWF ${breakdown.total.toInt()}',
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isSubmitting ? null : () => _submit(context),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              'Confirm Request to Rent • RWF ${breakdown.total.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 16 : 13,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(
            color: isTotal ? AppColors.primaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
