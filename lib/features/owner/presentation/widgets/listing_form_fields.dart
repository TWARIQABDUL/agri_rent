import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/equipment_categories.dart';
import '../../../../core/theme/app_colors.dart';

/// Bold caption above every input, as used on the Add New Equipment design.
class FieldLabel extends StatelessWidget {
  final String label;
  final String? hint;

  const FieldLabel(this.label, {super.key, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 3),
          Text(
            hint!,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

/// Text input in the project's outlined style, with the error text driven from
/// the form state rather than a [Form] validator.
class OwnerTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final TextCapitalization textCapitalization;

  const OwnerTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : null,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 15, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          color: AppColors.muted.withValues(alpha: 0.7),
        ),
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 12.5, color: AppColors.danger),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: border(AppColors.outline),
        focusedBorder: border(AppColors.green),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger),
      ),
    );
  }
}

/// The `RWF … / day` money input from the design.
class RateField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String unitLabel;
  final String? errorText;

  const RateField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.unitLabel = '/ day',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return OwnerTextField(
      controller: controller,
      hintText: '0',
      onChanged: onChanged,
      errorText: errorText,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefix: const Padding(
        padding: EdgeInsets.only(left: 16, right: 10),
        child: Text(
          'RWF',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
      ),
      suffix: Padding(
        padding: const EdgeInsets.only(left: 10, right: 16),
        child: Text(
          unitLabel,
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
      ),
    );
  }
}

/// Wrapped pill selector over the shared category catalogue.
class CategorySelector extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final category in EquipmentCategory.all)
          _chip(category, category.value == selectedValue),
      ],
    );
  }

  Widget _chip(EquipmentCategory category, bool selected) {
    return GestureDetector(
      onTap: () => onSelected(category.value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.green : AppColors.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 17,
              color: selected ? AppColors.white : AppColors.muted,
            ),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed drop zone from the design. Photo uploads to storage are not part of
/// this milestone, so it collects a link and previews it.
class PhotoLinkBox extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const PhotoLinkBox({
    super.key,
    required this.imageUrl,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              height: 168,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(
                icon: Icons.broken_image_outlined,
                title: 'That link did not load',
                subtitle: 'Tap to replace it',
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _placeholder(
      icon: Icons.image_outlined,
      title: 'Add a photo',
      subtitle: 'Paste a JPG or PNG link',
    );
  }

  Widget _placeholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: const DashedBorderPainter(),
        child: SizedBox(
          height: 168,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

  const DashedBorderPainter({
    this.color = AppColors.outline,
    this.radius = 16,
    this.dashLength = 7,
    this.gapLength = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final brush = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;

    for (final segment in outline.computeMetrics()) {
      var start = 0.0;
      while (start < segment.length) {
        final end = math.min(start + dashLength, segment.length);
        canvas.drawPath(segment.extractPath(start, end), brush);
        start = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Progress across the wizard: one bar per step plus a written position.
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final String stepTitle;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.stepCount,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var index = 0; index < stepCount; index++)
              Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index == stepCount - 1 ? 0 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? AppColors.green
                        : AppColors.outline,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Step ${currentStep + 1} of $stepCount · $stepTitle',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
