/// Area conversion utilities for Nepal.
///
/// Supports both hill region (ropani/aana/paisa/dam) and
/// terai region (bigha/kattha/dhur) units.
class AreaConverter {
  AreaConverter._();

  // Hill region conversions (to sqm)
  static const double _ropaniToSqm = 5476;
  static const double _aanaToSqm = 342.25;
  static const double _paisaToSqm = 85.56;
  static const double _damToSqm = 21.4;

  // Terai region conversions (to sqm)
  static const double _bighaToSqm = 6772.63;
  static const double _katthaToSqm = 338.63;
  static const double _dhurToSqm = 16.93;

  /// Convert hill region units to square meters.
  static double hillToSqm({
    int ropani = 0,
    int aana = 0,
    int paisa = 0,
    int dam = 0,
  }) {
    return (ropani * _ropaniToSqm) +
        (aana * _aanaToSqm) +
        (paisa * _paisaToSqm) +
        (dam * _damToSqm);
  }

  /// Convert terai region units to square meters.
  static double teraiToSqm({
    int bigha = 0,
    int kattha = 0,
    int dhur = 0,
  }) {
    return (bigha * _bighaToSqm) +
        (kattha * _katthaToSqm) +
        (dhur * _dhurToSqm);
  }

  /// Format area for display in hill region units.
  static String formatHill(double sqm) {
    final ropani = (sqm / _ropaniToSqm).floor();
    final remainingAfterRopani = sqm - (ropani * _ropaniToSqm);
    final aana = (remainingAfterRopani / _aanaToSqm).floor();
    final remainingAfterAana = remainingAfterRopani - (aana * _aanaToSqm);
    final paisa = (remainingAfterAana / _paisaToSqm).floor();
    final dam = ((remainingAfterAana - (paisa * _paisaToSqm)) / _damToSqm)
        .floor();

    final parts = <String>[];
    if (ropani > 0) parts.add('$ropani ropani');
    if (aana > 0) parts.add('$aana aana');
    if (paisa > 0) parts.add('$paisa paisa');
    if (dam > 0) parts.add('$dam dam');
    return parts.isEmpty ? '0 ropani' : parts.join(', ');
  }

  /// Format area for display in terai region units.
  static String formatTerai(double sqm) {
    final bigha = (sqm / _bighaToSqm).floor();
    final remainingAfterBigha = sqm - (bigha * _bighaToSqm);
    final kattha = (remainingAfterBigha / _katthaToSqm).floor();
    final dhur =
        ((remainingAfterBigha - (kattha * _katthaToSqm)) / _dhurToSqm)
            .floor();

    final parts = <String>[];
    if (bigha > 0) parts.add('$bigha bigha');
    if (kattha > 0) parts.add('$kattha kattha');
    if (dhur > 0) parts.add('$dhur dhur');
    return parts.isEmpty ? '0 bigha' : parts.join(', ');
  }
}
