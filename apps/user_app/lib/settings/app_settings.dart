import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted initial locale, overridden in `main()` with the stored value.
///
/// Widgets pumped without `main()` (every widget test) fall back to English
/// so they are never ambushed by persisted state.
final initialLocaleProvider = Provider<Locale>((ref) => const Locale('en'));

/// Persisted initial theme mode, overridden in `main()` the same way.
final initialThemeModeProvider =
    Provider<ThemeMode>((ref) => ThemeMode.system);

/// App locale: English / Nepali switcher (HYA-266).
///
/// A [Notifier] (not a `ChangeNotifier` + plain `Provider`) so that watching
/// the locale rebuilds dependents: `MaterialApp.locale` in `main.dart` and
/// the settings segmented control both follow changes without manual
/// listeners. State is the locale itself; persistence is a side effect.
class AppLocaleNotifier extends Notifier<Locale> {
  /// `shared_preferences` key. Versioned so a future locale reset can bump it.
  static const String localeKey = 'nbhumi.locale.v1';

  @override
  Locale build() => ref.watch(initialLocaleProvider);

  /// Reads the persisted locale. Defaults to English on fresh install.
  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(localeKey);
    if (code == 'ne' || code == 'en') return Locale(code!);
    return const Locale('en');
  }

  /// Sets the locale and persists it.
  ///
  /// Idempotent: setting the current locale is a no-op.
  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode;
    if (code != 'en' && code != 'ne') return;
    if (state.languageCode == code) return;
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, code);
  }
}

/// Current app locale.
final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale>(AppLocaleNotifier.new);

/// App theme mode: system / light / dark.
///
/// Same shape as [AppLocaleNotifier]: app chrome state owned by the shell,
/// persisted per install.
class AppThemeNotifier extends Notifier<ThemeMode> {
  /// `shared_preferences` key.
  static const String themeModeKey = 'nbhumi.themeMode.v1';

  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  /// Reads the persisted mode. Defaults to system on fresh install.
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Sets the mode and persists it.
  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      themeModeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }
}

/// Current app theme mode.
final appThemeProvider =
    NotifierProvider<AppThemeNotifier, ThemeMode>(AppThemeNotifier.new);
