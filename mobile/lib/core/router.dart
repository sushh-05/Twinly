import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/screen.dart';
import '../features/onboarding/screen.dart';
import '../features/avatar/screen.dart';
import '../features/catalog/screen.dart';
import '../features/fitting/screen.dart';
import '../features/styling/screen.dart';
import '../features/saved_looks/screen.dart';
import '../features/paywall/screen.dart';
import '../features/saved_looks/detail_screen.dart';
import '../core/providers/saved_avatars_state.dart';

GoRouter createRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      // Pre-shell flow: not part of the bottom nav
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app shell with persistent 4-tab bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Avatar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/avatar',
                builder: (context, state) => const AvatarScreen(),
              ),
            ],
          ),
          // Tab 2: Catalog (+ styling, pushed on top — not built yet, kept for later)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogScreen(),
                routes: [
                  GoRoute(
                    path: 'styling',
                    builder: (context, state) => const StylingScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 3: Fitting
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fitting',
                builder: (context, state) => const FittingScreen(),
              ),
            ],
          ),
          // Tab 4: Account (+ saved looks and paywall, pushed on top — not tabs themselves)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'saved',
                    builder: (context, state) => const SavedLooksScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        builder: (context, state) {
                          final entry = state.extra as SavedAvatarEntry;
                          return SavedLookDetailScreen(entry: entry);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'paywall',
                    builder: (context, state) => const PaywallScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.accessibility_new_outlined),
            selectedIcon: Icon(Icons.accessibility_new),
            label: 'Avatar',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Fitting',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
