import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../../../main_shell/farmer_navigation_cubit.dart';
import '../../../wallet/presentation/pages/top_up_wallet_page.dart';

class InsufficientBalancePage extends StatelessWidget {
  final double amountDue;
  final double availableBalance;

  const InsufficientBalancePage({
    super.key,
    required this.amountDue,
    required this.availableBalance,
  });

  @override
  Widget build(BuildContext context) {
    final shortfall = amountDue - availableBalance;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Payment Failed',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: Color(0xFFFFA51F),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.white,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Insufficient Balance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your AgriRent Wallet doesn\'t have enough funds to complete this booking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _amountRow('Amount due', amountDue),
                          const SizedBox(height: 10),
                          _amountRow('Wallet balance', availableBalance),
                          const Divider(height: 26),
                          _amountRow(
                            'Shortfall',
                            shortfall,
                            valueColor: AppColors.amber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.amberTint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Top up your AgriRent Wallet to cover the shortfall, then complete your booking.',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TopUpWalletPage(),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Top Up Wallet',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: () {
                        context.read<FarmerNavigationCubit>().select(2);
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.green,
                      ),
                      label: const Text(
                        'Go to Wallet',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<FarmerNavigationCubit>().select(0);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(
    String label,
    double value, {
    Color valueColor = AppColors.textPrimary,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            Money.format(value),
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
          ),
        ),
      ],
    );
  }
}
