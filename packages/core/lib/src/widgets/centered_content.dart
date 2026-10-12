import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Caps a content column on wide windows.
///
/// Phones pass through untouched (their width is under every cap); desktops
/// center instead of stretching. Place **directly around the scrollable**
/// (ListView, GridView, SingleChildScrollView, RefreshIndicator) so the
/// viewport provides bounded height and the scrollable never collapses.
///
/// Does NOT use `Align` (which breaks intrinsic height for scrollables) — just
/// a `ConstrainedBox` with `maxWidth`. This composes safely with any parent,
/// including the shell's `LayoutBuilder` and `SelectionArea`.
class CenteredContent extends StatelessWidget {
  /// Creates a capped content wrapper around [child].
  const CenteredContent({
    required this.child,
    this.maxWidth = AppContentWidths.reading,
    super.key,
  });

  /// The scrollable content to cap and center.
  final Widget child;

  /// Maximum width in logical pixels.
  ///
  /// One of [AppContentWidths] — [AppContentWidths.form] for auth-style
  /// single columns, [AppContentWidths.reading] for detail/wizard/profile,
  /// [AppContentWidths.feed] for wide grids. Never a literal (Rule 43).
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}
