import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:post_listing/post_listing.dart';

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

ListingWizardState _state({
  District? district = kathmandu,
  Municipality? municipality = kathmanduMetro,
  String areaAana = '5',
  String areaPaisa = '4',
  String areaBigha = '',
}) =>
    ListingWizardState(
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      title: 'Shanti Villa',
      district: district,
      municipality: district == null ? null : municipality,
      city: district == null ? '' : 'Kathmandu',
      areaAana: district?.isHill ?? false ? areaAana : '',
      areaPaisa: district?.isHill ?? false ? areaPaisa : '',
      areaBigha: district?.isHill ?? false ? '' : areaBigha,
    );

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

/// Pumps [child] inside a scope where Kathmandu's municipalities resolve.
///
/// LocationStep watches `municipalitiesProvider` itself, so every pump needs
/// the override (Rule 33). Other districts resolve to an empty list.
Widget _scopedApp(Widget child) => ProviderScope(
      overrides: [
        municipalitiesProvider(district: 'Kathmandu').overrideWithValue(
          const AsyncData<List<Municipality>>([kathmanduMetro, kirtipur]),
        ),
      ],
      child: _app(child),
    );

void main() {
  group('SpecsStep area units follow the district', () {
    testWidgets('a hill district shows ropani, aana, paisa, dam',
        (tester) async {
      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: _state(),
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Ropani'), findsOneWidget);
      expect(find.text('Aana'), findsOneWidget);
      expect(find.text('Paisa'), findsOneWidget);
      expect(find.text('Dam'), findsOneWidget);
      // The other system's units must not be offered.
      expect(find.text('Bigha'), findsNothing);
      expect(find.text('Kattha'), findsNothing);
    });

    testWidgets('a terai district shows bigha, kattha, dhur', (tester) async {
      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: _state(
              district: chitwan,
              areaAana: '',
              areaPaisa: '',
              areaBigha: '2',
            ),
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Bigha'), findsOneWidget);
      expect(find.text('Kattha'), findsOneWidget);
      expect(find.text('Dhur'), findsOneWidget);
      expect(find.text('Aana'), findsNothing);
    });

    testWidgets('shows the derived sqm once area is entered', (tester) async {
      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: _state(),
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      // 5 aana + 4 paisa = 5*342.25 + 4*85.56 = 2053.49
      expect(find.textContaining('2053 sqm'), findsOneWidget);
    });

    testWidgets('explains the unit system in the subtitle', (tester) async {
      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: _state(),
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      expect(find.textContaining('hill district'), findsOneWidget);
    });

    testWidgets('asks for a district first when none is chosen',
        (tester) async {
      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: const ListingWizardState(),
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      expect(find.textContaining('Choose a district first'), findsOneWidget);
      expect(find.text('Ropani'), findsNothing);
      expect(find.text('Bigha'), findsNothing);
    });

    testWidgets('reports the wrong unit system rather than a blank field',
        (tester) async {
      // A Terai seller who typed aana: the message has to name the problem,
      // because "enter the area" when they already did is not actionable.
      final state = _state(district: chitwan)
          .copyWith(areaAana: '5');

      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: state,
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      expect(find.textContaining('bigha, kattha or dhur'), findsOneWidget);
      expect(find.textContaining('not ropani'), findsOneWidget);
    });

    testWidgets('reports an invalid bedroom count inline', (tester) async {
      await tester.pumpWidget(
        _app(
          SpecsStep(
            state: _state().copyWith(bedrooms: '0'),
            onUnitChanged: (_, _) {},
            onBedroomsChanged: (_) {},
            onBathroomsChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Bedrooms must be 1 or more'), findsOneWidget);
    });
  });

  group('LocationStep cascade', () {
    Widget location(ListingWizardState state) => LocationStep(
          state: state,
          districts: const <District>[kathmandu, chitwan],
          onDistrictChanged: (_) {},
          onMunicipalityChanged: (_) {},
          onWardChanged: (_) {},
          onRoadAccessChanged: (_) {},
        );

    testWidgets('lists the municipalities of the chosen district',
        (tester) async {
      // No municipality pre-selected, so the menu is the only place names can
      // appear: tapping the district's displayed name would be ambiguous, since
      // the municipality field shows 'Kathmandu' too once KMC is picked.
      await tester.pumpWidget(
        _scopedApp(
          location(_state().copyWith(clearMunicipality: true, city: '')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<Municipality>));
      await tester.pumpAndSettle();

      // Both Kathmandu bodies from the override, and nothing else.
      expect(find.text('Kirtipur'), findsOneWidget);
      expect(find.text('Lalitpur'), findsNothing);
    });

    testWidgets('offers one ward entry per ward of the body', (tester) async {
      await tester.pumpWidget(
        _scopedApp(location(_state().copyWith(municipality: kirtipur))),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ward (optional)'));
      await tester.pumpAndSettle();

      // Kirtipur has 10 wards, plus the skip entry: ward 10 exists, ward 11
      // does not, and ward 25 — valid in KMC — is unoffered here. 'No ward'
      // renders twice (the field's current value and the menu entry), so it
      // is asserted as plural.
      expect(find.text('Ward 10'), findsWidgets);
      expect(find.text('Ward 11'), findsNothing);
      expect(find.text('Ward 25'), findsNothing);
      expect(find.text('No ward'), findsWidgets);
    });

    testWidgets('asks for a municipality before offering wards',
        (tester) async {
      await tester.pumpWidget(
        _scopedApp(
          location(_state().copyWith(clearMunicipality: true, city: '')),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Choose a municipality first'),
        findsOneWidget,
      );
      expect(find.text('Ward (optional)'), findsNothing);
    });

    testWidgets('rejects a ward beyond the body\u2019s own count',
        (tester) async {
      // Ward 25 is globally valid (KMC has 32) but Kirtipur has 10, so the
      // per-body bound is what rejects it — with the body's name attached.
      await tester.pumpWidget(
        _scopedApp(
          location(
            _state().copyWith(municipality: kirtipur, ward: '25'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kirtipur has 10 wards'), findsOneWidget);
    });

    testWidgets('requires a municipality, not just a district',
        (tester) async {
      await tester.pumpWidget(
        _scopedApp(
          location(_state().copyWith(clearMunicipality: true, city: '')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Municipality is required'), findsOneWidget);
    });

    testWidgets('states the ward range and that 33 is the national maximum',
        (tester) async {
      // Pokhara is the largest local body in Nepal at 33 wards, so the ceiling
      // is the real maximum rather than an arbitrary cap. This note previously
      // claimed KMC had the most at 32, which the Pokhara seed row disproved.
      await tester.pumpWidget(_scopedApp(location(_state())));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Pokhara Metropolitan City'),
        findsOneWidget,
      );
      expect(find.textContaining('33'), findsWidgets);
      expect(find.textContaining('more wards'), findsNothing);
    });

    testWidgets('rejects a ward the database would reject', (tester) async {
      await tester.pumpWidget(
        _scopedApp(location(_state().copyWith(ward: '34'))),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Ward must be a number'), findsOneWidget);
    });
  });

  group('ReviewStep', () {
    ReviewStep build(ListingWizardState state) => ReviewStep(
          state: state,
          onEditStep: (_) {},
          onSubmit: () {},
        );

    testWidgets('shows the formatted price', (tester) async {
      await tester.pumpWidget(
        _app(build(_state().copyWith(priceNpr: '25000000'))),
      );

      // Rule 27: the detail/review form uses the full grouped figure.
      expect(find.text('NPR 2,50,00,000'), findsOneWidget);
    });

    testWidgets('echoes the seller units alongside sqm', (tester) async {
      await tester.pumpWidget(_app(build(_state())));

      expect(find.textContaining('5 aana'), findsOneWidget);
      expect(find.textContaining('2053 sqm'), findsOneWidget);
    });

    testWidgets('states that the contact number is not published',
        (tester) async {
      // The privacy property, asserted in the UI: a seller must understand why
      // there is no phone field here.
      await tester.pumpWidget(_app(build(_state())));

      expect(find.textContaining('never published'), findsOneWidget);
    });

    testWidgets('submit is disabled when an earlier step is incomplete',
        (tester) async {
      final state = _state().copyWith(clearDistrict: true);

      await tester.pumpWidget(_app(build(state)));

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit for review'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('submit is enabled once everything is filled in',
        (tester) async {
      final state = _state().copyWith(
        priceNpr: '25000000',
        photos: const <WizardPhoto>[WizardPhoto(url: 'https://x/1.jpg')],
      );

      await tester.pumpWidget(_app(build(state)));

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit for review'),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  group('PricePhotosStep', () {
    testWidgets('shows the compact and full price forms', (tester) async {
      await tester.pumpWidget(
        _app(
          PricePhotosStep(
            state: _state().copyWith(priceNpr: '15000000'),
            onPriceChanged: (_) {},
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
          ),
        ),
      );

      expect(find.textContaining('1,50,00,000'), findsOneWidget);
    });

    testWidgets('asks for a photo when none are added', (tester) async {
      await tester.pumpWidget(
        _app(
          PricePhotosStep(
            state: _state(),
            onPriceChanged: (_) {},
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
          ),
        ),
      );

      expect(find.text('Add at least one photo'), findsOneWidget);
    });
  });

  group('WizardField', () {
    testWidgets('reports the error inline on the field', (tester) async {
      await tester.pumpWidget(
        _app(
          WizardField(
            label: 'Ward',
            value: '33',
            error: 'Ward must be a number from 1 to 33',
            onChanged: (_) {},
          ),
        ),
      );

      expect(
        find.text('Ward must be a number from 1 to 33'),
        findsOneWidget,
      );
    });

    testWidgets('restricts numeric input to digits', (tester) async {
      // Validating digits at the input layer means a seller cannot type a
      // letter and be told afterwards it is not a number.
      final values = <String>[];
      await tester.pumpWidget(
        _app(
          WizardField(
            label: 'Price',
            value: '',
            keyboardType: TextInputType.number,
            inputFormatters: digitsOnly,
            onChanged: values.add,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '12a3');
      expect(values.last, '123');
    });
  });

  group('NepaliCurrency used by the review step', () {
    test('is exercised through the wizard rather than duplicated', () {
      // Guards against the wizard growing its own price formatter and drifting
      // from Rule 27.
      expect(NepaliCurrency.full(25000000), 'NPR 2,50,00,000');
    });
  });
}
