import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'owner_buttons.dart';

/// Shown where a list would be, when the owner has nothing there yet.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.greenTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: AppColors.greenDeep),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.muted,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            OwnerPrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              height: 50,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when a read failed and there is nothing to display underneath.
class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetry({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.dangerTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              size: 30,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),
          OwnerSecondaryButton(
            label: 'Try again',
            emphasised: true,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
