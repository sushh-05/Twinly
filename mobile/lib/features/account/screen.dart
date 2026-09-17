import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_profiles_state.dart';
import '../../core/providers/theme_state.dart';
import '../../core/providers/usage_limits_state.dart';
import '../../core/providers/user_profile_state.dart';
import '../../widgets/avatar_profile_sheet.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/account_deletion_service.dart';
import '../../services/revenuecat_service.dart';

import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, this.asSettings = false});

  final bool asSettings;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileState>().value;
    final isPremium = context.watch<RevenueCatService>().isPremium;
    final usage = context.watch<UsageLimitsState>().state;
    final profilesState = context.watch<AvatarProfilesState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final buttonDarkBg = isDark
        ? const Color(0xFF222226)
        : Colors.grey.shade200;
    final buttonDarkText = isDark ? Colors.white : Colors.black87;

    final name = profile?.name != null && profile!.name.isNotEmpty
        ? profile.name
        : 'Anushila';

    final triesRemaining = (UsageLimits.freeTriesLimit - usage.triesUsed).clamp(
      0,
      UsageLimits.freeTriesLimit,
    );
    final savesRemaining = (UsageLimits.freeSavesLimit - usage.savesUsed).clamp(
      0,
      UsageLimits.freeSavesLimit,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          asSettings ? 'Settings' : 'Hi, $name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Theme Switcher button
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? Colors.amber : Colors.indigo.shade700,
            ),
            onPressed: () => context.read<ThemeModeState>().toggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.teal.withValues(alpha: 0.2),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.email != null && profile!.email.isNotEmpty
                              ? profile.email
                              : 'Logged in to Twinly',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Free Plan Usage Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPremium ? 'Premium plan' : 'Free plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Try-ons usage bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPremium
                            ? 'Unlimited try-ons'
                            : 'Try-ons remaining: $triesRemaining of ${UsageLimits.freeTriesLimit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${usage.triesUsed} used',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isPremium
                          ? 0.2
                          : (usage.triesUsed / UsageLimits.freeTriesLimit)
                                .clamp(0.0, 1.0),
                      backgroundColor: isDark
                          ? Colors.white12
                          : Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.teal,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Saved looks usage bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPremium
                            ? 'Unlimited saved looks'
                            : 'Saved looks: $savesRemaining of ${UsageLimits.freeSavesLimit}',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${usage.savesUsed} used',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isPremium
                          ? 0.3
                          : (usage.savesUsed / UsageLimits.freeSavesLimit)
                                .clamp(0.0, 1.0),
                      backgroundColor: isDark
                          ? Colors.white12
                          : Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.teal,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // My Avatar Section
            _sectionHeader('My avatar', textSecondary),
            const SizedBox(height: 8),
            _actionButton(
              label:
                  'Edit avatar (${profilesState.activeProfile?.name ?? "Me"})',
              bgColor: buttonDarkBg,
              textColor: buttonDarkText,
              onPressed: () => context.go('/avatar'),
            ),
            const SizedBox(height: 18),

            // Multiple Avatar Profiles Section (Fit for different people)
            _sectionHeader(
              'Avatar Profiles (${profilesState.profiles.length} saved)',
              textSecondary,
            ),
            const SizedBox(height: 8),
            _actionButton(
              label:
                  'Switch person / Manage profiles (Fitting for: ${profilesState.activeProfile?.name ?? "Me"})',
              bgColor: buttonDarkBg,
              textColor: buttonDarkText,
              onPressed: () => showAvatarProfileSheet(context),
            ),
            const SizedBox(height: 18),

            // Saved Looks Section
            _sectionHeader('Saved looks', textSecondary),
            const SizedBox(height: 8),
            _actionButton(
              label: 'View saved looks',
              bgColor: buttonDarkBg,
              textColor: buttonDarkText,
              onPressed: () => context.push('/account/saved'),
            ),
            const SizedBox(height: 18),

            // Plan Section
            _sectionHeader('Plan', textSecondary),
            const SizedBox(height: 8),
            _actionButton(
              label: isPremium ? 'Manage Subscription' : 'Upgrade to Premium',
              bgColor: isDark ? Colors.white : Colors.black87,
              textColor: isDark ? Colors.black : Colors.white,
              isBold: true,
              onPressed: () => context.push('/account/paywall'),
            ),
            const SizedBox(height: 22),

            // Privacy and Data Section
            _sectionHeader('Privacy and data', textSecondary),
            const SizedBox(height: 4),
            Text(
              'Photo consent settings (Phase 1).',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 10),
            _actionButton(
              label: 'Photo consent settings',
              bgColor: buttonDarkBg,
              textColor: buttonDarkText,
              onPressed: () => _showPhotoConsentDialog(context),
            ),
            const SizedBox(height: 10),
            _actionButton(
              label: 'Delete my local photo',
              bgColor: isDark ? const Color(0xFF2E2E34) : Colors.grey.shade300,
              textColor: textSecondary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local temporary photos cleared.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _actionButton(
              label: 'Delete my avatar data',
              bgColor: Colors.red.shade700,
              textColor: Colors.white,
              isBold: true,
              onPressed: () => _showDeleteAvatarConfirmation(context),
            ),
            const SizedBox(height: 24),

            _sectionHeader('Account deletion', textSecondary),
            const SizedBox(height: 8),
            _actionButton(
              label: 'Delete account',
              bgColor: Colors.red.shade700,
              textColor: Colors.white,
              isBold: true,
              onPressed: () => _deleteAccount(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Deletion currently removes the Firebase account only. Profile records, saved looks, and uploaded media need deletion workflows when those systems are added.',
              style: TextStyle(fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 18),
            _sectionHeader('Help and legal', textSecondary),
            const SizedBox(height: 8),
            _actionButton(
              label: 'Privacy policy',
              bgColor: buttonDarkBg,
              textColor: buttonDarkText,
              onPressed: () => _openLink(context, AppConfig.privacyPolicyUrl),
            ),
            const SizedBox(height: 8),
            _actionButton(
              label: 'Contact support',
              bgColor: buttonDarkBg,
              textColor: buttonDarkText,
              onPressed: () => _openLink(
                context,
                AppConfig.supportEmail.isEmpty
                    ? ''
                    : 'mailto:${AppConfig.supportEmail}',
              ),
            ),

            // Account & Session Management (Only Log out button kept)
            _sectionHeader('Account & Session', textSecondary),
            const SizedBox(height: 8),
            _actionButton(
              label: 'Log out',
              bgColor: Colors.red.withValues(alpha: 0.15),
              textColor: Colors.redAccent,
              isBold: true,
              onPressed: () => _confirmLogout(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
    bool isBold = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showPhotoConsentDialog(BuildContext context) {
    bool agreed = true;
    bool saveForFuture = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
          final textPrimary = isDark ? Colors.white : Colors.black87;
          final textSecondary = isDark ? Colors.white70 : Colors.black54;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: Colors.teal.shade400,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Use a photo for AI try-on',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Twinly needs one clear, front-facing full-body photo to create a visual try-on preview.\n\nYour photo will only be used for your try-on request. You can delete it later.',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: agreed,
                  activeColor: Colors.teal,
                  onChanged: (val) =>
                      setModalState(() => agreed = val ?? false),
                  title: Text(
                    'I agree to use my photo for this try-on preview',
                    style: TextStyle(fontSize: 13, color: textPrimary),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: saveForFuture,
                  activeThumbColor: Colors.teal,
                  onChanged: (val) => setModalState(() => saveForFuture = val),
                  title: Text(
                    'Save my photo for future try-ons',
                    style: TextStyle(fontSize: 13, color: textPrimary),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: agreed
                        ? () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Photo consent preferences updated.',
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black87,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Continue with photo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Not now — show avatar preview',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteAvatarConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
          title: const Text('Delete this look?'),
          content: const Text(
            'Your avatar data will be deleted from local temporary storage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (!context.mounted) return;
      await context.read<RevenueCatService>().logout();
      if (!context.mounted) return;
      await context.read<UserProfileState>().clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar data deleted from local storage.'),
          ),
        );
        context.go('/onboarding');
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This is permanent. Your Firebase account will be deleted. Local profile data and future saved media require separate cleanup when those systems exist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm permanent deletion'),
        content: const Text(
          'Are you sure you want to delete your Twinly account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep account'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (second != true || !context.mounted) return;
    final deletion = AccountDeletionService();
    var result = await deletion.deleteAccount(demoMode: AppConfig.demoMode);
    if (!context.mounted) return;
    if (result.requiresReauthentication) {
      final password = await _requestDeletionPassword(context);
      if (!context.mounted || password == null) return;
      result = await deletion.deleteAccount(
        demoMode: AppConfig.demoMode,
        reauthenticationPassword: password,
      );
    }
    if (!context.mounted) return;
    if (result.isComplete) {
      context.go('/onboarding');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.errors.join(' '))),
    );
  }

  Future<String?> _requestDeletionPassword(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm account deletion'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Firebase password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _openLink(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This link is not configured or could not be opened.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
          title: const Text('Log out?'),
          content: const Text(
            'You will be signed out of Twinly. You can sign up or log in again at any time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      await context.read<UserProfileState>().clear();
      if (context.mounted) {
        context.go('/onboarding');
      }
    }
  }
}
