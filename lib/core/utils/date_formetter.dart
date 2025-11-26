import 'package:intl/intl.dart';

class DateFormatter {
  // Format date as dd MMM yyyy (e.g., 25 Nov 2024)
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format date as dd/MM/yyyy
  static String formatSlash(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date as full (e.g., Monday, 25 November 2024)
  static String formatFull(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy').format(date);
  }

  // Format time as hh:mm a (e.g., 02:30 PM)
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // Get relative time (Today, Yesterday, etc.)
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return format(date);
    }
  }

  // Get month name
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  // Get month year (e.g., November 2024)
  static String getMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Parse string to DateTime
  static DateTime? parse(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }
}