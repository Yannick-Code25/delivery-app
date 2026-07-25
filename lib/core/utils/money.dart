/// Money helpers for the CFA franc.
///
/// The CFA franc has no subunit in practice, so every amount in the app is an
/// integer number of francs — never a double, which would invite rounding drift
/// on order totals.
class Money {
  Money._();

  static const currencyLabel = 'FCFA';

  /// Formats an amount as `12 500 FCFA`, grouping thousands with a non-breaking
  /// space so a price never wraps mid-number.
  static String format(int amount) => '${groupThousands(amount)} $currencyLabel';

  /// Formats without the currency label, for rows that show the unit elsewhere.
  static String groupThousands(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer(amount < 0 ? '-' : '');

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}
