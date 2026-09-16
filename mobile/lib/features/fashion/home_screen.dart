import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/fashion_state.dart';

class FashionHomeScreen extends StatelessWidget {
  const FashionHomeScreen({super.key});
  String _greeting() {
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<FashionProfileState>().profile;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Twinly'),
        actions: [
          IconButton(
            onPressed: () => context.push('/account'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(_greeting(), style: theme.textTheme.displaySmall),
          Text(
            'Your visual wardrobe starts here.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: const Color(0xffe7d4ca),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 72,
                  color: Color(0xffa06b5b),
                ),
                Text(
                  '${profile?.bodyShape ?? 'your'} twin',
                  style: theme.textTheme.titleLarge,
                ),
                const Text('Placeholder visual — not a finished 3D avatar'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to try something on?',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload a garment or paste a product link. We’ll turn it into a style preview.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/try-on'),
                    child: const Text('Start a try-on'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/premium'),
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }
}
