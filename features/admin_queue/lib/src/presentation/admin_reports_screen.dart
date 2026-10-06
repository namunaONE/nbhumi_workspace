import 'package:admin_queue/admin_queue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The buyer reports queue (HYA-263).
///
/// A separate screen rather than a tab inside the verification queue. The two
/// queues have different units — a listing to review versus a complaint to
/// judge — different actions, and different consequences for the seller.
/// Putting them behind one tab bar would make "Pending 12" ambiguous, and the
/// tab badge an admin reads to decide what to work on would no longer say
/// which queue is backed up.
///
/// The role gate is rendered here for the same reason as
/// [AdminQueueScreen]: the router cannot send an admin anywhere useful while
/// the role is still resolving, so it leaves the route alone and this screen
/// shows the wait.
class AdminReportsScreen extends ConsumerWidget {
  /// Creates the reports screen.
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessProvider);
    if (access.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Once the answer is "denied" the router has already redirected to
    // /forbidden, so this branch is only ever seen loading or granted.
    return const ReportsList();
  }
}
