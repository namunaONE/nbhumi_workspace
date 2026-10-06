/// In-app notification inbox for nBhumi (HYA-242 B3).
///
/// Listing/KYC verdicts fanned out by the B2 migration land here over
/// Realtime; push and SMS delivery are a documented follow-up requiring
/// FCM keys and an SMS provider account, neither of which exists yet.
library;

export 'src/presentation/notifications_screen.dart';
export 'src/viewmodels/notifications_providers.dart';
