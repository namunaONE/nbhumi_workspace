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
  await AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(),
    run: testMain,
  );
}
