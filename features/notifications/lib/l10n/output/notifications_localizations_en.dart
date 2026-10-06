// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get emptyBody => 'Nothing yet. Approvals, rejections and contact views appear here.';

  @override
  String get loadFailed => 'Could not load notifications.';

  @override
  String get retry => 'Retry';
}
