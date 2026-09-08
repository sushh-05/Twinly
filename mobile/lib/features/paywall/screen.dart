import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/usage_limits_state.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF9FAFB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF4B5563);
    final buttonSecondaryBg = isDark ? const Color(0xFF1E1E24) : Colors.grey.shade200;
    final buttonSecondaryText = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : context.go('/catalog'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Golden Crown Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.shade300.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 72,
                  color: Color(0xFFFFC107),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Unlock Twinly\nPremium',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),

              // Feature Bullets
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _benefitRow('More try-ons', textPrimary),
                      const SizedBox(height: 8),
                      _benefitRow('Unlimited saved looks', textPrimary),
                      const SizedBox(height: 8),
                      _benefitRow('Full fitting history', textPrimary),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Primary Action: Start Premium
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Toggle mock premium
                    ref.read(isPremiumProvider.notifier).setPremium(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Twinly Premium unlocked!')),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Start Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Action: Not now
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonSecondaryBg,
                    foregroundColor: buttonSecondaryText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Not now',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Disclaimer
              Text(
                'Premium payments are coming soon.\n(Mock transaction for Phase 1 testing only)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitRow(String text, Color color) {
    return Row(
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 18, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
