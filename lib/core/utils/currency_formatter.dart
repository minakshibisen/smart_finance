import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format currency
  static String format(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '$symbol${formatter.format(amount)}';
  }

  // Format without decimals
  static String formatWithoutDecimals(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '$symbol${formatter.format(amount)}';
  }

  // Format compact (1K, 1M, etc.)
  static String formatCompact(double amount, {String symbol = '₹'}) {
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  // Parse string to double
  static double parse(String value) {
    try {
      return double.parse(value.replaceAll(',', ''));
    } catch (e) {
      return 0.0;
    }
  }
}