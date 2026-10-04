import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_app/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabasePublishableKey,
  );

  runApp(
    ProviderScope(
      // AppProviderObserver records provider failures into AppLogger.
      // Session attribution is a provider rather than a second observer,
      // because it needs a Ref to watch the session and ProviderObserver
      // deliberately does not expose one.
      observers: <ProviderObserver>[AppProviderObserver()],
      child: const UserApp(),
    ),
  );
}

/// Root widget for the nBhumi user app.
///
/// Owns nothing but the [MaterialApp] shell: routing comes from
/// [appRouterProvider] so that auth redirects stay in one place.
class UserApp extends ConsumerWidget {
  /// Creates the app shell.
  const UserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the bridge here guarantees log entries are attributed from the
    // very first frame, rather than only after something first reads a session.
    ref.watch(sessionLoggingBridgeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'nBhumi',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      // Wired now so M3's Nepali localisation only has to add .arb files
      // rather than also reworking every app entry point.
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
    );
  }
}
