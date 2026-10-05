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

  /// Canonicalize a phone number to the stored form.
  ///
  /// Stored values are bare 10-digit numbers, but existing rows and pasted
  /// input arrive E.164-styled (`+9779841234567`, 13 digits). Rejecting those
  /// would make the edit form unsavable for data the database already holds,
  /// so the prefix is stripped instead:
  ///
  /// * a leading `+` is always dropped;
  /// * a leading `977` is dropped only when exactly 10 digits remain, so a
  ///   hypothetical local number starting in 977 is never mangled.
  ///
  /// The result still has to pass [isValidNepaliPhone]; this only normalizes,
  /// it never validates.
  static String canonicalNepaliPhone(String raw) {
    var digits = raw.trim();
    if (digits.startsWith('+')) digits = digits.substring(1);
    if (digits.length == 13 && digits.startsWith('977')) {
      digits = digits.substring(3);
    }
    return digits;
  }

  /// Validate email address.
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Minimum password length.
  ///
  /// Supabase accepts 6+, but 8 is the floor worth teaching: short passwords
  /// fall to stuffing lists first, and HaveIBeenPwned screening (a dashboard
  /// toggle) only helps if the password has some entropy to begin with.
  static const int minPasswordLength = 8;

  /// Validate a password candidate.
  ///
  /// Length only — composition rules (`P@ssw0rd!` mandates) push users toward
  /// predictable substitutions without adding real entropy. At least
  /// [minPasswordLength] characters; empty and blank strings fail.
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
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
  /// 33 is the national maximum, not an arbitrary round number. Pokhara
  /// Metropolitan City is the largest local body in Nepal at 33 wards
  /// (Kathmandu is second at 32); the Local Government Act 2017 caps ordinary
  /// municipalities and rural municipalities at 19. So 33 accepts every ward
  /// that exists anywhere in the country, and nothing higher is a real
  /// address.
  ///
  /// This ceiling has been wrong twice. It was 36 with no basis, then 32 on the
  /// claim that KMC's 32 was the maximum — which the Pokhara seed row
  /// (ward_count 33) disproved. Both corrections are recorded rather than
  /// silently made, because a range boundary with a wrong reason attached will
  /// be "fixed" again by the next reader.
  static const int maxWard = 33;

  /// Mirrors the `ward_valid` CHECK constraint on `listings.ward`:
  ///
  ///   check (ward is null or ward ~ '^([1-9]|[12][0-9]|3[0-3])$')
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
  static final RegExp _wardPattern = RegExp(r'^(?:[1-9]|[12][0-9]|3[0-3])$');

  /// Validate a ward number: 1 to [maxWard], with no leading zero.
  ///
  /// An absent ward is legitimate, so callers check for emptiness first rather
  /// than passing an empty string here.
  static bool isValidWard(String ward) => _wardPattern.hasMatch(ward);
}
