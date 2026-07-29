/// Short date formatting in the style the designs use: `5 Jun 2026`.
class Dates {
  const Dates._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String day(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// Collapses the shared parts of a range: `10-12 Jun 2026`, `28 May - 2 Jun
  /// 2026`, `28 Dec 2025 - 3 Jan 2026`.
  static String range(DateTime start, DateTime end) {
    if (start.year != end.year) return '${day(start)} - ${day(end)}';
    if (start.month != end.month) {
      return '${start.day} ${_months[start.month - 1]} - ${day(end)}';
    }
    if (start.day == end.day) return day(start);
    return '${start.day}-${day(end)}';
  }

  /// `2 days`, used next to a rental range.
  static String dayCount(int days) => days == 1 ? '1 day' : '$days days';
}
