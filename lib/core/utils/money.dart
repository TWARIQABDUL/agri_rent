/// Rwandan franc formatting.
///
/// The app ships without `intl`, and the currency it shows has no minor unit,
/// so grouping is done here rather than pulling in a locale database.
class Money {
  const Money._();

  static const String currency = 'RWF';

  /// `96500` becomes `96,500`.
  static String amount(num value) {
    final digits = value.round().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }

  /// `96500` becomes `RWF 96,500`.
  static String format(num value) => '$currency ${amount(value)}';

  /// `1240000` becomes `RWF 1.24M`, for figures that must fit a small tile.
  static String compact(num value) {
    final magnitude = value.abs();
    if (magnitude >= 1000000) {
      return '$currency ${_trim(value / 1000000)}M';
    }
    if (magnitude >= 100000) {
      return '$currency ${_trim(value / 1000)}K';
    }
    return format(value);
  }

  static String _trim(double value) {
    final text = value.toStringAsFixed(2);
    return text.endsWith('.00') ? text.substring(0, text.length - 3) : text;
  }
}
