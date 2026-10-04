import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The four destinations of the bottom navigation, in order.
///
/// Fixed count and fixed order: [StatefulShellRoute.indexedStack] maps branches
/// to indices positionally, so inserting one in the middle would silently
/// repoint every saved tab index.
enum AppTab {
  /// Browse the feed.
  home('/', Icons.home_outlined, Icons.home, 'Home'),

  /// Search and filter.
  search('/search', Icons.search_outlined, Icons.search, 'Search'),

  /// Saved listings. Locked until M3 implements favourites (HYA-212).
  saved('/saved', Icons.favorite_outline, Icons.favorite, 'Saved'),

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
}

/// Layout widths at which the navigation affordance changes.
///
/// Material's 600 and 840 breakpoints, matching DESIGN.md. Widths are read from
/// [MediaQuery] rather than [LayoutBuilder] because the shell decides app-level
/// chrome, not a component within a constrained parent.
abstract final class AppBreakpoints {
  /// Below this, bottom navigation.
  static const double medium = 600;

  /// At or above this, a permanent drawer and master-detail layouts.
  static const double expanded = 840;
}

/// Hosts the four tabs and adapts its navigation to the available width.
///
/// Compact (<600) gets a [NavigationBar], medium (600-840) a [NavigationRail],
/// expanded (>=840) a [NavigationDrawer]. Each branch renders the same
/// [navigationShell], so tab state survives a rotation or a window resize.
class AppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  destinations: <NavigationRailDestination>[
                    for (final tab in AppTab.values)
                      NavigationRailDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.selectedIcon),
                        label: Text(tab.label),
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
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: <NavigationDestination>[
              for (final tab in AppTab.values)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Always-visible navigation column used at the expanded breakpoint.
class AppDrawer extends StatelessWidget {
  /// Creates the expanded-width navigation column.
  const AppDrawer({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  /// Index of the tab currently shown.
  final int selectedIndex;

  /// Called with the index of the tab the user tapped.
  final ValueChanged<int> onSelected;

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
                child: Text('nBhumi', style: theme.textTheme.titleLarge),
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
                  title: Text(AppTab.values[i].label),
                  onTap: () => onSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
