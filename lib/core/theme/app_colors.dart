import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF2E6B32); // Dark green
  static const Color primaryLight = Color(
    0xFFE8F5E9,
  ); // Light green for selected chips
  static const Color accentYellow = Color(
    0xFFF5A623,
  ); // Yellow/Orange for Track button
  static const Color background = Color(0xFFF7F9FC); // Off-white app background
  static const Color textPrimary = Color(0xFF1E1E1E); // Dark text
  static const Color textSecondary = Color(0xFF757575); // Grey text
  static const Color white = Colors.white;
  static const Color borderColor = Color(0xFFE0E0E0);

  // Values below come from the current Figma exports in designs/. The screens
  // built before those exports landed use the slightly different greens and
  // greys above; anything new should use these.
  static const Color green = Color(0xFF2E7D32);
  static const Color greenDeep = Color(0xFF1B5E20);
  static const Color greenTint = Color(0xFFE8F1E5);
  static const Color amber = Color(0xFFF5A623);
  static const Color amberTint = Color(0xFFFEF3D6);
  static const Color amberText = Color(0xFF9A7400);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF6B7280);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color danger = Color(0xFFD32F2F);
  static const Color dangerTint = Color(0xFFFDECEA);
}
