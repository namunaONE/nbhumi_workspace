import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:auth/auth.dart';
import 'package:data/data.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/router/app_router.dart';

/// Starts the deep-link handler for the lifetime of the widget (HYA-257).
///
/// A non-visual wrapper: it owns an [AuthLinkHandler] from `initState` to
/// `dispose` and renders [child] untouched. Auth callbacks are exchanged for
/// a session through `AuthService`; in-app routes (shared listing links) go
/// to the router.
///
/// [getInitialLinkOverride] and [linkStreamOverride] exist for widget tests,
/// where the real `AppLinks` plugin has no platform implementation. Production
/// code never passes them.
class DeepLinkListener extends ConsumerStatefulWidget {
  /// Creates a listener around the app.
  const DeepLinkListener({
    required this.child,
    super.key,
    this.getInitialLinkOverride,
    this.linkStreamOverride,
  });

  /// The subtree that stays mounted while links are handled.
  final Widget child;

  /// Test-only cold-start link source.
  final Future<Uri?> Function()? getInitialLinkOverride;

  /// Test-only warm-link source.
  final Stream<Uri>? linkStreamOverride;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  late final AuthLinkHandler _handler;

  @override
  void initState() {
    super.initState();
    final appLinks = widget.getInitialLinkOverride == null &&
            widget.linkStreamOverride == null
        ? AppLinks()
        : null;
    _handler = AuthLinkHandler(
      getInitialLink:
          widget.getInitialLinkOverride ?? appLinks!.getInitialLink,
      linkStream: widget.linkStreamOverride ?? appLinks!.uriLinkStream,
      onAuthCallback: (uri) =>
          ref.read(authServiceProvider).exchangeSessionFromUrl(uri),
      onAppRoute: (location) => ref.read(appRouterProvider).go(location),
      onAuthError: (error) => ref.read(appRouterProvider).go(
            error.code == 'auth.linkExpired'
                ? '/auth/callback?error=expired'
                : '/auth/callback?error=failed',
          ),
    );
    unawaited(_handler.start());
  }

  @override
  void dispose() {
    unawaited(_handler.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
