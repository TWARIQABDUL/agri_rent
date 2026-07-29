import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../equipment/domain/entities/equipment.dart';
import '../../domain/usecases/calculate_rental_cost.dart';
import '../../domain/usecases/create_booking.dart';
import '../bloc/booking_bloc.dart';
import '../widgets/rate_option_selector.dart';
import 'checkout_page.dart';

class RequestToRentPage extends StatefulWidget {
  final Equipment equipment;
  final String initialRateType;
  final double initialRate;

  const RequestToRentPage({
    super.key,
    required this.equipment,
    required this.initialRateType,
    required this.initialRate,
  });

  @override
  State<RequestToRentPage> createState() => _RequestToRentPageState();
}

class _RequestToRentPageState extends State<RequestToRentPage> {
  late String _rateType;
  late double _rate;
  DateTime? _startDate;
  int _duration = 1;

  static const _calculateRentalCost = CalculateRentalCost();

  @override
  void initState() {
    super.initState();
    _rateType = widget.initialRateType;
    _rate = widget.initialRate;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _changeDuration(int delta) {
    setState(() {
      final next = _duration + delta;
      _duration = next < 1 ? 1 : (next > 365 ? 365 : next);
    });
  }

  void _onRateTypeChanged(String type, List<RateOption> options) {
    final option = options.firstWhere((o) => o.type == type);
    setState(() {
      _rateType = type;
      _rate = option.price;
    });
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

  void _continueToCheckout() {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a start date.')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to request a rental.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<BookingBloc>(),
          child: CheckoutPage(
            params: CreateBookingParams(
              equipment: widget.equipment,
              farmerId: authState.user.id,
              rateType: _rateType,
              rate: _rate,
              duration: _duration,
              startDate: _startDate!,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = buildRateOptions(widget.equipment);
    final breakdown = _calculateRentalCost(rate: _rate, duration: _duration);
    final unit = rateUnitLabel(_rateType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Request to Rent',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        widget.equipment.category.toLowerCase().contains(
                          'tractor',
                        )
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.asset(
                              'assets/images/tractor.svg',
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            _iconForCategory(widget.equipment.category),
                            color: AppColors.primaryDark,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.equipment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.equipment.category}'
                          '${widget.equipment.ownerName.isNotEmpty ? ' • by ${widget.equipment.ownerName}' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose rate',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              RateOptionSelector(
                options: options,
                selectedType: _rateType,
                onChanged: (type) => _onRateTypeChanged(type, options),
              ),
              const SizedBox(height: 24),
              const Text(
                'Start date',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _startDate == null
                            ? 'dd/mm/yyyy'
                            : '${_startDate!.day.toString().padLeft(2, '0')}/'
                                  '${_startDate!.month.toString().padLeft(2, '0')}/'
                                  '${_startDate!.year}',
                        style: TextStyle(
                          color: _startDate == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Duration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Number of ${unit}s',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    _stepperButton(Icons.remove, () => _changeDuration(-1)),
                    SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          '$_duration',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    _stepperButton(Icons.add, () => _changeDuration(1)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _summaryRow(
                      'RWF ${_rate.toInt()} × $_duration $unit${_duration > 1 ? 's' : ''}',
                      'RWF ${breakdown.subtotal.toInt()}',
                    ),
                    const SizedBox(height: 10),
                    _summaryRow(
                      'Service fee (${(CalculateRentalCost.serviceFeeRate * 100).toInt()}%)',
                      'RWF ${breakdown.serviceFee.toInt()}',
                    ),
                    const Divider(height: 24),
                    _summaryRow(
                      'Total',
                      'RWF ${breakdown.total.toInt()}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
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
                  onPressed: _continueToCheckout,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Checkout',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryDark, size: 18),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
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
