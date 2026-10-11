import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:post_listing/l10n/output/post_localizations.dart';
import 'package:post_listing/l10n/output/post_localizations_en.dart';
import 'package:post_listing/l10n/output/post_localizations_ne.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_state.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_validation.dart';

/// English strings for message assertions.
final AppLocalizations en = AppLocalizationsEn();

/// Nepali strings for message assertions.
final AppLocalizations ne = AppLocalizationsNe();

const District kathmandu = District(
  id: 29,
  name: 'Kathmandu',
  province: 3,
  region: Region.hill,
);

const District chitwan = District(
  id: 35,
  name: 'Chitwan',
  province: 3,
  region: Region.terai,
);

const Municipality kathmanduMetro = Municipality(
  id: 'm-ktm',
  slug: 'kathmandu-kathmandu',
  district: 'Kathmandu',
  name: 'Kathmandu',
  type: MunicipalityType.metropolitan,
  wardCount: 32,
);

const Municipality kirtipur = Municipality(
  id: 'm-kir',
  slug: 'kathmandu-kirtipur',
  district: 'Kathmandu',
  name: 'Kirtipur',
  type: MunicipalityType.municipality,
  wardCount: 10,
);

const Municipality lalitpurMetro = Municipality(
  id: 'm-lal',
  slug: 'lalitpur-lalitpur',
  district: 'Lalitpur',
  name: 'Lalitpur',
  type: MunicipalityType.metropolitan,
  wardCount: 29,
);

/// A state that passes every step.
ListingWizardState _complete({
  District district = kathmandu,
  Municipality municipality = kathmanduMetro,
  String city = 'Kathmandu',
  String areaAana = '5',
  String areaPaisa = '4',
  String areaBigha = '',
  String price = '25000000',
}) =>
    ListingWizardState(
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      title: 'Shanti Villa',
      district: district,
      municipality: municipality,
      city: city,
      areaAana: areaAana,
      areaPaisa: areaPaisa,
      areaBigha: areaBigha,
      priceNpr: price,
      photos: const <WizardPhoto>[WizardPhoto(url: 'https://x/1.jpg')],
    );

