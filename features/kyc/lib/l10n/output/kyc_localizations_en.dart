// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'kyc_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Verify identity';

  @override
  String get howItWorks => 'How verification works';

  @override
  String get howItWorksBody => 'Our team checks that your document photo is readable and matches your account. This is an identity check only — never a legal or land-title verification. Ownership transfers are completed at Malpot.';

  @override
  String get submitDocument => 'Submit a document';

  @override
  String get emptyBody => 'No documents yet. Submit your citizenship to earn the verified badge buyers look for.';

  @override
  String get chooseDocument => 'Choose a document';

  @override
  String get pickAndSubmit => 'Pick photo and submit';

  @override
  String get uploading => 'Uploading…';

  @override
  String get submitted => 'Submitted — we review within 48 hours.';

  @override
  String get docCitizenship => 'Citizenship';

  @override
  String get docLalpurja => 'Lalpurja (land ownership)';

  @override
  String get docAgencyReg => 'Agency registration';

  @override
  String get statusPending => 'Pending review';

  @override
  String get statusVerified => 'Verified — identity checked';

  @override
  String get statusRejected => 'Rejected — submit a clearer photo';

  @override
  String get retry => 'Retry';

  @override
  String get loadFailed => 'Could not load your documents.';
}
