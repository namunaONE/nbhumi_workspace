// The widget file directly rather than the `admin_queue` barrel.
//
// SpecTable depends only on core, flutter and models, but the barrel also
// exports the providers, which reach `package:data` - and an unrelated
// in-flight change there does not currently compile. Importing the one file
// keeps this test scoped to what it actually tests, and runnable while
// someone else's work is half-applied.
import 'package:admin_queue/src/presentation/widgets/spec_table.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Tests for [SpecTable]'s ward and area rendering.
///
/// The ward cases exist because this getter was wrong three ways at once when
/// it parsed the string itself. Each case below is one of those ways, and each
/// asserts against the *database's* accepted set rather than a restated copy of
/// it - [Validators.isValidWard] is the single source, and these tests exist to
/// catch the day someone stops using it.
void main() {
  ListingDetail listing({String? ward, double? areaSqm, String? areaDisplay}) =>
      ListingDetail(
        id: 'l1',
        sellerId: 's1',
        title: 'Shanti Villa',
        priceNpr: 25000000,
        district: 'Kathmandu',
        city: 'Kathmandu',
        propertyType: PropertyType.house,
        listingPurpose: ListingPurpose.sale,
        ward: ward,
        areaSqm: areaSqm,
        areaDisplay: areaDisplay,
      );

  Future<void> pumpTable(WidgetTester tester, ListingDetail value) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SpecTable(listing: value)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ward', () {
    testWidgets('shows a normal ward', (tester) async {
      await pumpTable(tester, listing(ward: '5'));

      expect(find.text('Ward'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows ward 33, which Pokhara genuinely has', (tester) async {
      // The regression that started this. Kathmandu is the largest body
      // most people know of, at 32 wards, but Pokhara has 33 - and the ceiling
      // has already been corrected to 33 twice. A getter that hardcoded 32
      // silently dropped a real address from the review pane.
      await pumpTable(tester, listing(ward: '33'));

      expect(find.text('33'), findsOneWidget);
    });

    testWidgets('drops ward 34, which is not real anywhere', (tester) async {
      await pumpTable(tester, listing(ward: '34'));

      expect(find.text('Ward'), findsNothing);
    });

    testWidgets('drops ward 0 and any leading zero', (tester) async {
      // The `ward_valid` CHECK is a string pattern with no `0` branch, so '01'
      // is rejected by the database. `int.tryParse('01')` accepts it, which is
      // how a client and server end up disagreeing about a value both were
      // handed.
      await pumpTable(tester, listing(ward: '0'));
      expect(find.text('Ward'), findsNothing);

      await pumpTable(tester, listing(ward: '01'));
      expect(find.text('Ward'), findsNothing);
    });

    testWidgets('drops a padded or spaced ward', (tester) async {
      // Same reason: the pattern is anchored, so whitespace is not accepted.
      await pumpTable(tester, listing(ward: ' 5'));
      expect(find.text('Ward'), findsNothing);
    });

    testWidgets('omits the row entirely when there is no ward', (tester) async {
      // Not a dash. A dash would imply the seller left something out.
      await pumpTable(tester, listing());

      expect(find.text('Ward'), findsNothing);
    });

    testWidgets('agrees with the canonical validator on every value', (
      tester,
    ) async {
      // The invariant behind all the individual cases: whatever
      // Validators.isValidWard accepts, the table renders. A loop, so a future
      // ceiling change is caught here rather than in production.
      for (var n = 0; n <= 40; n++) {
        final ward = n.toString();
        final shouldShow = Validators.isValidWard(ward);

        await pumpTable(tester, listing(ward: ward));

        expect(
          find.text('Ward'),
          shouldShow ? findsOneWidget : findsNothing,
          reason: 'ward "$ward": Validators says $shouldShow',
        );
      }
    });
  });

  group('area', () {
    testWidgets('prefers the server-rendered local units', (tester) async {
      // The server already applied the hill/terai split, which the client cannot
      // infer from a district name.
      await pumpTable(
        tester,
        listing(areaSqm: 508.6, areaDisplay: '2 Aana 1 Paisa 2 Dam'),
      );

      expect(find.text('2 Aana 1 Paisa 2 Dam'), findsOneWidget);
    });

    testWidgets('falls back to sqm, without a trailing .0', (tester) async {
      await pumpTable(tester, listing(areaSqm: 2500));

      expect(find.text('2500 sqm'), findsOneWidget);
    });

    testWidgets('keeps two decimals when they carry information', (
      tester,
    ) async {
      await pumpTable(tester, listing(areaSqm: 508.64));

      expect(find.text('508.64 sqm'), findsOneWidget);
    });

    testWidgets('omits the row when there is no area at all', (tester) async {
      await pumpTable(tester, listing());

      expect(find.text('Area'), findsNothing);
    });
  });

  group('absent attributes', () {
    testWidgets('a land listing shows no bedrooms row', (tester) async {
      // Land has no bedrooms. A dash would read as "the seller left it out",
      // which is a different and wrong thing to tell a reviewer.
      await pumpTable(tester, listing());

      expect(find.text('Bedrooms'), findsNothing);
      expect(find.text('Bathrooms'), findsNothing);
    });
  });
}
