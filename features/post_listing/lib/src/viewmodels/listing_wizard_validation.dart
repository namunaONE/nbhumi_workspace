import 'package:core/core.dart';

import 'listing_wizard_state.dart';

/// Per-step validation for the post-listing wizard.
///
/// A separate file from the state because it is the part worth testing
/// exhaustively: each rule corresponds to something the database or Storage
/// will reject later, and a rule the app and the server disagree on is how a
/// seller fills in a correct form and gets an error anyway.
///
/// Messages are bilingual inline rather than through [AppException], because
/// these are field-level hints attached to inputs, not failures to report
/// (Rule 36 covers the latter).
extension ListingWizardValidation on ListingWizardState {
  /// Validates [step] and returns any problems.
  StepValidation validate(WizardStep step) => switch (step) {
        WizardStep.type => _validateType(),
        WizardStep.location => _validateLocation(),
        WizardStep.specs => _validateSpecs(),
        WizardStep.price => _validatePrice(),
        WizardStep.review => const StepValidation.valid(),
      };

  /// Whether [step] may be left.
  bool canLeave(WizardStep step) => validate(step).isValid;

  /// Whether the whole wizard may be submitted.
  ///
  /// Checks every step, not just the current one, because the seller can reach
  /// review by stepping back and forth and the review step shows everything at
  /// once. Without this a listing could be submitted with a hole in it.
  bool get canSubmit => WizardStep.values
      .where((step) => step != WizardStep.review)
      .every((step) => validate(step).isValid);

  /// Validates [step] and returns the first field that is wrong.
  ///
  /// Convenience for tests and for deciding which step to jump to when
  /// submission is blocked.
  String? firstInvalidField(WizardStep step) {
    final errors = validate(step).errors;
    return errors.isEmpty ? null : errors.keys.first;
  }

  StepValidation _validateType() {
    final errors = <String, String>{};
    if (propertyType == null) {
      errors['propertyType'] = _required('Property type');
    }
    if (listingPurpose == null) {
      errors['listingPurpose'] = _required('Sale, rent or lease');
    }
    return StepValidation(errors);
  }

  StepValidation _validateLocation() {
    final errors = <String, String>{};

    if (district == null) {
      errors['district'] = _required('District');
    }

    if (city.trim().isEmpty) {
      errors['city'] = _required('City or municipality');
    }

    // Ward is optional (Rule 28) but must be in range when present. The
    // validator mirrors the ward_valid CHECK exactly, so a value this accepts
    // will not be rejected by the database.
    final wardValue = ward.trim();
    if (wardValue.isNotEmpty && !Validators.isValidWard(wardValue)) {
      errors['ward'] =
          'Ward must be a number from 1 to ${Validators.maxWard}';
    }

    errors.addAll(
      _optionalNonNegative('roadAccessFt', roadAccessFt, 'Road access'),
    );

    return StepValidation(errors);
  }

  StepValidation _validateSpecs() {
    final errors = <String, String>{};

    // Which units are required depends on the district's region (Rule 25).
    // Accepting the wrong system's numbers here is the bug this guards: 1 bigha
    // and 1 ropani differ by about 12x, so a seller who typed terai units for a
    // hill district would publish a wildly wrong size.
    if (district == null) {
      errors['district'] = _required('District');
      return StepValidation(errors);
    }

    if (!hasArea) {
      // Distinguish "you used the wrong units" from "you left it blank".
      // Both leave the applicable fields empty, but only one is a unit mix-up,
      // and telling a seller their bigha figure is invalid for a Terai district
      // when they simply have not noticed the fields changed is unhelpful.
      errors['area'] = hasAreaInWrongUnits
          ? (usesHillUnits
              ? 'This district measures area in hill units '
                  '(ropani, aana, paisa, dam), not bigha'
              : 'This district measures area in terai units '
                  '(bigha, kattha, dhur), not ropani')
          : (usesHillUnits
              ? 'Enter the area in ropani, aana, paisa or dam'
              : 'Enter the area in bigha, kattha or dhur');
      return StepValidation(errors);
    }

    if (usesHillUnits) {
      errors
        ..addAll(_optionalNonNegative('areaRopani', areaRopani, 'Ropani'))
        ..addAll(_optionalNonNegative('areaAana', areaAana, 'Aana'))
        ..addAll(_optionalNonNegative('areaPaisa', areaPaisa, 'Paisa'))
        ..addAll(_optionalNonNegative('areaDam', areaDam, 'Dam'));
    } else {
      errors
        ..addAll(_optionalNonNegative('areaBigha', areaBigha, 'Bigha'))
        ..addAll(_optionalNonNegative('areaKattha', areaKattha, 'Kattha'))
        ..addAll(_optionalNonNegative('areaDhur', areaDhur, 'Dhur'));
    }

    // Bedrooms and bathrooms are optional, but the column carries
    // CHECK (> 0), so 0 is rejected by the database. Catching it here turns a
    // server error into an inline hint.
    for (final entry in <String, String>{
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
    }.entries) {
      final parsed = _parse(entry.value);
      if (entry.value.trim().isNotEmpty &&
          (parsed == null || parsed < 1)) {
        errors[entry.key] = entry.key == 'bedrooms'
            ? 'Bedrooms must be 1 or more'
            : 'Bathrooms must be 1 or more';
      }
    }

    return StepValidation(errors);
  }

  StepValidation _validatePrice() {
    final errors = <String, String>{};

    final price = _parse(priceNpr);
    if (price == null) {
      errors['priceNpr'] = _required('Price');
    } else if (!Validators.isValidPrice(price)) {
      errors['priceNpr'] = 'Price must be more than zero';
    }

    // One photo is required so a listing is never invisible in search results.
    // A stub comment here once claimed DATA.md requires three; that file
    // is not in the repository, so the requirement is not asserted as fact.
    // Raising it to three is a product decision, not a validation fix.
    if (uploadedPhotoUrls.isEmpty) {
      errors['photos'] = 'Add at least one photo';
    }

    return StepValidation(errors);
  }

  /// Validates a non-negative optional integer field.
  Map<String, String> _optionalNonNegative(
    String field,
    String raw,
    String label,
  ) {
    if (raw.trim().isEmpty) return const <String, String>{};
    final parsed = _parse(raw);
    if (parsed == null) {
      return <String, String>{field: '$label must be a number'};
    }
    if (parsed < 0) {
      return <String, String>{field: '$label cannot be negative'};
    }
    return const <String, String>{};
  }

  static int? _parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  static String _required(String what) => '$what is required';
}
