import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../services/revenuecat_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RevenueCatService>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<RevenueCatService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? Colors.black : const Color(0xFFF9FAFB);
    final primary = isDark ? Colors.white : const Color(0xFF111827);
    final secondary = isDark ? Colors.white70 : const Color(0xFF4B5563);
    final buttonBackground = isDark ? const Color(0xFF1E1E24) : Colors.grey.shade200;
    final buttonText = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: primary),
          onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : context.go('/avatar'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [Colors.amber.shade300.withValues(alpha: 0.35), Colors.transparent]),
              ),
              child: const Icon(Icons.workspace_premium, size: 72, color: Color(0xFFFFC107)),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock Twinly\nPremium',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary, height: 1.2),
            ),
            const SizedBox(height: 28),
            Text('Get:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary)),
            const SizedBox(height: 12),
            _benefitRow('More try-ons', primary),
            _benefitRow('Unlimited saved looks', primary),
            _benefitRow('Full fitting history', primary),
            const SizedBox(height: 24),
            if (service.isPremium) ...[
              Text(
                'Premium active',
                textAlign: TextAlign.center,
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ] else if (!service.isAvailable) ...[
              if (service.errorMessage != null)
                Text(
                  service.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondary),
                )
              else
                _demoPremiumPlaceholder(context),
            ] else if (service.loading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (service.errorMessage != null) ...[
              Text(
                service.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondary),
              ),
            ] else if (service.packages.isEmpty) ...[
              Text(
                'No premium plans are available yet. Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondary),
              ),
            ] else ...[
              for (final package in service.packages)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _purchase(service, package),
                    child: Text('Continue · ${package.storeProduct.priceString}'),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).canPop() ? Navigator.of(context).pop() : context.go('/avatar'),
                style: ElevatedButton.styleFrom(backgroundColor: buttonBackground, foregroundColor: buttonText, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                child: const Text('Not now', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
              ),
            ),
            if (service.isAvailable) ...[
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => _restore(service), child: const Text('Restore purchases')),
            ],
            const SizedBox(height: 18),
            Text(
              service.isAvailable
                  ? 'Subscriptions are managed by Google Play. Prices are supplied by the store.'
                  : 'Premium payments are coming soon.\n(Mock transaction for Phase 1 testing only)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: secondary, height: 1.3),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _openPrivacyPolicy, child: const Text('Privacy policy')),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          Text(text, style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _demoPremiumPlaceholder(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium payments are coming soon.')),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: const Text('Start Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _purchase(RevenueCatService service, Package package) async {
    final active = await service.purchase(package);
    if (active && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium active')));
    }
  }

  Future<void> _restore(RevenueCatService service) async {
    final active = await service.restore();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(active ? 'Premium restored.' : 'No active purchases found.')));
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.tryParse(AppConfig.privacyPolicyUrl);
    if (uri == null || AppConfig.privacyPolicyUrl.isEmpty || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy policy link is not configured.')));
    }
  }
}
