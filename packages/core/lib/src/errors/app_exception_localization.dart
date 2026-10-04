import 'package:flutter/widgets.dart';

import 'app_exception.dart';

/// Picks the right language for a user-facing error message (Rule 36).
///
/// [AppException.message] prefers Nepali, which is the right default for the
/// primary market but wrong for an app running in English. Calling it directly
/// from a widget silently shows Nepali to an English user, so widgets go
/// through this instead: one place to fix when a third language is added.
///
/// Nepali is also the fallback for any locale that is not English, because the
/// pair is fixed and there is no third message to choose.
extension AppExceptionLocalization on AppException {
  /// The message for [locale].
  String localized(Locale locale) =>
      message(preferNepali: locale.languageCode != 'en');

  /// The message for the locale currently in effect, read from the context.
  ///
  /// Falls back to Nepali if no [Localizations] ancestor is present, so a
  /// widget pumped without `MaterialApp.localizationsDelegates` still renders
  /// rather than throwing.
  String localizedForContext(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return localized(locale ?? const Locale('ne'));
  }
}
