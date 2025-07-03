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

  /// Calculates the rental price for a given period (supports custom periods like '5d')
  static double calculateRentalPrice({
    required dynamic car, // Should have .price, .price6h, .price12h, .price1d, .price1w, .price1m
    required String period,
  }) {
    // Multipliers should match those in rental_duration_selector.dart
    const Map<String, double> priceMultipliers = {
      '6h': 0.35,
      '12h': 0.6,
      '1d': 1.0,
      '1w': 6.3,
      '1m': 24.0,
    };

    // Use Firebase prices if available for fixed periods
    switch (period) {
      case '6h':
        return double.tryParse(car.price6h?.toString() ?? '') ?? (car.price * priceMultipliers['6h']!);
      case '12h':
        return double.tryParse(car.price12h?.toString() ?? '') ?? (car.price * priceMultipliers['12h']!);
      case '1d':
        return double.tryParse(car.price1d?.toString() ?? '') ?? (car.price * priceMultipliers['1d']!);
      case '1w':
        return double.tryParse(car.price1w?.toString() ?? '') ?? (car.price * priceMultipliers['1w']!);
      case '1m':
        return double.tryParse(car.price1m?.toString() ?? '') ?? (car.price * priceMultipliers['1m']!);
    }

    // Custom period e.g. "5d"
    final customPeriodRegex = RegExp(r'^(\d+)d');
    final match = customPeriodRegex.firstMatch(period);
    if (match != null) {
      final days = int.parse(match.group(1) ?? '0');
      double basePrice = double.tryParse(car.price?.toString() ?? '') ?? 0;
      double dailyRate = basePrice * (priceMultipliers['1d'] ?? 1.0);
      double totalPrice = days * dailyRate;

      // Bulk discount
      if (days >= 30) {
        totalPrice *= 0.8; // 20% off
      } else if (days >= 7) {
        totalPrice *= 0.9; // 10% off
      } else if (days >= 3) {
        totalPrice *= 0.95; // 5% off
      }
      return totalPrice;
    }

    // Fallback to daily rate
    double basePrice = double.tryParse(car.price?.toString() ?? '') ?? 0;
    return basePrice * (priceMultipliers['1d'] ?? 1.0);
  }
}
