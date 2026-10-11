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
/// Messages resolve through the localizations passed in by the caller, which
/// always has a BuildContext (steps, screen) or constructs the English
/// lookup directly (unit tests). Field hints are UI strings, not failures,
/// so they do not go through `AppException`.
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
    // The server refuses a blank title on submit (HYA-292 trigger), so the
    // form requires it up front rather than failing at review.
    if (title.trim().isEmpty) {
      errors['title'] = s.requiredField(s.fieldTitle);
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
        ..addAll(
          _optionalNonNegative(s, 'areaRopani', areaRopani, s.unitRopani),
        )
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

    // Rooms only exist in residential buildings. The fields are hidden for
    // land, commercial and business, so anything in state here came from a type
    // the seller switched away from; validating it anyway keeps the state
    // honest rather than trusting the UI to have cleared it.
    if (isResidential) {
      // Bedrooms and bathrooms are optional, but the column carries
      // CHECK (> 0), so 0 is rejected by the database. Catching it here turns
      // a server error into an inline hint.
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
    }

    // Parking is counted wherever there is ground to park on, so land is the
    // only type that drops out.
    if (hasParking) {
      errors.addAll(
        _optionalAtLeastOne(s, 'parkingSpaces', parkingSpaces, s.parkingMin),
      );
    }

    // Floor counts only apply inside a taller building.
    if (hasFloors) {
      errors
        ..addAll(
          _optionalNonNegative(s, 'floorNumber', floorNumber, s.fieldFloor),
        )
        ..addAll(
          _optionalAtLeastOne(s, 'totalFloors', totalFloors, s.totalFloorsMin),
        );
    }

    // A building can be aged; land cannot.
    if (isBuilt) {
      errors.addAll(
        _optionalNonNegative(
          s,
          'propertyAgeYears',
          propertyAgeYears,
          s.fieldPropertyAge,
        ),
      );
    }

    errors
      ..addAll(_validateLeaseTerms(s).errors)
      ..addAll(_validateRentalTerms(s).errors);

    return StepValidation(errors);
  }

  /// Lease terms are only required when the purpose is a lease.
  ///
  /// A term is required rather than optional because a lease without one is
  /// not a contract a tenant can act on, and the review screen would otherwise
  /// show "Not set" for the one field that defines the arrangement.
  StepValidation _validateLeaseTerms(post_strings.AppLocalizations s) {
    if (!isLease) return const StepValidation.valid();

    final errors = <String, String>{};
    final term = _parse(leaseTermMonths);

    if (leaseTermMonths.trim().isEmpty) {
      errors['leaseTermMonths'] = s.requiredField(s.fieldLeaseTerm);
    } else if (term == null) {
      errors['leaseTermMonths'] = s.numberInvalid(s.fieldLeaseTerm);
    } else if (term < 1) {
      errors['leaseTermMonths'] = s.leaseTermMin;
    }

    return StepValidation(errors);
  }

  /// Rental terms are only required when the purpose is a rent.
  ///
  /// The deposit stays optional: some rentals are genuinely deposit-free, and
  /// the column's CHECK is `>= 0` rather than `> 0` for exactly that reason.
  /// The availability date is checked against today, because a listing that
  /// says it is available from last month is either wrong or stale, and a
  /// tenant who filters on availability would skip it either way.
  StepValidation _validateRentalTerms(post_strings.AppLocalizations s) {
    final errors = <String, String>{};

    if (isRent) {
      final deposit = _parse(depositAmount);
      if (depositAmount.trim().isNotEmpty) {
        if (deposit == null) {
          errors['depositAmount'] = s.numberInvalid(s.fieldDeposit);
        } else if (deposit < 0) {
          errors['depositAmount'] = s.numberNegative(s.fieldDeposit);
        }
      }

      final available = availableFrom;
      if (available != null) {
        final now = DateTime.now();
        final dateOnly =
            DateTime(available.year, available.month, available.day);
        final todayOnly = DateTime(now.year, now.month, now.day);
        if (dateOnly.isBefore(todayOnly)) {
          errors['availableFrom'] = s.availableFromPast;
        }
      }

      if (utilitiesIncluded.trim().length > 200) {
        errors['utilitiesIncluded'] = s.utilitiesTooLong;
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

  /// Validates an optional integer field whose zero is meaningless.
  ///
  /// Parking spaces and total floors both carry `CHECK (> 0)` in the database:
  /// "none" is expressed by leaving the field empty, so a stored 0 can only be
  /// a mistake. The bedroom rule is its own because the column is
  /// residential-only.
  Map<String, String> _optionalAtLeastOne(
    post_strings.AppLocalizations s,
    String field,
    String raw,
    String minimumMessage,
  ) {
    if (raw.trim().isEmpty) return const <String, String>{};
    final parsed = _parse(raw);
    if (parsed == null || parsed < 1) {
      return <String, String>{field: minimumMessage};
    }
    return const <String, String>{};
  }
  static int? _parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
}
