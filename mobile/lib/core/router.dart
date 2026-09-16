import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/screen.dart';
import '../features/avatar/screen.dart';
import '../features/catalog/screen.dart';
import '../features/fashion/profile_onboarding_screen.dart';
import '../features/fashion/saved_looks_screen.dart';
import '../features/fashion/try_on_screen.dart';
import '../features/fitting/screen.dart';
import '../features/onboarding/screen.dart';
import '../features/paywall/screen.dart';
import '../features/settings/screen.dart';

GoRouter createRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const ProfileOnboardingScreen(),
      ),
      GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/account/paywall', builder: (_, _) => const PaywallScreen()),
      GoRoute(path: '/account/saved', builder: (_, _) => const FashionSavedLooksScreen()),
      GoRoute(path: '/premium', builder: (_, _) => const PaywallScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => ScaffoldWithNavBar(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/avatar', builder: (_, _) => const AvatarScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (_, _) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/try-on', builder: (_, _) => const TryOnScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (_, _) => const FashionSavedLooksScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/fitting', builder: (_, _) => const FittingScreen()),
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
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Avatar',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Try On',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved Looks',
          ),
        ],
      ),
    );
  }
}
