/// Seller KYC feature for nBhumi.
///
/// Tier 2 identity checks (HYA-264) and Tier 3 per-listing checks (HYA-265)
/// share one flow: pick a document photo, upload it to the private
/// `kyc-documents` bucket, submit it for admin doc-check, and track the
/// verdict. Doc-check only — a verified badge means an admin looked at the
/// file, never legal or title verification.
library;

export 'src/presentation/kyc_screen.dart';
export 'src/viewmodels/kyc_providers.dart';
