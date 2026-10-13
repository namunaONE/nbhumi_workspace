import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_tokens.dart';

/// A card-shaped wrapper that adds keyboard/mouse focus affordance.
///
/// Material's [InkWell] handles tap and hover, but a visible focus ring is
/// required for keyboard users and web/desktop reviews. This wrapper preserves
/// the inner tap target, attaches keyboard shortcuts for `Enter`/`Space`, and
/// draws a 2dp ring in `ColorScheme.primary` around any focusable child.
///
/// Keep the inner [InkWell] (or other surface) so pointer-driven hover/ripple
/// and existing cursor tests continue to work next to the extra semantics.
class FocusableCard extends StatefulWidget {
  /// Creates a focusable card wrapper.
  const FocusableCard({
    required this.child,
    this.onTap,
    this.borderRadius = AppRadius.lg,
    this.enabled,
    super.key,
  });

  /// Wrapped surface.
  final Widget child;

  /// Tap handler. Null keeps the surface non-interactive for tab order, but the
  /// focus highlight is still possible for previews that want it.
  final VoidCallback? onTap;

  /// Radius used for the focus outline. Match the inner surface so the ring
  /// hugs the card.
  final double borderRadius;

  /// Whether the surface can receive tab focus. Defaults to whether [onTap] is
  /// supplied, which is what the primitive card callers want.
  final bool? enabled;

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard> {
  final FocusNode _focusNode = FocusNode();

  bool _focused = false;

  bool get _enabled => widget.enabled ?? widget.onTap != null;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusableActionDetector(
      focusNode: _focusNode,
      enabled: _enabled,
      mouseCursor: _enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const <SingleActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      onFocusChange: (value) {
        if (_focused != value && mounted) {
          setState(() => _focused = value);
        }
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_focused)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
