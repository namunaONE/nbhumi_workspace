// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'notifications_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get title => 'सूचनाहरू';

  @override
  String get markAllRead => 'सबै पढियो';

  @override
  String get emptyTitle => 'अहिलेसम्म कुनै सूचना छैन';

  @override
  String get emptyBody =>
      'अहिलेसम्म केही छैन। स्वीकृति, अस्वीकृति र सम्पर्क अवलोकन यहाँ देखिन्छ।';

  @override
  String get loadFailed => 'सूचनाहरू लोड गर्न सकिएन।';

  @override
  String get retry => 'पुनः प्रयास';
}
