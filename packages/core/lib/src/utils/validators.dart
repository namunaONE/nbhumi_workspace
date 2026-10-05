/// Input validators for nBhumi.
class Validators {
  Validators._();

  /// Validate Nepali phone number.
  ///
  /// Format: 98XXXXXXXX or 97XXXXXXXX (10 digits total).
  static bool isValidNepaliPhone(String phone) {
    final regex = RegExp(r'^(98|97)\d{8}$');
    return regex.hasMatch(phone);
  }

  /// Validate email address.
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Validate price (must be positive).
  static bool isValidPrice(int price) {
    return price > 0;
  }

  /// Validate area (must be positive).
  static bool isValidArea(double area) {
    return area > 0;
  }

  /// Highest ward number this app accepts.
  ///
  /// 32 is the national maximum, not an arbitrary round number. Kathmandu
  /// Metropolitan City is the largest local body in Nepal at 32 wards; the
  /// Local Government Act 2017 caps ordinary municipalities and rural
  /// municipalities at 19. So 32 accepts every ward that exists anywhere in the
  /// country, and nothing higher is a real address.
  ///
  /// An earlier version of this comment claimed KMC had 53 wards and that this
  /// ceiling therefore rejected valid addresses. That was wrong: KMC has 32.
  /// The number was right and the reasoning was not, which is the worst kind
  /// of wrong, because it would have justified widening a correct constraint.
  static const int maxWard = 32;

  /// Mirrors the `ward_valid` CHECK constraint on `listings.ward`:
  ///
  ///   check (ward is null or ward ~ '^([1-9]|[12][0-9]|3[0-2])$')
  ///
  /// Validating the string against that pattern rather than parsing an integer
  /// is the whole point. Two separate client/server disagreements came from
  /// parsing:
  ///
  ///   * the range was 1-36 here against 1-32 in the database, so a ward of 33
  ///     passed the wizard and was rejected with a bare 23514;
  ///   * `int.tryParse('01')` is 1, so a leading zero passed here and was
  ///     rejected there, because the constraint's pattern has no `0` branch.
  ///
  /// Client and server have to agree on the accepted set, or the user fills the
  /// form in correctly by the app's own lights and still gets a server error.
  /// Keeping the two expressions textually aligned makes that reviewable.
  static final RegExp _wardPattern = RegExp(r'^(?:[1-9]|[12][0-9]|3[0-2])$');

  /// Validate a ward number: 1 to [maxWard], with no leading zero.
  ///
  /// An absent ward is legitimate, so callers check for emptiness first rather
  /// than passing an empty string here.
  static bool isValidWard(String ward) => _wardPattern.hasMatch(ward);
}
