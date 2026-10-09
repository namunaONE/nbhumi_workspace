import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Test configuration for the core package.
///
/// The app theme sets its typeface through google_fonts, which fetches font
/// files over HTTP at runtime. The test binding answers every such request
/// with a 400, so fetching must be off: text falls back to the bundled test
/// font instead of throwing mid-test.
Future<void> testExecutable(Future<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
