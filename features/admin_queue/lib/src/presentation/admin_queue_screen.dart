import 'package:admin_queue/admin_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/queue_list.dart';

/// The width at which the queue shows both panes.
///
/// Material's "medium" breakpoint is 600, chosen for *cards*. The queue is a
/// table-like view: a row needs room for a cover photo, a title, a price, an
/// SLA chip and a seller badge at once, and the detail pane needs room for a
/// photo strip beside the specification table. At 600 both panes are visibly
/// cramped; 840 is where the detail stops being a stack of narrow columns.
const double narrowBreakpoint = 840;

/// How wide the list is when both panes are visible.
///
/// Fixed rather than proportional. The detail pane's content is
/// width-sensitive,
/// so handing it the leftover space would make its layout swing as the window
/// resizes.
const double listPaneWidth = 400;

/// The admin verification queue.
///
/// Two panes on a wide window, one on a narrow one. Both read the same
/// providers, so the breakpoint is purely presentational: a resize neither
/// refetches nor loses the selected listing.
///
/// ### Why this is a page and not a stack
///
/// An admin works a queue — read one, decide, come back to the list. Pushing a
/// route per listing would bury the list under a history to pop back through,
/// and would lose the list's scroll position on every decision.
class AdminQueueScreen extends ConsumerWidget {
  /// Creates the queue.
  ///
  /// [onOpenReports] is forwarded to the list's reports affordance; see
  /// [QueueList] for why it is a callback rather than a route name.
  const AdminQueueScreen({super.key, this.onOpenReports});

  /// Called when the admin chooses the reports queue.
  final VoidCallback? onOpenReports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The role gate is rendered here rather than only in `redirect`. The router
    // cannot send an admin anywhere useful while the role is still resolving,
    // so it leaves the route alone and this screen shows the wait. Once the
    // answer is "denied" the router has already redirected to /forbidden, so
    // this branch is only ever seen loading or granted.
    final access = ref.watch(adminAccessProvider);
    if (access.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selectedId = ref.watch(adminSelectedListingProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= narrowBreakpoint) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                SizedBox(
                  width: listPaneWidth,
                  child: QueueList(onOpenReports: onOpenReports),
                ),
                const VerticalDivider(width: 1),
                // Keyed on the id so switching listings discards the previous
                // pane rather than keeping its scroll offset — otherwise a long
                // description scrolled halfway would carry that offset to the
                // next listing.
                Expanded(
                  key: ValueKey<String?>(selectedId),
                  child: AdminListingPane(listingId: selectedId),
                ),
              ],
            ),
          );
        }

        // One pane: the detail replaces the list, with a back button in its own
        // app bar. Driven by state rather than a pushed route, so go_router's
        // redirect handles `/listing/:id` once and both the browser back button
        // and the escape key work without a nested navigator.
        if (selectedId != null) {
          return AdminListingPane(
            listingId: selectedId,
            onBack: () =>
                ref.read(adminSelectedListingProvider.notifier).clear(),
          );
        }

        return Scaffold(
          body: QueueList(onOpenReports: onOpenReports),
        );
      },
    );
  }
}

/// The detail pane, for both layouts.
///
/// Split out because the layouts place it differently and disagree about its
/// chrome: the narrow one needs a back button, the wide one must not have one,
/// since there is no stack to go back to and an arrow there would have nowhere
/// to lead.
///
/// A null [listingId] renders the empty prompt rather than a spinner — nothing
/// is loading, and "select a listing" is the actual instruction.
class AdminListingPane extends ConsumerWidget {
  /// Creates a pane for [listingId].
  const AdminListingPane({required this.listingId, this.onBack, super.key});

  /// The listing to show, or null for the empty prompt.
  final String? listingId;

  /// Called by the narrow layout's back button. Null in the wide layout.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = listingId;

    if (id == null) return const Scaffold(body: _NothingSelected());

    return AdminListingDetailScreen(listingId: id, onBack: onBack);
  }
}

/// Shown in the wide layout's detail pane before anything is selected.
class _NothingSelected extends StatelessWidget {
  const _NothingSelected();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Select a listing to review it.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The route path prefix for one listing.
///
/// Duplicated from the router's own path rather than imported from it, because
/// `go_router` is not a dependency of this feature: importing it would couple
/// the feature to a navigation library its screens never use. The admin panel's
/// router test asserts the two agree.
const String adminListingRoutePrefix = '/listing';
