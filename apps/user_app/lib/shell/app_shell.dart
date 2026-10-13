import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/l10n/output/app_localizations.dart';

/// The four destinations of the bottom navigation, in order.
///
/// Fixed count and fixed order: [StatefulShellRoute.indexedStack] maps branches
/// to indices positionally, so inserting one in the middle would silently
/// repoint every saved tab index. Posting is a center action, not a branch —
/// a fifth tab for it would waste a saved index on a route that owns no stack.
enum AppTab {
  /// Merged browse and search.
  explore('/', Icons.explore_outlined, Icons.explore, 'Explore'),

  /// Saved listings. Locked until M3 implements favourites (HYA-212).
  saved('/saved', Icons.favorite_outline, Icons.favorite, 'Saved'),

  /// The seller's own listings.
  myListings(
    '/my-listings',
    Icons.home_work_outlined,
    Icons.home_work,
    'My Listings',
  ),

  /// Account and seller actions.
  profile('/profile', Icons.person_outline, Icons.person, 'Profile');

  AppTab(this.route, this.icon, this.selectedIcon, this.label);

  /// Route this tab navigates to.
  final String route;

  /// Icon when the tab is not selected.
  final IconData icon;

  /// Icon when the tab is selected.
  final IconData selectedIcon;

  /// Bottom navigation label.
  final String label;

  /// Localized label for the destination.
  ///
  /// Kept separate from [label] (which stays English for the tab-order test):
  /// labels render from here everywhere.
  String localize(AppLocalizations strings) => switch (this) {
        AppTab.explore => strings.navExplore,
        AppTab.saved => strings.navSaved,
        AppTab.myListings => strings.navMyListings,
        AppTab.profile => strings.navProfile,
      };
}

/// Hosts the four tabs and adapts its navigation to the available width.
///
/// Compact (<600) gets a notched [BottomAppBar] with a center-docked post
/// button, medium (600-840) a [NavigationRail] with a trailing post action,
/// expanded (>=840) a [NavigationDrawer] with a post tile. Each branch
/// renders the same [navigationShell], so tab state survives a rotation or
/// a window resize.
///
/// Posting is an action, not a destination: it pushes `/post` (which owns
/// its own chrome and auth gate) instead of occupying a branch index.
///
/// The unread inbox badge lives on the notification bell in the Explore app
/// bar, not on any tab — a fifth badge tab would repoint saved indices, and
/// repeating a bell on every screen is what the single Explore entry avoids.
class AppShell extends ConsumerWidget {
  /// Wraps a [StatefulNavigationShell] in the appropriate navigation chrome.
  const AppShell({required this.navigationShell, super.key});

  /// The shell router's navigation state.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    // Tapping the active tab pops it back to its root, matching platform
    // convention. Guarded because an unconditional goBranch would reset it.
    if (index == navigationShell.currentIndex) {
      navigationShell.goBranch(index, initialLocation: true);
      return;
    }
    // The default initialLocation: false preserves each tab's own navigation
    // stack and scroll position rather than resetting to its root.
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    // LayoutBuilder, not MediaQuery: the shell sits inside the Scaffold
    // body, so its own constraints are the authoritative width and stay
    // correct across window resizes and split-screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.expanded) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                // DESIGN.md specifies a *permanent* drawer at this width, not a
                // hidden one behind a hamburger. On a tablet the destinations
                // are always visible and the label has room to breathe.
                AppDrawer(
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: _onDestinationSelected,
                  strings: strings,
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        if (constraints.maxWidth >= AppBreakpoints.medium) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: strings.postAction,
                    onPressed: () =>
                        GoRouter.of(context).push('/post'),
                  ),
                  destinations: <NavigationRailDestination>[
                    for (final tab in AppTab.values)
                      NavigationRailDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.selectedIcon),
                        label: Text(tab.localize(strings)),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          floatingActionButton: FloatingActionButton(
            tooltip: strings.postAction,
            onPressed: () => GoRouter.of(context).push('/post'),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 72,
              child: Row(
                children: <Widget>[
                  for (var i = 0; i < 2; i++)
                    _BarDestination(
                      tab: AppTab.values[i],
                      selected: i == navigationShell.currentIndex,
                      label: AppTab.values[i].localize(strings),
                      onTap: () => _onDestinationSelected(i),
                    ),
                  const Spacer(),
                  for (var i = 2; i < AppTab.values.length; i++)
                    _BarDestination(
                      tab: AppTab.values[i],
                      selected: i == navigationShell.currentIndex,
                      label: AppTab.values[i].localize(strings),
                      onTap: () => _onDestinationSelected(i),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One compact-bar destination with the M3 selected pill.
///
/// [NavigationBar] cannot host a center notch, so the compact bar is a
/// [BottomAppBar] row of these: icon in a pill plus a
/// small label, matching the bar's visual language without its widget.
class _BarDestination extends StatelessWidget {
  const _BarDestination({
    required this.tab,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        // Desktop affordance (DESIGN.md §6.5): destinations are always
        // tappable, so they always show the click cursor on hover.
        mouseCursor: SystemMouseCursors.click,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: AppDurations.interaction,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: selected
                  ? BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              child: Icon(
                selected ? tab.selectedIcon : tab.icon,
                color: selected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Always-visible navigation column used at the expanded breakpoint.
class AppDrawer extends StatelessWidget {
  /// Creates the expanded-width navigation column.
  const AppDrawer({
    required this.selectedIndex,
    required this.onSelected,
    required this.strings,
    super.key,
  });

  /// Index of the tab currently shown.
  final int selectedIndex;

  /// Called with the index of the tab the user tapped.
  final ValueChanged<int> onSelected;

  /// Localized strings for labels and the app title.
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: SizedBox(
          width: 220,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
                child: Text(
                  strings.appTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(strings.postAction),
                onTap: () => GoRouter.of(context).push('/post'),
              ),
              for (var i = 0; i < AppTab.values.length; i++)
                ListTile(
                  selected: i == selectedIndex,
                  selectedTileColor: theme.colorScheme.secondaryContainer,
                  leading: Icon(
                    i == selectedIndex
                        ? AppTab.values[i].selectedIcon
                        : AppTab.values[i].icon,
                  ),
                  title: Text(AppTab.values[i].localize(strings)),
                  onTap: () => onSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
