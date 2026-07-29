import 'package:flutter/material.dart';

/// The catalogue of equipment types the marketplace supports.
///
/// [value] is what gets written to and queried from Firestore, so it must stay
/// stable. [label] is what the owner and the farmer read on screen.
class EquipmentCategory {
  final String value;
  final String label;
  final IconData icon;

  const EquipmentCategory({
    required this.value,
    required this.label,
    required this.icon,
  });

  static const tractors = EquipmentCategory(
    value: 'Tractors',
    label: 'Tractor',
    icon: Icons.agriculture_outlined,
  );

  static const pumps = EquipmentCategory(
    value: 'Pumps',
    label: 'Pump',
    icon: Icons.water_drop_outlined,
  );

  static const sprayers = EquipmentCategory(
    value: 'Sprayers',
    label: 'Sprayer',
    icon: Icons.shower_outlined,
  );

  static const harvesters = EquipmentCategory(
    value: 'Harvesters',
    label: 'Harvester',
    icon: Icons.grass_outlined,
  );

  static const List<EquipmentCategory> all = [
    tractors,
    pumps,
    sprayers,
    harvesters,
  ];

  /// Sentinel used by the browse filters; never stored on a document.
  static const anyValue = 'All';

  static EquipmentCategory? byValue(String value) {
    for (final category in all) {
      if (category.value == value) return category;
    }
    return null;
  }

  /// Falls back to the stored value so a listing created before a category was
  /// added to the catalogue still reads sensibly.
  static String labelFor(String value) => byValue(value)?.label ?? value;

  static IconData iconFor(String value) =>
      byValue(value)?.icon ?? Icons.build_outlined;
}
