enum PaymentMethod {
  gcash,
  paymaya,
  cash,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.gcash:
        return 'GCash';
      case PaymentMethod.paymaya:
        return 'PayMaya';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }
}
