import 'package:admin_queue/admin_queue.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

/// Widget tests for the fraud signals panel (HYA-261).
///
/// Signals are read-only context for the decision, so these assert what the
/// admin is shown -- warnings with a count, a checked-and-clear state, and an
/// inline retry that never blocks the approve/reject bar. The provider is
/// overridden directly (Rule 33); the repository fake below exists only to
/// satisfy the interface.
void main() {
  const signals = ListingFraudSignals(
    listingId: 'l1',
    signals: [
      FraudSignal(
        code: FraudSignalCode.duplicatePhoto,
        severity: FraudSeverity.warning,
        messageEn: 'Same photo appears on another listing.',
        messageNe: 'उही फोटो अर्को लिस्टिङमा पनि देखिन्छ।',
      ),
      FraudSignal(
        code: FraudSignalCode.missingKitta,
        messageEn: 'No kitta number provided.',
        messageNe: 'कित्ता नम्बर दिइएको छैन।',
      ),
    ],
  );

  Future<void> pumpPanel(
    WidgetTester tester, {
    required Object? signalsOverride,
  }) async {
    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(_FakeAdminRepository()),
        if (signalsOverride is ListingFraudSignals)
          fraudSignalsProvider('l1').overrideWithValue(
            AsyncValue.data(signalsOverride),
          )
        else
          fraudSignalsProvider('l1').overrideWithValue(
            AsyncValue.error(
              signalsOverride!,
              StackTrace.empty,
            ),
          ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: FraudSignalsPanel(listingId: 'l1')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('with signals', () {
    testWidgets('warnings render with a count and their messages', (
      tester,
    ) async {
      await pumpPanel(tester, signalsOverride: signals);

      expect(find.text('Fraud signals (1)'), findsOneWidget);
      expect(
        find.text('Same photo appears on another listing.'),
        findsOneWidget,
      );
      expect(find.text('No kitta number provided.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });
  });

  group('with nothing suspicious', () {
    testWidgets('an empty set reads as checked, not as missing', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        signalsOverride: const ListingFraudSignals(listingId: 'l1'),
      );

      expect(find.text('No fraud signals.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('when the read fails', () {
    testWidgets('an inline retry is offered without blocking', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        signalsOverride: const NetworkException(
          code: 'network.timeout',
          messageEn: 'Timed out. Check your connection.',
          messageNe: 'समय सकिएको छैन। इन्टरनेट जाँच्नुहोस्।',
        ),
      );

      expect(
        find.text('Timed out. Check your connection.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      // The retry re-reads rather than crashing: the provider still fails,
      // and the panel still shows the error instead of a spinner forever.
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

/// Repository stub: the panel reads through an overridden provider, so no
/// method here is ever called. Stubs throw rather than answer, so a test that
/// reaches the network fails loudly instead of passing on an empty default.
class _FakeAdminRepository implements AdminRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
        '${invocation.memberName} is not covered by these tests',
      );
}
