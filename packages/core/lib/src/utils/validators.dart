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

  /// Validate ward number (1-36 for municipalities).
  static bool isValidWard(String ward) {
    final number = int.tryParse(ward);
    return number != null && number >= 1 && number <= 36;
  }
}
