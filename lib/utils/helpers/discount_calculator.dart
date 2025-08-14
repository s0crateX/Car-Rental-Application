/// Utility class for calculating rental discounts based on duration
/// 
/// This class implements a tiered discount system where:
/// - Short-term: 3-6 days
/// - Weekly: 7-29 days  
/// - Monthly: 30+ days
/// 
/// The system applies the highest applicable discount for the rental period.
class DiscountCalculator {
  
  /// Calculates the applicable discount percentage based on rental duration
  /// 
  /// [rentalDays] - Number of days for the rental
  /// [shortTermDiscount] - Discount percentage for 3-6 day rentals (0-50)
  /// [weeklyDiscount] - Discount percentage for 7-29 day rentals (0-50)
  /// [monthlyDiscount] - Discount percentage for 30+ day rentals (0-50)
  /// 
  /// Returns the applicable discount percentage (0-50)
  static double calculateDiscount({
    required int rentalDays,
    required double shortTermDiscount,
    required double weeklyDiscount,
    required double monthlyDiscount,
  }) {
    // Validate input parameters
    if (rentalDays < 1) return 0.0;
    
    // Ensure discount values are within valid range (0-50%)
    shortTermDiscount = _clampDiscount(shortTermDiscount);
    weeklyDiscount = _clampDiscount(weeklyDiscount);
    monthlyDiscount = _clampDiscount(monthlyDiscount);
    
    // Apply tiered discount logic
    if (rentalDays >= 30) {
      // Monthly tier (30+ days) - Apply highest of all applicable discounts
      return _getHighestDiscount([shortTermDiscount, weeklyDiscount, monthlyDiscount]);
    } else if (rentalDays >= 7) {
      // Weekly tier (7-29 days) - Apply highest of short-term and weekly
      return _getHighestDiscount([shortTermDiscount, weeklyDiscount]);
    } else if (rentalDays >= 3) {
      // Short-term tier (3-6 days) - Apply short-term discount only
      return shortTermDiscount;
    } else {
      // Less than 3 days - No discount
      return 0.0;
    }
  }
  
  /// Calculates the discount amount in currency
  /// 
  /// [basePrice] - Original rental price
  /// [discountPercentage] - Discount percentage (0-50)
  /// 
  /// Returns the discount amount
  static double calculateDiscountAmount({
    required double basePrice,
    required double discountPercentage,
  }) {
    if (basePrice <= 0 || discountPercentage <= 0) return 0.0;
    
    final clampedDiscount = _clampDiscount(discountPercentage);
    return basePrice * (clampedDiscount / 100);
  }
  
  /// Calculates the final price after applying discount
  /// 
  /// [basePrice] - Original rental price
  /// [discountPercentage] - Discount percentage (0-50)
  /// 
  /// Returns the final price after discount
  static double calculateFinalPrice({
    required double basePrice,
    required double discountPercentage,
  }) {
    final discountAmount = calculateDiscountAmount(
      basePrice: basePrice,
      discountPercentage: discountPercentage,
    );
    return basePrice - discountAmount;
  }
  
  /// Gets a user-friendly description of the applied discount
  /// 
  /// [rentalDays] - Number of days for the rental
  /// [appliedDiscount] - The discount percentage that was applied
  /// 
  /// Returns a description string
  static String getDiscountDescription({
    required int rentalDays,
    required double appliedDiscount,
  }) {
    if (appliedDiscount <= 0) {
      return 'No discount applied';
    }
    
    String tier;
    if (rentalDays >= 30) {
      tier = 'Monthly';
    } else if (rentalDays >= 7) {
      tier = 'Weekly';
    } else if (rentalDays >= 3) {
      tier = 'Short-term';
    } else {
      return 'No discount applied';
    }
    
    return '$tier discount: ${appliedDiscount.toStringAsFixed(1)}% off';
  }
  
  /// Example usage and discount scenarios
  /// 
  /// Returns a map of example scenarios for testing/documentation
  static Map<String, dynamic> getExampleScenarios() {
    return {
      'scenarios': [
        {
          'days': 2,
          'description': '2 days rental - No discount',
          'expectedDiscount': 0.0,
        },
        {
          'days': 5,
          'description': '5 days rental - Short-term discount applies',
          'expectedDiscount': 'shortTermDiscount',
        },
        {
          'days': 14,
          'description': '14 days rental - Weekly discount applies (higher than short-term)',
          'expectedDiscount': 'max(shortTermDiscount, weeklyDiscount)',
        },
        {
          'days': 45,
          'description': '45 days rental - Monthly discount applies (highest available)',
          'expectedDiscount': 'max(shortTermDiscount, weeklyDiscount, monthlyDiscount)',
        },
      ],
      'recommendations': {
        'shortTerm': '5-10%',
        'weekly': '10-15%',
        'monthly': '15-25%',
      },
    };
  }
  
  // Private helper methods
  
  /// Clamps discount percentage to valid range (0-50%)
  static double _clampDiscount(double discount) {
    return discount.clamp(0.0, 50.0);
  }
  
  /// Returns the highest discount from a list of discounts
  static double _getHighestDiscount(List<double> discounts) {
    if (discounts.isEmpty) return 0.0;
    return discounts.reduce((a, b) => a > b ? a : b);
  }
}

/// Extension on int to make discount calculations more convenient
extension DiscountCalculatorExtension on int {
  /// Calculates discount for this number of days
  double calculateRentalDiscount({
    required double shortTermDiscount,
    required double weeklyDiscount,
    required double monthlyDiscount,
  }) {
    return DiscountCalculator.calculateDiscount(
      rentalDays: this,
      shortTermDiscount: shortTermDiscount,
      weeklyDiscount: weeklyDiscount,
      monthlyDiscount: monthlyDiscount,
    );
  }
}