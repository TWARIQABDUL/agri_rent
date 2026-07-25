import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Filled green action, the primary button on every owner screen.
class OwnerPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  /// Renders in the muted style of the design's disabled state while still
  /// accepting a tap, so pressing it can explain what is missing instead of
  /// doing nothing.
  final bool inactive;

  final double height;

  const OwnerPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.busy = false,
    this.inactive = false,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final background = inactive ? AppColors.outline : AppColors.green;
    final foreground = inactive ? AppColors.muted : AppColors.white;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background,
          disabledForegroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: foreground,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 19),
                    const SizedBox(width: 8),
                  ],
                  // Flexible so a long label or a large text scale shortens the
                  // text instead of overflowing the button.
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined action. [emphasised] gives it the green border the design uses for
/// the more important of two side-by-side choices.
class OwnerSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool emphasised;
  final bool busy;
  final double height;

  const OwnerSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.emphasised = false,
    this.busy = false,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = emphasised ? AppColors.green : AppColors.ink;

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: AppColors.muted,
          backgroundColor: AppColors.white,
          side: BorderSide(
            color: emphasised ? AppColors.green : AppColors.outline,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: busy
            ? SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
