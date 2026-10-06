/// Shared data models for nBhumi.
///
/// Wire models are split by wire format rather than by domain concept:
///
/// * `Listing`          - what a seller writes. Accepted by `v1_create_listing`
///                       and `v1_update_listing`.
/// * `ListingSummary`   - what browse returns. See `v1_get_listings`.
/// * `ListingDetail`    - what the detail page returns. See
///                       `v1_get_listing_detail`.
/// * `ListingFilter`    - browse query state, not a wire model.
/// * `SellerContact`    - the only model carrying a seller's phone or email.
///                       Released by `v1_contact_seller` under a daily cap.
/// * `District`         - reference data. `region` decides hill vs terai area
///                       units throughout the app (Rule 25).
/// * `Municipality`     - reference data. `slug` identifies a local body
///                       (names recur across districts); `wardCount` sizes the
///                       wizard's ward picker.
/// * `AdminQueueEntry`  - one row of the verification queue. Admin-scoped.
///                       See `v1_admin_get_queue`.
/// * `QueueSla`         - how a queued listing stands against the 48h SLA.
///                       Computed client-side, not by the RPC.
/// * `AuditLogEntry`    - one admin action. Every approve/reject writes one.
library;

export 'src/admin_queue_entry.dart';
export 'src/district.dart';
export 'src/kyc_document.dart';
export 'src/listing.dart';
export 'src/listing_detail.dart';
export 'src/listing_query.dart';
export 'src/listing_summary.dart';
export 'src/municipality.dart';
export 'src/notification.dart';
export 'src/profile.dart';
export 'src/queue_sla.dart';
export 'src/saved_search.dart';
export 'src/seller_contact.dart';
