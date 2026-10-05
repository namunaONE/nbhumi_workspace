/// Authentication feature for nBhumi.
///
/// Magic link first, email + password as the alternative: the login screen
/// offers both and neither is forced (DATA.md's password ban was lifted by
/// owner decision — see `AuthService`).
library;

export 'src/deep_links/auth_link_handler.dart';
export 'src/deep_links/deep_link_target.dart';
export 'src/presentation/auth_callback_screen.dart';
export 'src/presentation/login_screen.dart';
export 'src/viewmodels/auth_viewmodel.dart';
