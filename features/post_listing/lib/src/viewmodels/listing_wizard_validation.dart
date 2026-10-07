import 'package:core/core.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;

import 'listing_wizard_state.dart';

/// Per-step validation for the post-listing wizard.
///
/// A separate file from the state because it is the part worth testing
/// exhaustively: each rule corresponds to something the database or Storage
/// will reject later, and a rule the app and the server disagree on is how a
/// seller fills in a correct form and gets an error anyway.
///
/// Messages resolve through [AppLocalizations] passed in by the caller, which
/// always has a BuildContext (steps, screen) or constructs the English
/// lookup directly (unit tests). Field hints are UI strings, not failures,
/// so they do not go through [AppException] (Rule 36 covers the latter).
extension ListingWizardValidation on ListingWizardState {
  /// Validates [step] and returns any problems.
  StepValidation validate(WizardStep step, post_strings.AppLocalizations s) =>
      switch (step) {
        WizardStep.type => _validateType(s),
        WizardStep.location => _validateLocation(s),
        WizardStep.specs => _validateSpecs(s),
        WizardStep.price => _validatePrice(s),
        WizardStep.review => const StepValidation.valid(),
      };

  /// Whether [step] may be left.
  bool canLeave(WizardStep step, post_strings.AppLocalizations s) =>
      validate(step, s).isValid;

  /// Whether the whole wizard may be submitted.
  ///
  /// Checks every step, not just the current one, because the seller can reach
  /// review by stepping back and forth and the review step shows everything at
  /// once. Without this a listing could be submitted with a hole in it.
  bool canSubmit(post_strings.AppLocalizations s) => WizardStep.values
      .where((step) => step != WizardStep.review)
      .every((step) => validate(step, s).isValid);

  /// Validates [step] and returns the first field that is wrong.
  ///
  /// Convenience for tests and for deciding which step to jump to when
  /// submission is blocked.
  String? firstInvalidField(
    WizardStep step,
    post_strings.AppLocalizations s,
  ) {
    final errors = validate(step, s).errors;
    return errors.isEmpty ? null : errors.keys.first;
  }

  StepValidation _validateType(post_strings.AppLocalizations s) {
    final errors = <String, String>{};
    if (propertyType == null) {
      errors['propertyType'] = s.requiredField(s.fieldPropertyType);
    }
    if (listingPurpose == null) {
      errors['listingPurpose'] = s.requiredField(s.fieldPurpose);
    }
    return StepValidation(errors);
  }

  StepValidation _validateLocation(post_strings.AppLocalizations s) {
    final errors = <String, String>{};

    if (district == null) {
      errors['district'] = s.requiredField(s.fieldDistrict);
    }

    // The municipality is chosen from a dropdown scoped to the district, never
    // typed, so by the time this runs the pair already agrees. The check below
    // is defence in depth for a state assembled any other way (a test, a
    // restored draft): a cross-district pair is exactly what the composite
    // city FK refuses with a bare 23503.
    // Copied to a local so it can be null-checked and then used; a field on
    // `this` is not promotable in Dart.
    final chosen = municipality;
    if (chosen == null) {
      errors['municipality'] = s.requiredField(s.fieldMunicipality);
    } else if (chosen.district != district?.name) {
      errors['municipality'] = s.crossDistrict(
        chosen.name,
        district?.name ?? '',
      );
    }

    // Ward is optional (Rule 28) but must be in range when present. Two bounds
    // apply and both are checked: the global validator mirrors the ward_valid
    // CHECK exactly (so a leading zero like '01' is still rejected), and the
    // municipality's own wardCount is the tighter bound (so ward 25 in a
    // 9-ward body is rejected here rather than submitted).
    final wardValue = ward.trim();
    if (wardValue.isNotEmpty) {
      if (!Validators.isValidWard(wardValue)) {
        errors['ward'] = s.wardRange(Validators.maxWard);
      } else if (chosen != null) {
        final number = int.parse(wardValue);
        if (number > chosen.wardCount) {
          errors['ward'] = s.wardCount(chosen.name, chosen.wardCount);
        }
      }
    }

    errors.addAll(
      _optionalNonNegative(s, 'roadAccessFt', roadAccessFt, s.fieldRoadAccess),
    );

    return StepValidation(errors);
  }

  StepValidation _validateSpecs(post_strings.AppLocalizations s) {
    final errors = <String, String>{};

    // Which units are required depends on the district's region (Rule 25).
    // Accepting the wrong system's numbers here is the bug this guards: 1 bigha
    // and 1 ropani differ by about 12x, so a seller who typed terai units for a
    // hill district would publish a wildly wrong size.
    if (district == null) {
      errors['district'] = s.requiredField(s.fieldDistrict);
      return StepValidation(errors);
    }

    if (!hasArea) {
      // Distinguish "you used the wrong units" from "you left it blank".
      // Both leave the applicable fields empty, but only one is a unit mix-up,
      // and telling a seller their bigha figure is invalid for a Terai district
      // when they simply have not noticed the fields changed is unhelpful.
      errors['area'] = hasAreaInWrongUnits
          ? (usesHillUnits ? s.areaWrongHill : s.areaWrongTerai)
          : (usesHillUnits ? s.areaHillEmpty : s.areaTeraiEmpty);
      return StepValidation(errors);
    }

    if (usesHillUnits) {
      errors
        ..addAll(_optionalNonNegative(s, 'areaRopani', areaRopani, s.unitRopani))
        ..addAll(_optionalNonNegative(s, 'areaAana', areaAana, s.unitAana))
        ..addAll(
          _optionalNonNegative(s, 'areaPaisa', areaPaisa, s.unitPaisa),
        )
        ..addAll(_optionalNonNegative(s, 'areaDam', areaDam, s.unitDam));
    } else {
      errors
        ..addAll(_optionalNonNegative(s, 'areaBigha', areaBigha, s.unitBigha))
        ..addAll(
          _optionalNonNegative(s, 'areaKattha', areaKattha, s.unitKattha),
        )
        ..addAll(_optionalNonNegative(s, 'areaDhur', areaDhur, s.unitDhur));
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
            ? s.bedroomsMin
            : s.bathroomsMin;
      }
    }

    return StepValidation(errors);
  }

  StepValidation _validatePrice(post_strings.AppLocalizations s) {
    final errors = <String, String>{};

    final price = _parse(priceNpr);
    if (price == null) {
      errors['priceNpr'] = s.requiredField(s.fieldPrice);
    } else if (!Validators.isValidPrice(price)) {
      errors['priceNpr'] = s.priceInvalid;
    }

    // One photo is required so a listing is never invisible in search results.
    // A stub comment here once claimed DATA.md requires three; that file
    // is not in the repository, so the requirement is not asserted as fact.
    // Raising it to three is a product decision, not a validation fix.
    if (uploadedPhotoUrls.isEmpty) {
      errors['photos'] = s.photosRequired;
    }

    return StepValidation(errors);
  }

  /// Validates a non-negative optional integer field.
  Map<String, String> _optionalNonNegative(
    post_strings.AppLocalizations s,
    String field,
    String raw,
    String label,
  ) {
    if (raw.trim().isEmpty) return const <String, String>{};
    final parsed = _parse(raw);
    if (parsed == null) {
      return <String, String>{field: s.numberInvalid(label)};
    }
    if (parsed < 0) {
      return <String, String>{field: s.numberNegative(label)};
    }
    return const <String, String>{};
  }

  static int? _parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
}

