import 'package:intl/intl.dart';

/// Formats a currency value for display (e.g., ₱1,234).
String formatCurrency(num amount, {String symbol = '₱', int decimalPlaces = 0}) {
  final format = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: decimalPlaces,
    locale: 'en_PH',
  );
  return format.format(amount);
}

class PriceUtils {
  /// Formats a price as currency with 2 decimal places (e.g., ₱1,234.56)
  static String formatPrice(num amount, {String symbol = '₱'}) {
    return formatCurrency(amount, symbol: symbol, decimalPlaces: 2);
  }
}
