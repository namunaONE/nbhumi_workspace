/// One photo to attach to a listing (HYA-300).
///
/// Carries the public URL the widgets render alongside the object key the
/// duplicate-photo signal groups on. A null path preserves the old url-only
/// behaviour for rows attached before paths were persisted.
///
/// Lives in models rather than data because both the repository (which writes
/// it) and the post-listing wizard state (which carries it) need the type,
/// and packages never import features (Rule 10).
typedef PhotoAttachment = ({String url, String? storagePath});
