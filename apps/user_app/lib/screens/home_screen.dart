import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:search/search.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('nBhumi'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search listings',
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Post a property',
            onPressed: () => context.push('/post'),
          ),
        ],
      ),
      body: BrowseFeed(
        onListingTap: (id) => context.push('/listing/$id'),
        emptyTitle: 'No properties listed yet',
        emptyBody: 'Be the first to post one. Listings appear here as soon as '
            'they go live.',
      ),
    );
  }
}
