import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/saved_avatars_state.dart';
import '../../core/providers/usage_limits_state.dart';
import '../../core/providers/user_profile_state.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final usage = ref.watch(usageLimitsProvider);
    final savedLooks = ref.watch(savedAvatarsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name ?? 'Guest',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subscription status
            Card(
              color: isPremium ? Colors.deepPurple.shade50 : null,
              child: ListTile(
                leading: Icon(
                  isPremium ? Icons.workspace_premium : Icons.lock_outline,
                  color: isPremium ? Colors.deepPurple : Colors.grey,
                ),
                title: Text(isPremium ? 'Premium' : 'Free plan'),
                subtitle: Text(
                  isPremium
                      ? 'Unlimited try-ons and saves'
                      : '${usage.triesUsed}/${UsageLimits.freeTriesLimit} try-ons used · '
                            '${usage.savesUsed}/${UsageLimits.freeSavesLimit} saves used',
                ),
                trailing: isPremium
                    ? null
                    : ElevatedButton(
                        onPressed: () => context.push('/account/paywall'),
                        child: const Text('Upgrade'),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Saved looks
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Saved looks'),
              subtitle: Text('${savedLooks.length} saved'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/account/saved'),
            ),
            const Divider(),

            // Log out
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log out', style: TextStyle(color: Colors.red)),
              onTap: () => _confirmLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You\'ll need to sign up again to use Twinly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(userProfileProvider.notifier).clear();
    if (context.mounted) context.go('/onboarding');
  }
}
