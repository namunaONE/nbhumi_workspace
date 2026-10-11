import 'package:flutter/material.dart';

/// Names the browser tab after the current destination.
///
/// Flutter's [Title] widget drives `document.title` on web and is inert
/// everywhere else, so wrapping a route's root is free on mobile. Embodied
/// here rather than in any router because feature screens cannot import an
/// app's router (Rule 10) while every feature already imports core — one
/// helper, one suffix, every tab titled the same way.
///
/// The side-pane variant of a screen must NOT use this: only the full route
/// owns the tab. (e.g. `ListingDetailScreen` titles; `ListingDetailPane`
/// does not.)
class PageTitle extends StatelessWidget {
  /// Creates a tab title of "`title` · nBhumi" around [child].
  const PageTitle({required this.title, required this.child, super.key});

  /// The destination name, already localized by the caller.
  final String title;

  /// The route's root widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Title(
      title: '$title · nBhumi',
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}
