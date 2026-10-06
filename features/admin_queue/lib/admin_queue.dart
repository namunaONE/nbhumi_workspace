/// Admin verification queue feature for nBhumi.
///
/// Two queues live here. The verification queue (`AdminQueue`, `QueueList`)
/// reviews new listings. The reports queue (`AdminReports`, `ReportsList`)
/// works through buyer complaints (HYA-263). They share providers and
/// conventions, not widgets: their rows answer different questions and their
/// actions differ.
library;

export 'src/presentation/admin_listing_detail_screen.dart';
export 'src/presentation/admin_queue_screen.dart';
export 'src/presentation/admin_reports_screen.dart';
export 'src/presentation/widgets/reports_list.dart'
    show ReportsList, listingStatusLabel, reasonLabel, reportStatusLabel;
export 'src/providers/admin_access_providers.dart';
export 'src/providers/admin_queue_providers.dart';
export 'src/providers/admin_review_controller.dart';
export 'src/providers/reports_controller.dart';
export 'src/providers/reports_providers.dart';
