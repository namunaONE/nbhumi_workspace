import 'package:intl/intl.dart';

/// Formats Nepali Rupee amounts the way Nepalis read them (Rule 27).
///
/// Two formats, because two different jobs:
///
/// * [compact] for browse cards — `NPR 2.5 Cr`, `NPR 25 Lakh`. A card is about
///   180dp wide; `NPR 1,50,00,000` does not fit and forces the title to
///   truncate. WIREFRAMES.md specifies the compact form for exactly this
///   reason.
/// * [full] for the detail page and any place the exact figure matters —
///   `NPR 1,50,00,000`. Indian digit grouping, not Western: 15000000 is
///   `1,50,00,000`, never `15,000,000`.
///
/// Uses Indian lakh/crore thresholds rather than `NumberFormat.compact`, which
/// emits Western `M`/`B` abbreviations and would read as foreign on a Nepali
/// listing.
abstract final class NepaliCurrency {
  const NepaliCurrency._();

  static final NumberFormat _grouped = NumberFormat.decimalPattern('en_IN');

  /// One lakh: 100,000.
  static const int lakh = 100000;

  /// One crore: 10,000,000.
  static const int crore = 10000000;

  /// Compact form with the NPR prefix, e.g. `NPR 2.5 Cr`.
  ///
  /// Falls back to [full] below one lakh, where compacting saves nothing:
  /// `NPR 85,000` is clearer than `NPR 0.85 Lakh`.
  ///
  /// A negative amount reads `NPR -1.5 Cr`, not `-NPR 1.5 Cr`: the sign belongs
  /// to the amount, and putting it in front of the currency symbol reads as a
  /// deduction rather than a negative price.
  static String compact(int amountNpr) {
    if (amountNpr.abs() < lakh) return full(amountNpr);

    if (amountNpr.abs() >= crore) {
      final crores = amountNpr.abs() / crore;
      // One decimal only when it carries information: 2.5 Cr reads better
      // than 2.50 Cr, but 3 Cr beats 3.0 Cr.
      final croresText =
          crores >= 10 ? crores.round().toString() : _trim(crores);
      return 'NPR ${_sign(amountNpr)}$croresText Cr';
    }

    final lakhs = amountNpr.abs() / lakh;
    final lakhsText = lakhs >= 10 ? lakhs.round().toString() : _trim(lakhs);
    return 'NPR ${_sign(amountNpr)}$lakhsText Lakh';
  }

  /// Compact form without the NPR prefix, e.g. `2.5 Cr` or `-1.5 Cr`.
  static String compactBare(int amountNpr) =>
      compact(amountNpr).replaceFirst(RegExp(r'^NPR\s*'), '');

  /// Full amount with Indian grouping and the NPR prefix.
  ///
  /// `15000000` becomes `NPR 1,50,00,000`.
  static String full(int amountNpr) => 'NPR ${fullBare(amountNpr)}';

  /// Full amount with Indian grouping, no prefix.
  static String fullBare(int amountNpr) {
    final negative = amountNpr < 0;
    final digits = _grouped.format(amountNpr.abs());
    return negative ? '-$digits' : digits;
  }

  /// A leading minus sign, or nothing.
  static String _sign(int amountNpr) => amountNpr < 0 ? '-' : '';

  /// Drops a trailing `.0` so 3.0 renders as 3.
  static String _trim(double value) {
    final text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
}
