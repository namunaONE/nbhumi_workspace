import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';
import 'package:search/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/main.dart';
import 'package:user_app/shell/app_shell.dart';

/// Guards the one way a responsive layout can crash outright.
///
/// `LayoutBuilder` runs its builder during `performLayout` and cannot answer
/// an intrinsic-dimensions query: running the callback speculatively could
/// mutate the live render tree. Any ancestor that measures its children
/// intrinsically therefore derails it with:
///
///   LayoutBuilder does not support returning intrinsic dimensions.
///
/// The hosts that measure intrinsically are dialogs (they size themselves
/// from their content's intrinsic width), `IntrinsicHeight`,
/// `IntrinsicWidth`, `Table` with intrinsic column widths, and sliver trees.
/// `Ink` — and so every Material button — uses a `LayoutBuilder` internally,
/// which is why button widgets fail the same way inside those hosts.
///
/// This suite keeps such a combination out of the tree. It asserts the
/// invariant on the widgets we actually render, and proves the detector is
/// not vacuous on a deliberately broken tree.
///
/// See DESIGN.md §6.4 for the design rule itself.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Two environment problems must be solved before the app can pump, both of
    // which make a naive test throw rather than fail:
    //
    // * The router reads auth state while constructing, so `Supabase.instance`
    //   must exist even for a signed-out assertion.
    // * Supabase Auth persists through `shared_preferences`, which has no
    //   plugin implementation under `flutter test`.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://project.supabase.co',
      publishableKey: 'sb_publishable_test_key',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUri: false,
      ),
    );
  });

  setUp(() => sessionContext.value = SessionContext.guest);

  /// Resizes the test surface, restoring it when the test ends.
  Future<void> resize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Every [LayoutBuilder] currently in the tree.
  List<Element> layoutBuildersInTree(WidgetTester tester) => tester
      .allElements
      .where((element) => element.widget is LayoutBuilder)
      .toList(growable: false);

  /// True if any ancestor of [element] is a widget of type [T].
  ///
  /// The visitor's return value decides whether to keep walking. Always
  /// continuing is correct: a match deep down still counts, and the walk is a
  /// dozen-odd nodes to the root.
  bool hasAncestorOf<T>(Element element) {
    var found = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is T) found = true;
      return true;
    });
    return found;
  }

  /// Asserts that [builder] sits under no host that measures intrinsically.
  ///
  /// Each host is checked with its own typed predicate rather than a runtime
  /// `Type` list, because `AlertDialog` is *not* a `Dialog` subclass — both
  /// extend `StatelessWidget` directly — so a single nominal type would miss
  /// the most common dialog outright.
  void expectNotUnderIntrinsicHost(Element builder, {required String context}) {
    void check<T>() {
      if (!hasAncestorOf<T>(builder)) return;
      fail(
        'A LayoutBuilder was rendered under $T in $context. That combination '
        'throws "LayoutBuilder does not support returning intrinsic '
        'dimensions" — see DESIGN.md §6.4.',
      );
    }

    check<AlertDialog>();
    check<SimpleDialog>();
    check<Dialog>();
    check<IntrinsicHeight>();
    check<IntrinsicWidth>();
    check<Table>();
  }

  /// Runs [expectNotUnderIntrinsicHost] over every [LayoutBuilder] in the tree.
  void expectNoIntrinsicHost(WidgetTester tester, {required String context}) {
    final builders = layoutBuildersInTree(tester);
    expect(
      builders,
      isNotEmpty,
      reason: 'The guard is only meaningful if the tree actually contains a '
          'LayoutBuilder — nothing was rendered under $context.',
    );

    for (final builder in builders) {
      expectNotUnderIntrinsicHost(builder, context: context);
    }
  }

  /// Every error the framework reports while [pump] runs.
  ///
  /// Intrinsic crashes cascade — the intrinsic error plus knock-on
  /// "RenderBox was not laid out" failures — and the test binding replaces
  /// several pending exceptions with a synthetic "Multiple exceptions"
  /// summary (see `_runTest` in package:flutter_test's binding.dart), so
  /// `takeException` can never see the originals. Collecting them here keeps
  /// every message.
  Future<List<String>> collectErrors(
    WidgetTester tester,
    Future<void> Function() pump,
  ) async {
    final messages = <String>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      messages.add(details.toString());
    };
    try {
      await pump();
    } finally {
      FlutterError.onError = oldHandler;
    }
    // Drain the binding's own pending slot as well, or a leftover makes the
    // test fail at teardown ("at least one was unexpected"). Our handler saw
    // everything first, so this only ever clears the summary.
    tester.takeException();
    return messages;
  }

  group('the hazard', () {
    testWidgets('a LayoutBuilder inside an AlertDialog really does throw',
        (tester) async {
      // Proves the guards below protect against a real crash rather than a
      // theoretical one: the dialog sizes itself from its content's
      // intrinsic width, and LayoutBuilder cannot answer that query.
      final messages = await collectErrors(
        tester,
        () => tester.pumpWidget(
          MaterialApp(
            home: AlertDialog(
              content: LayoutBuilder(
                builder: (context, constraints) => Text('$constraints'),
              ),
            ),
          ),
        ),
      );

      expect(
        messages.any(
          (message) => message.contains(
            'LayoutBuilder does not support returning intrinsic',
          ),
        ),
        isTrue,
        reason: 'The intrinsic-dimensions crash this suite guards against no '
            'longer reproduces. The hazard may have been fixed upstream, in '
            'which case this guard is dead weight and should be deleted.',
      );
    });

    testWidgets('an intrinsic wrapper around one throws too', (tester) async {
      // Unbounded height is what arms the intrinsic query: at fullscreen
      // size the wrapper lays out normally and nothing throws, so the
      // scroll view supplies the unbounded axis.
      final messages = await collectErrors(
        tester,
        () => tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[_ConstrainedWidget()],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        messages.any(
          (message) => message.contains(
            'LayoutBuilder does not support returning intrinsic',
          ),
        ),
        isTrue,
        reason: 'Expected the intrinsic wrapper to throw; got $messages',
      );
    });
  });

  group('the detector', () {
    testWidgets('walks past intermediate widgets to the real host',
        (tester) async {
      // A fixed-size Dialog renders fine — that is the documented workaround
      // for the intrinsic crash — so the tree survives long enough to
      // inspect. The point is that the ancestor walk reaches the Dialog
      // through the SizedBox and Padding in between, which is what real
      // dialogs look like.
      await tester.pumpWidget(
        MaterialApp(
          home: Dialog(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Padding(
                padding: EdgeInsets.zero,
                child: LayoutBuilder(
                  builder: (context, constraints) => Text('$constraints'),
                ),
              ),
            ),
          ),
        ),
      );

      final builders = layoutBuildersInTree(tester);
      expect(builders, hasLength(1));
      expect(hasAncestorOf<Dialog>(builders.single), isTrue);
      // The walk must also record what is genuinely absent, or a predicate
      // that always returns true would pass every guard below.
      expect(hasAncestorOf<AlertDialog>(builders.single), isFalse);
    });

    testWidgets('catches a LayoutBuilder inside a Table cell', (tester) async {
      // Table cells with default column widths render, so this is the
      // detector exercising a real forbidden host on a surviving tree.
      await tester.pumpWidget(
        MaterialApp(
          home: Table(
            children: const <TableRow>[
              TableRow(
                children: <Widget>[_ConstrainedWidget()],
              ),
            ],
          ),
        ),
      );

      expect(hasAncestorOf<Table>(layoutBuildersInTree(tester).single), isTrue);
    });

    testWidgets('accepts the ordinary hosts our widgets live in',
        (tester) async {
      // The negative control: a perfectly normal hosting must not be flagged.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                Card(
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        Text('${constraints.maxWidth}'),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (context, constraints) =>
                          Text('${constraints.maxHeight}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final builders = layoutBuildersInTree(tester);
      expect(builders, hasLength(2));
      for (final builder in builders) {
        expectNotUnderIntrinsicHost(builder, context: 'an ordinary Scaffold');
      }
    });
  });

  group('the listing grid', () {
    Future<void> pumpGrid(WidgetTester tester) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListingGrid(
                listings: <ListingSummary>[
                  _listing('1'),
                  _listing('2'),
                  _listing('3'),
                ],
                onLoadMore: () async {},
              ),
            ),
          ),
        );

    testWidgets('keeps its LayoutBuilder out of intrinsic hosts at every width',
        (tester) async {
      // The widths straddle the card-density threshold and the
      // one/two/three column transitions, so the builder runs under
      // materially different constraints rather than the same branch thrice.
      for (final width in <double>[320, 360, 400, 600, 720, 900, 1200]) {
        await resize(tester, Size(width, 800));
        await pumpGrid(tester);
        expectNoIntrinsicHost(tester, context: 'ListingGrid at $width wide');
      }
    });

    testWidgets('is clean when rendered without pagination', (tester) async {
      // Optional-callback path: the grid is inert but still builds, so the
      // guard still runs over real elements.
      await resize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListingGrid(
              listings: <ListingSummary>[_listing('1')],
              onLoadMore: () async {},
              onListingTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expectNoIntrinsicHost(
        tester,
        context: 'a ListingGrid without pagination',
      );
    });
  });

  group('the app shell', () {
    Future<void> pumpApp(WidgetTester tester, Size size) async {
      await resize(tester, size);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Pinned to zero so the shell never touches the network through
            // the stub Supabase client.
            unreadNotificationCountProvider.overrideWith((ref) async => 0),
          ],
          child: const UserApp(),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
    }

    // The shell holds the app-wide LayoutBuilder: it branches the navigation
    // affordance on window width. It is also the widget where a regression
    // would be most visible, because every screen inherits it.
    final widths = <String, Size>{
      'compact breakpoint': const Size(400, 800),
      'medium breakpoint': const Size(700, 900),
      'expanded breakpoint': const Size(1000, 900),
    };

    for (final entry in widths.entries) {
      testWidgets('is clean of intrinsic hosts at the ${entry.key}',
          (tester) async {
        await pumpApp(tester, entry.value);
        expectNoIntrinsicHost(tester, context: 'the shell at ${entry.key}');

        // Each branch must actually render, or the guard above is asserting
        // over a tree that never reached the shell's own builder.
        final width = entry.value.width;
        if (width >= 840) {
          expect(find.byType(AppDrawer), findsOneWidget);
        } else if (width >= 600) {
          expect(find.byType(NavigationRail), findsOneWidget);
        } else {
          expect(find.byType(BottomAppBar), findsOneWidget);
        }
      });
    }
  });
}

/// A [LayoutBuilder] whose builder is cheap and never throws.
class _ConstrainedWidget extends StatelessWidget {
  const _ConstrainedWidget();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Text('${constraints.maxWidth}'),
      );
}

/// Builds a summary with only the fields the card reads.
ListingSummary _listing(String id) => ListingSummary(
      id: id,
      sellerId: 'seller-1',
      title: 'House $id',
      district: 'Kathmandu',
      city: 'Kathmandu',
      priceNpr: 2500000,
      propertyType: PropertyType.house,
      listingPurpose: ListingPurpose.sale,
      createdAt: DateTime.utc(2026),
    );
