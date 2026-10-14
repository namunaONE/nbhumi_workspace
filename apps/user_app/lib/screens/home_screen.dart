import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:search/search.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// Landing screen: the browse feed.
///
/// ### One feed, shared with Search
///
/// Home and Search both render `browseProvider`, so there is a single browse
/// session for the app and filters set on Search are still in force when the
/// user returns to Home. That is deliberate — a filter that silently resets on
/// a tab switch, or a second feed refetching the same pages, would both be
/// more surprising than a filter that persists. The active-filter badge on the
/// Search tab makes the shared state visible.
class HomeScreen extends StatelessWidget {
  /// Creates the landing screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: strings.searchListingsTooltip,
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: strings.postPropertyTooltip,
            onPressed: () => context.push('/post'),
          ),
        ],
      ),
      body: BrowseFeed(
        onListingTap: (id) => context.push('/listing/$id'),
        emptyTitle: strings.homeEmptyTitle,
        emptyBody: strings.homeEmptyBody,
      ),
    );
  }
}
