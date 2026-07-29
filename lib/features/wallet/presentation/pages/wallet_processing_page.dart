import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/money.dart';
import '../cubit/wallet_cubit.dart';

class WalletProcessingPage extends StatefulWidget {
  final double amount;

  const WalletProcessingPage({super.key, required this.amount});

  @override
  State<WalletProcessingPage> createState() => _WalletProcessingPageState();
}

class _WalletProcessingPageState extends State<WalletProcessingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  Future<void> _process() async {
    try {
      await context.read<WalletCubit>().topUp(widget.amount);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Top-up failed. Please try again.')),
      );
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    color: AppColors.green,
                    backgroundColor: AppColors.greenTint,
                    strokeWidth: 9,
                  ),
                ),
                const SizedBox(height: 44),
                Text(
                  Money.format(widget.amount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Topping up your wallet',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Securely processing your transaction.\nThis only takes a moment…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 34),
                const _ProgressStep(
                  label: 'Request received',
                  isComplete: true,
                ),
                const _ProgressStep(label: 'Confirming payment'),
                const _ProgressStep(label: 'Updating wallet'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool isComplete;

  const _ProgressStep({required this.label, this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            size: 22,
            color: isComplete ? AppColors.green : AppColors.outline,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isComplete ? FontWeight.w700 : FontWeight.w500,
                color: isComplete
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
