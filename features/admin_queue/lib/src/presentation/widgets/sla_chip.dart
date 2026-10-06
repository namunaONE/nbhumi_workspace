import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// How long a queued listing has been waiting, as a compact label.
///
/// Resolved from [QueueSla] rather than formatting a duration here, so the
/// wording and the bucket cannot disagree: a row 40 hours old reads "Due soon"
/// and says "40h" from the same decision.
///
/// ### Why each bucket gets a different colour
///
/// Three states need three signals, and an admin scanning a queue reads colour
/// before text. [QueueSla.fresh] uses the scheme's own surface colour rather
/// than a green: most rows in a healthy queue are fresh, so colouring them all
/// green would make the rare amber and red rows *less* noticeable, not more.
/// Colour is spent on the exceptions.
///
/// Every chip pairs its fill with an explicit foreground from
/// [MarketplaceColors] so it meets contrast in both light and dark, and each
/// carries an icon as well as a colour, so the state is never conveyed by hue
/// alone.
class SlaChip extends StatelessWidget {
  /// Creates a chip for [sla].
  const SlaChip({required this.sla, this.waited, super.key});

  /// The bucket this chip represents.
  final QueueSla sla;

  /// How long the listing has waited, when the caller knows it.
  ///
  /// Shown as the secondary label so "Due soon" always sits beside the number
  /// that put it there. An admin deciding what to open next needs the hours,
  /// not just the verdict.
  final Duration? waited;

  /// Human label for the bucket.
  String get _label => switch (sla) {
        QueueSla.fresh => 'On time',
        QueueSla.atRisk => 'Due soon',
        QueueSla.breached => 'Overdue',
      };

  /// Icon for the bucket, so state is not colour-only.
  IconData get _icon => switch (sla) {
        QueueSla.fresh => Icons.check_circle_outline,
        QueueSla.atRisk => Icons.schedule,
        QueueSla.breached => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nullable extension with a fallback, matching `ListingCard`: a widget test
    // or any theme built without MarketplaceColors still renders instead of
    // throwing on `!`. Amber reads as "attend to this", so the fallback keeps
    // the
    // warning visible rather than falling back to a neutral that would hide the
    // only signal an at-risk row carries.
    final colors = theme.extension<MarketplaceColors>();
    final (warnFill, warnText) = colors == null
        ? (
            theme.colorScheme.tertiaryContainer,
            theme.colorScheme.onTertiaryContainer,
          )
        : (colors.saleOrange, colors.onSaleOrange);

    final (background, foreground) = switch (sla) {
      QueueSla.fresh => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
      QueueSla.atRisk => (warnFill, warnText),
      QueueSla.breached => (theme.colorScheme.error, theme.colorScheme.onError),
    };

    // Sub-hour waits render as the bare label. Rounding "12 minutes" down to
    // "0h" would read as an error rather than as a young listing.
    final hours = waited?.inHours;
    final detail = hours == null || hours < 1 ? null : '${hours}h';

    return Semantics(
      // Announced as one phrase: a screen reader should not read "Overdue" and
      // "72h" as two unrelated facts.
      label: detail == null ? _label : '$_label, waiting $detail',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_icon, size: 14, color: foreground),
            const SizedBox(width: 4),
            Text(
              detail == null ? _label : '$_label · $detail',
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
