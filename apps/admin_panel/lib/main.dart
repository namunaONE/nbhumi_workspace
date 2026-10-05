import 'package:admin_panel/router/admin_router.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabasePublishableKey,
  );

  runApp(
    ProviderScope(
      // The admin panel is where moderation decisions happen, so its failures
      // are the ones that most need attribution. Without this observer a failed
      // provider went unrecorded entirely — AppProviderObserver routes provider
      // failures into AppLogger (Rule 37).
      observers: <ProviderObserver>[AppProviderObserver()],
      child: const AdminPanel(),
    ),
  );
}

/// Root widget for the nBhumi admin panel.
///
/// Deliberately Flutter-web-only: the project does not ship public web listings
/// because that would forfeit SEO, and this panel must never be indexed.
class AdminPanel extends ConsumerWidget {
  /// Creates the admin shell.
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the bridge guarantees the acting admin is attached to every log
    // entry from the first frame. Without it an approve or reject failure would
    // be attributed to `guest`, which for this app is worse than useless: the
    // audit trail in `audit_log` is the record of who did what, and an
    // unattributed client-side error is exactly what an audit is for.
    ref.watch(sessionLoggingBridgeProvider);
    final router = ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'nBhumi Admin',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ne')],
    );
  }
}
