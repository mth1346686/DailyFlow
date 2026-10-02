import 'package:intl/intl.dart';

class DateUtilsHelper {
  /// Returns a nicely formatted header date string e.g. "Friday, Oct 2"
  static String getFormattedToday() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMM d').format(now);
  }

  /// Returns full date string e.g. "October 2, 2026"
  static String getFullTodayDate() {
    final now = DateTime.now();
    return DateFormat('MMMM d, yyyy').format(now);
  }
}