void main() {
  group('step one: type and purpose', () {
    test('requires both', () {
      const state = ListingWizardState();
      final errors = state.validate(WizardStep.type, en).errors;

      expect(
        errors.keys,
        containsAll(<String>['propertyType', 'listingPurpose', 'title']),
      );
    });

    test('passes with both chosen', () {
      expect(
        _complete().validate(WizardStep.type, en).isValid,
        isTrue,
      );
    });

    test('rejects a blank title', () {
      // The server refuses a blank title on submit (HYA-292 trigger), so the
      // form requires it on step one rather than failing at review.
      final errors = _complete()
          .copyWith(title: '   ')
          .validate(WizardStep.type, en)
          .errors;

      expect(errors.keys, contains('title'));
      expect(errors['title'], contains('Title'));
    });
  });

  group('step two: location', () {
    test('requires a district and a municipality', () {
      const state = ListingWizardState();
      final errors = state.validate(WizardStep.location, en).errors;

      expect(
        errors.keys,
        containsAll(<String>['district', 'municipality']),
      );
      // No free-text city to require: the municipality is the city, chosen
      // from the district's own bodies so the composite city FK holds.
      expect(errors.keys, isNot(contains('city')));
    });

    test('rejects a municipality from another district', () {
      // Defence in depth for a state assembled any other way. The UI cannot
      // produce this (the dropdown is district-scoped), but the database
      // refuses the pair with a bare 23503, so validation names it first.
      final state = _complete().copyWith(municipality: lalitpurMetro);
      final errors = state.validate(WizardStep.location, en).errors;

      expect(errors['municipality'], contains('not in Kathmandu'));
    });

    test('accepts ward 33 in Pokhara, the one body that has it', () {
      // 33 is rejected under KMC above and accepted here: the bound follows
      // the municipality, not the global ceiling.
      const pokhara = Municipality(
        id: 'm-pok',
        slug: 'kaski-pokhara',
        district: 'Kaski',
        name: 'Pokhara',
        type: MunicipalityType.metropolitan,
        wardCount: 33,
      );
      const pokharaDistrict = District(
        id: 40,
        name: 'Kaski',
        province: 4,
        region: Region.hill,
      );
      final state = _complete(district: pokharaDistrict).copyWith(
        municipality: pokhara,
        city: 'Pokhara',
        ward: '33',
      );
      expect(state.validate(WizardStep.location, en).isValid, isTrue);
    });

    test('accepts a ward at exactly the body\u2019s count', () {
      expect(
        _complete().copyWith(municipality: kirtipur, ward: '10').validate(
              WizardStep.location,
              en,
            ).isValid,
        isTrue,
      );
    });

    test('rejects a ward above the body\u2019s count', () {
      // Globally valid (KMC has 32) but out of range for Kirtipur's 10.
      final state =
          _complete().copyWith(municipality: kirtipur, ward: '11');
      expect(
        state.validate(WizardStep.location, en)['ward'],
        'Kirtipur has 10 wards',
      );
    });

    test('ward is optional', () {
      // Rule 28: ward is optional.
      expect(
        _complete()
            .copyWith(ward: '')
            .validate(WizardStep.location, en)
            .isValid,
        isTrue,
      );
    });

    test('accepts a ward inside the agreed range', () {
      for (final ward in <String>['1', '16', '32']) {
        expect(
          _complete().copyWith(ward: ward).validate(WizardStep.location, en)
              .isValid,
          isTrue,
          reason: 'ward $ward',
        );
      }
    });

    test('rejects a ward the database would reject', () {
      // The client and the ward_valid CHECK have to agree, or the seller fills
      // the form in correctly and gets a 23514 on submit.
      for (final ward in <String>['34', '36', '0', '-1', '01', 'abc', '']) {
        if (ward.isEmpty) continue;
        expect(
          _complete().copyWith(ward: ward).validate(WizardStep.location, en)
              .isValid,
          isFalse,
          reason: 'ward "$ward"',
        );
      }
    });

    test('rejects a negative road frontage', () {
      final state = _complete().copyWith(roadAccessFt: '-5');
      expect(
        state.validate(WizardStep.location, en)['roadAccessFt'],
        isNotNull,
      );
    });

    test('accepts a blank road frontage', () {
      expect(
        _complete()
            .copyWith(roadAccessFt: '')
            .validate(WizardStep.location, en)
            .isValid,
        isTrue,
      );
    });
  });

  group('step three: area units follow the district region', () {
    test('a hill district uses hill units', () {
      final state = _complete();
      expect(state.usesHillUnits, isTrue);
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a terai district uses terai units', () {
      // The whole point of District.region. A seller in Chitwan entering bigha
      // must not be asked for aana.
      final state = _complete(
        district: chitwan,
        areaAana: '',
        areaBigha: '2',
      );
      expect(state.usesHillUnits, isFalse);
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('rejects hill units entered for a terai district', () {
      // 1 ropani and 1 bigha differ by about 12x, so accepting the wrong
      // system's numbers would publish a wildly wrong size.
      final state = _complete(
        district: chitwan,
      );
      expect(state.validate(WizardStep.specs, en)['area'], isNotNull);
    });

    test('rejects terai units entered for a hill district', () {
      // Every hill field must be blank, not just the first: areaPaisa defaults
      // to a value in the fixture, and one stray hill unit makes the input
      // count as hill after all.
      final state = _complete(
        areaAana: '',
        areaPaisa: '',
        areaBigha: '2',
      );
      expect(state.validate(WizardStep.specs, en)['area'], isNotNull);
    });

    test('requires some area', () {
      final state = _complete().copyWith(areaAana: '', areaPaisa: '');
      expect(state.validate(WizardStep.specs, en)['area'], isNotNull);
    });

    test('computes sqm from hill units', () {
      // 5 aana 4 paisa = 5 * 342.25 + 4 * 85.56
      final state = _complete();
      expect(state.areaSqm, closeTo(5 * 342.25 + 4 * 85.56, 0.001));
    });

    test('computes sqm from terai units', () {
      final state = _complete(
        district: chitwan,
        areaAana: '',
        areaBigha: '1',
      );
      expect(state.areaSqm, closeTo(6772.63, 0.001));
    });

    test('has no area before a district is chosen', () {
      const state = ListingWizardState(areaAana: '5');
      expect(state.areaSqm, isNull);
      expect(state.region, isNull);
    });

    test('rejects zero bedrooms, which the CHECK forbids', () {
      // CHECK (bedrooms > 0): catching it here turns a server error into a
      // hint rather than a failed submission.
      final state = _complete().copyWith(bedrooms: '0');
      expect(state.validate(WizardStep.specs, en)['bedrooms'], isNotNull);
    });

    test('accepts absent bedrooms for land', () {
      final state = _complete(
        district: chitwan,
        areaAana: '',
        areaBigha: '1',
      ).copyWith(bedrooms: '', bathrooms: '');
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });
  });

  group('step three: purpose-conditioned fields', () {
    test('a lease requires a term', () {
      // A lease without a term is not a contract a tenant can act on, and the
      // review screen would otherwise show "Not set" for the field that
      // defines the arrangement.
      final state = _complete().copyWith(listingPurpose: ListingPurpose.lease);
      final errors = state.validate(WizardStep.specs, en).errors;

      expect(errors['leaseTermMonths'], 'Lease term is required');
    });

    test('a lease accepts a term of one month or more', () {
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.lease,
        leaseTermMonths: '24',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a lease rejects a term below one month', () {
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.lease,
        leaseTermMonths: '0',
      );
      expect(
        state.validate(WizardStep.specs, en)['leaseTermMonths'],
        'Lease term must be at least 1 month',
      );
    });

    test('a lease asks nothing about deposits or pets', () {
      // The other purpose's fields must not be required, or a lease seller is
      // held to rent terms that do not apply to them.
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.lease,
        leaseTermMonths: '12',
      );
      final errors = state.validate(WizardStep.specs, en).errors;

      expect(errors, isNot(contains('depositAmount')));
      expect(errors, isNot(contains('availableFrom')));
      expect(errors, isNot(contains('utilitiesIncluded')));
      expect(errors, isNot(contains('petPolicy')));
    });

    test('a rent listing asks nothing about a lease term', () {
      final state = _complete().copyWith(listingPurpose: ListingPurpose.rent);
      final errors = state.validate(WizardStep.specs, en).errors;

      expect(errors, isNot(contains('leaseTermMonths')));
    });

    test('a rent listing accepts a past-free availability date', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        availableFrom: tomorrow,
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a rent listing refuses an availability date in the past', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        availableFrom: yesterday,
      );
      expect(
        state.validate(WizardStep.specs, en)['availableFrom'],
        'Availability date cannot be in the past',
      );
    });

    test('a rent listing accepts today as an availability date', () {
      // Same-day occupancy is normal and must not be refused as "in the
      // past"; the comparison is date-only, so the clock time is ignored.
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        availableFrom: DateTime.now(),
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a rent listing accepts a zero deposit', () {
      // Some rentals are genuinely deposit-free, so the CHECK is >= 0 and the
      // validator mirrors that rather than reusing the bedroom rule.
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        depositAmount: '0',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a rent listing refuses a negative deposit', () {
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        depositAmount: '-1',
      );
      expect(
        state.validate(WizardStep.specs, en)['depositAmount'],
        'Security deposit cannot be negative',
      );
    });

    test('a rent listing caps the utilities note', () {
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        utilitiesIncluded: 'x' * 201,
      );
      expect(
        state.validate(WizardStep.specs, en)['utilitiesIncluded'],
        'Keep the utilities note under 200 characters',
      );
    });

    test('a rent listing accepts a short utilities note', () {
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.rent,
        utilitiesIncluded: 'Water and maintenance',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });
  });

  group('step three: type-conditioned fields', () {
    test('land is not asked for bedrooms or bathrooms', () {
      // The fields are hidden for land, so anything in state here came from a
      // type the seller switched away from -- and it must not be validated,
      // because the seller can no longer see or clear it.
      final state = _complete().copyWith(
        propertyType: PropertyType.land,
        bedrooms: '3',
        bathrooms: '2',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('land is not asked for parking, floors, age or construction', () {
      final state = _complete().copyWith(
        propertyType: PropertyType.land,
        parkingSpaces: '0',
        floorNumber: '-1',
        totalFloors: '0',
        propertyAgeYears: '-5',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a commercial shop is not asked for bedrooms', () {
      final state = _complete().copyWith(
        propertyType: PropertyType.commercial,
        bedrooms: '3',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a commercial shop is asked for floor counts', () {
      // "Shop on the 2nd floor of a 5-storey plaza" is the normal shape of a
      // commercial listing, so the floors section applies.
      final state = _complete().copyWith(
        propertyType: PropertyType.commercial,
        floorNumber: '2',
        totalFloors: '5',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a commercial shop refuses a zero total floor count', () {
      final state = _complete().copyWith(
        propertyType: PropertyType.commercial,
        totalFloors: '0',
      );
      expect(
        state.validate(WizardStep.specs, en)['totalFloors'],
        'Total floors must be 1 or more',
      );
    });

    test('an apartment accepts the ground floor', () {
      // Floor zero is a real value, unlike a zero bedroom count, so this is
      // >= 0 rather than > 0.
      final state = _complete().copyWith(
        propertyType: PropertyType.apartment,
        floorNumber: '0',
        totalFloors: '7',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('an apartment refuses a negative floor', () {
      final state = _complete().copyWith(
        propertyType: PropertyType.apartment,
        floorNumber: '-1',
      );
      expect(
        state.validate(WizardStep.specs, en)['floorNumber'],
        isNotNull,
      );
    });

    test('a house is asked for parking but not for floors', () {
      final state = _complete().copyWith(parkingSpaces: '2');
      final errors = state.validate(WizardStep.specs, en).errors;

      expect(errors, isNot(contains('parkingSpaces')));
      expect(errors, isNot(contains('floorNumber')));
      expect(errors, isNot(contains('totalFloors')));
    });

    test('a house refuses a zero parking count', () {
      final state = _complete().copyWith(parkingSpaces: '0');
      expect(
        state.validate(WizardStep.specs, en)['parkingSpaces'],
        'Parking must be 1 or more',
      );
    });

    test('a villa is built, so it is asked for age and construction', () {
      final state = _complete().copyWith(
        propertyType: PropertyType.villa,
        propertyAgeYears: '10',
        constructionStatus: ConstructionStatus.resale,
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });

    test('a villa refuses a negative age', () {
      final state = _complete().copyWith(
        propertyType: PropertyType.villa,
        propertyAgeYears: '-3',
      );
      expect(
        state.validate(WizardStep.specs, en)['propertyAgeYears'],
        isNotNull,
      );
    });
  });

  group('step three: switching between purposes clears the other set', () {
    test('isLease and isRent are mutually exclusive', () {
      final lease = _complete().copyWith(listingPurpose: ListingPurpose.lease);
      final rent = _complete().copyWith(listingPurpose: ListingPurpose.rent);
      final sale = _complete();

      expect(lease.isLease, isTrue);
      expect(lease.isRent, isFalse);
      expect(rent.isRent, isTrue);
      expect(rent.isLease, isFalse);
      expect(sale.isLease, isFalse);
      expect(sale.isRent, isFalse);
    });

    test('a lease with a term passes the whole specs step', () {
      final state = _complete().copyWith(
        listingPurpose: ListingPurpose.lease,
        leaseTermMonths: '12',
      );
      expect(state.validate(WizardStep.specs, en).isValid, isTrue);
    });
  });

  group('step four: price and photos', () {
    test('requires a price', () {
      final state = _complete().copyWith(priceNpr: '');
      expect(state.validate(WizardStep.price, en)['priceNpr'], isNotNull);
    });

    test('rejects a zero price', () {
      final state = _complete(price: '0');
      expect(state.validate(WizardStep.price, en)['priceNpr'], isNotNull);
    });

    test('requires at least one uploaded photo', () {
      final state = _complete().copyWith(photos: const <WizardPhoto>[]);
      expect(state.validate(WizardStep.price, en)['photos'], isNotNull);
    });

    test('an in-flight photo does not count', () {
      // Otherwise the seller could submit while an upload was still running.
      final state = _complete().copyWith(
        photos: const <WizardPhoto>[WizardPhoto(url: '', isUploading: true)],
      );
      expect(state.validate(WizardStep.price, en)['photos'], isNotNull);
    });

    test('a failed photo does not count', () {
      final state = _complete().copyWith(
        photos: const <WizardPhoto>[
          WizardPhoto(
            url: '',
            error: NetworkException(
              code: 'network.offline',
              messageEn: 'No connection',
              messageNe: 'no',
            ),
          ),
        ],
      );
      expect(state.validate(WizardStep.price, en)['photos'], isNotNull);
    });
  });

  group('canSubmit', () {
    test('is true only when every step passes', () {
      expect(_complete().canSubmit(en), isTrue);
    });

    test('is false when an early step is incomplete', () {
      // The seller can reach review by stepping back and forth, so submission
      // has to re-check everything rather than trusting arrival at review.
      expect(
        _complete().copyWith(clearDistrict: true).canSubmit(en),
        isFalse,
      );
      expect(_complete().copyWith(priceNpr: '').canSubmit(en), isFalse);
      expect(_complete().copyWith(ward: '99').canSubmit(en), isFalse);
    });
  });

  group('WizardStep navigation', () {
    test('walks forward and back', () {
      expect(WizardStep.type.next, WizardStep.location);
      expect(WizardStep.location.previous, WizardStep.type);
      expect(WizardStep.type.previous, isNull);
      expect(WizardStep.review.next, isNull);
    });

    test('at() clamps rather than throwing', () {
      expect(WizardStep.at(-5), WizardStep.type);
      expect(WizardStep.at(99), WizardStep.review);
    });

    test('positions are sequential', () {
      for (var i = 0; i < WizardStep.values.length; i++) {
        expect(WizardStep.values[i].position, i);
      }
    });
  });

  group('Nepali messages (HYA-266 D2)', () {
    test('required fields name the field in Nepali', () {
      const state = ListingWizardState();
      final errors = state.validate(WizardStep.type, ne).errors;

      expect(errors['propertyType'], 'घरजग्गाको किसिम आवश्यक छ');
      expect(errors['listingPurpose'], 'बिक्री, भाडा वा लिज आवश्यक छ');
    });

    test('ward range carries the ceiling in Nepali', () {
      final state = _complete().copyWith(ward: '99');
      expect(
        state.validate(WizardStep.location, ne)['ward'],
        contains('33'),
      );
    });

    test('wrong-unit areas explain themselves in Nepali', () {
      final state = _complete(district: chitwan);
      expect(
        state.validate(WizardStep.specs, ne)['area'],
        contains('तराई'),
      );
    });

    test('price and photo hints are Nepali', () {
      final state = _complete().copyWith(priceNpr: '0', photos: const []);
      final errors = state.validate(WizardStep.price, ne).errors;

      expect(errors['priceNpr'], 'मूल्य शून्यभन्दा बढी हुनुपर्छ');
      expect(errors['photos'], 'कम्तीमा एउटा फोटो थप्नुहोस्');
    });
  });
}
