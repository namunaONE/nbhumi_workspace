import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:google_fonts/google_fonts.dart';

/// Golden-test configuration for the user app (HYA-267).
///
/// Defaults: CI goldens render text as Ahem blocks, so the committed PNGs
/// compare identically on any host (dev machines vary; CI is Linux).
/// Regenerate deliberately with `flutter test --update-goldens` and review
/// the diff like code — a changed golden is either an intended redesign or
/// a regression, never noise.
Future<void> testExecutable(Future<void> Function() testMain) async {
  // The app theme sets its typeface through google_fonts, which fetches
  // font files over HTTP at runtime. The test binding answers every such
  // request with a 400, so fetching must be off: text falls back to the
  // test font (Ahem in CI goldens), which is exactly what makes the PNGs
  // platform-independent.
  GoogleFonts.config.allowRuntimeFetching = false;
  // Warm the bundled brand fonts before any test pumps. AppTheme's getters
  // rebuild per access and every first-use load is async: without warming,
  // a load can finish mid-capture and change text metrics between runs,
  // making goldens flaky. Warming lives in each golden file's setUpAll
  // (not here): this hook can run before the test binding swaps in
  // TestAssetBundle, and the lookup would miss. Afterwards every load
  // early-returns from google_fonts' cache, so rendering is deterministic.
  await AlchemistConfig.runWithConfig(
    // Platform (human-readable) goldens are disabled: their PNGs were never
    // committed (only goldens/ci/ is, per DESIGN.md §7), their files would
    // differ per host OS anyway, and the readable variant needs real fonts
    // that never load under flutter test (see above). The CI goldens are
    // the single compared set on every host, dev machine or CI.
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
