import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_state.dart';
import 'package:post_listing/src/viewmodels/listing_wizard_validation.dart';

const District kathmandu = District(
  id: 'd-ktm',
  name: 'Kathmandu',
  province: 'Bagmati',
  region: Region.hill,
);

const District chitwan = District(
  id: 'd-chi',
  name: 'Chitwan',
  province: 'Bagmati',
  region: Region.terai,
);

/// A state that passes every step.
ListingWizardState _complete({
  District district = kathmandu,
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
      city: 'Kathmandu',
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
      final errors = state.validate(WizardStep.type).errors;

      expect(
        errors.keys,
        containsAll(<String>['propertyType', 'listingPurpose']),
      );
    });

    test('passes with both chosen', () {
      expect(
        _complete().validate(WizardStep.type).isValid,
        isTrue,
      );
    });
  });

  group('step two: location', () {
    test('requires a district and a city', () {
      const state = ListingWizardState();
      final errors = state.validate(WizardStep.location).errors;

      expect(errors.keys, containsAll(<String>['district', 'city']));
    });

    test('ward is optional', () {
      // Rule 28: ward is optional.
      expect(
        _complete().copyWith(ward: '').validate(WizardStep.location).isValid,
        isTrue,
      );
    });

    test('accepts a ward inside the agreed range', () {
      for (final ward in <String>['1', '16', '32']) {
        expect(
          _complete().copyWith(ward: ward).validate(WizardStep.location)
              .isValid,
          isTrue,
          reason: 'ward $ward',
        );
      }
    });

    test('rejects a ward the database would reject', () {
      // The client and the ward_valid CHECK have to agree, or the seller fills
      // the form in correctly and gets a 23514 on submit.
      for (final ward in <String>['33', '36', '0', '-1', '01', 'abc', '']) {
        if (ward.isEmpty) continue;
        expect(
          _complete().copyWith(ward: ward).validate(WizardStep.location)
              .isValid,
          isFalse,
          reason: 'ward "$ward"',
        );
      }
    });

    test('rejects a negative road frontage', () {
      final state = _complete().copyWith(roadAccessFt: '-5');
      expect(state.validate(WizardStep.location)['roadAccessFt'], isNotNull);
    });

    test('accepts a blank road frontage', () {
      expect(
        _complete().copyWith(roadAccessFt: '').validate(WizardStep.location)
            .isValid,
        isTrue,
      );
    });
  });

  group('step three: area units follow the district region', () {
    test('a hill district uses hill units', () {
      final state = _complete();
      expect(state.usesHillUnits, isTrue);
      expect(state.validate(WizardStep.specs).isValid, isTrue);
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
      expect(state.validate(WizardStep.specs).isValid, isTrue);
    });

    test('rejects hill units entered for a terai district', () {
      // 1 ropani and 1 bigha differ by about 12x, so accepting the wrong
      // system's numbers would publish a wildly wrong size.
      final state = _complete(
        district: chitwan,
      );
      expect(state.validate(WizardStep.specs)['area'], isNotNull);
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
      expect(state.validate(WizardStep.specs)['area'], isNotNull);
    });

    test('requires some area', () {
      final state = _complete().copyWith(areaAana: '', areaPaisa: '');
      expect(state.validate(WizardStep.specs)['area'], isNotNull);
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
      expect(state.validate(WizardStep.specs)['bedrooms'], isNotNull);
    });

    test('accepts absent bedrooms for land', () {
      final state = _complete(
        district: chitwan,
        areaAana: '',
        areaBigha: '1',
      ).copyWith(bedrooms: '', bathrooms: '');
      expect(state.validate(WizardStep.specs).isValid, isTrue);
    });
  });

  group('step four: price and photos', () {
    test('requires a price', () {
      final state = _complete().copyWith(priceNpr: '');
      expect(state.validate(WizardStep.price)['priceNpr'], isNotNull);
    });

    test('rejects a zero price', () {
      final state = _complete(price: '0');
      expect(state.validate(WizardStep.price)['priceNpr'], isNotNull);
    });

    test('requires at least one uploaded photo', () {
      final state = _complete().copyWith(photos: const <WizardPhoto>[]);
      expect(state.validate(WizardStep.price)['photos'], isNotNull);
    });

    test('an in-flight photo does not count', () {
      // Otherwise the seller could submit while an upload was still running.
      final state = _complete().copyWith(
        photos: const <WizardPhoto>[WizardPhoto(url: '', isUploading: true)],
      );
      expect(state.validate(WizardStep.price)['photos'], isNotNull);
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
      expect(state.validate(WizardStep.price)['photos'], isNotNull);
    });
  });

  group('canSubmit', () {
    test('is true only when every step passes', () {
      expect(_complete().canSubmit, isTrue);
    });

    test('is false when an early step is incomplete', () {
      // The seller can reach review by stepping back and forth, so submission
      // has to re-check everything rather than trusting arrival at review.
      expect(
        _complete().copyWith(clearDistrict: true).canSubmit,
        isFalse,
      );
      expect(_complete().copyWith(priceNpr: '').canSubmit, isFalse);
      expect(_complete().copyWith(ward: '99').canSubmit, isFalse);
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
}
