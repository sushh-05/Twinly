import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_profiles_state.dart';
import '../../core/providers/avatar_state.dart';
import '../../core/providers/garment_state.dart';
import '../../core/providers/saved_avatars_state.dart';
import '../../core/providers/usage_limits_state.dart';
import '../../models/garment.dart';
import '../../widgets/avatar_profile_sheet.dart';
import '../../widgets/garment_image.dart';
import '../avatar/body_painter.dart';

class FittingScreen extends ConsumerStatefulWidget {
  const FittingScreen({super.key});

  @override
  ConsumerState<FittingScreen> createState() => _FittingScreenState();
}

class _FittingScreenState extends ConsumerState<FittingScreen> {
  String? _registeredForGarmentId;
  String _preferredFit = 'regular';
  bool _showDressPhoto = true;

  @override
  Widget build(BuildContext context) {
    final garment = ref.watch(selectedGarmentProvider);
    final measurements = ref.watch(avatarMeasurementsProvider);
    final usage = ref.watch(usageLimitsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final profilesState = ref.watch(avatarProfilesProvider);
    final activeProfile = profilesState.activeProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B7280);

    // If reached without a selected garment
    if (garment == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text('Fitting', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checkroom_outlined, size: 64, color: textSecondary),
              const SizedBox(height: 16),
              Text(
                'No dress selected yet',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Pick a garment from the catalog to try on.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Go to Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final atFreeLimit = !isPremium && usage.triesUsed >= UsageLimits.freeTriesLimit;
    final isNewGarment = garment.id != usage.lastCountedGarmentId;

    if (atFreeLimit && isNewGarment) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text('Fitting', style: TextStyle(color: textPrimary)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  "You've used your ${UsageLimits.freeTriesLimit} free try-ons",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upgrade to Twinly Premium for unlimited try-ons and full fitting analytics.',
                  style: TextStyle(color: textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/account/paywall'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_registeredForGarmentId != garment.id) {
      _registeredForGarmentId = garment.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(usageLimitsProvider.notifier).registerTryIfNew(garment.id, isPremium: isPremium);
      });
    }

    // Determine recommended size based on measurements & garment size chart
    final recommendedSize = _computeRecommendedSize(garment, measurements);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.go('/catalog'),
        ),
        title: Text(
          'Fitting',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: textPrimary),
        ),
        actions: [
          // Toggle between dress catalog portrait & 2D custom avatar view
          TextButton.icon(
            onPressed: () => setState(() => _showDressPhoto = !_showDressPhoto),
            icon: Icon(
              _showDressPhoto ? Icons.accessibility_new : Icons.photo_outlined,
              color: Colors.teal.shade400,
              size: 18,
            ),
            label: Text(
              _showDressPhoto ? 'Avatar' : 'Dress',
              style: TextStyle(color: Colors.teal.shade400, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Person Switcher Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => showAvatarProfileSheet(context, ref),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF182828) : Colors.teal.shade50.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.teal,
                                child: Icon(
                                  measurements.isFeminine ? Icons.female : Icons.male,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Fitting for: ${activeProfile?.name ?? "Me"} (${activeProfile?.sizePreset ?? "S"})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.teal.shade200 : Colors.teal.shade900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down, color: Colors.teal.shade400, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      tooltip: 'Add new person',
                      color: Colors.teal.shade400,
                      onPressed: () => showAvatarProfileSheet(context, ref),
                    ),
                  ],
                ),
              ),

              // Visual Preview Container
              Center(
                child: Container(
                  height: 340,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _showDressPhoto
                      ? GarmentImage(garment: garment)
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(260, 320),
                              painter: BodyPainter(
                                height: measurements.height,
                                chest: measurements.chest,
                                waist: measurements.waist,
                                hip: measurements.hip,
                                inseam: measurements.inseam,
                                isSideView: false,
                              ),
                            ),
                            Positioned(
                              top: 60,
                              child: Container(
                                width: 85,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.teal, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Fit Estimate Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your fit estimate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Recommended size: $recommendedSize',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade600, width: 0.8),
                          ),
                          child: Text(
                            'Confidence: Medium',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Based on your measurements, your fit preference (${_preferredFit.substring(0, 1).toUpperCase()}${_preferredFit.substring(1)}), and this dress\'s verified size chart.',
                      style: TextStyle(fontSize: 12.5, color: textSecondary, height: 1.3),
                    ),
                    const SizedBox(height: 16),

                    // Fit Breakdown Rows
                    _fitMetricRow(
                      icon: Icons.accessibility_new,
                      label: 'Bust',
                      badge: 'Comfortable',
                      badgeColor: Colors.teal,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: 10),
                    _waistMetricRow(
                      measurements: measurements,
                      recommendedSize: recommendedSize,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: 10),
                    _fitMetricRow(
                      icon: Icons.airline_seat_legroom_normal,
                      label: 'Hips',
                      badge: 'Comfortable',
                      badgeColor: Colors.teal,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: 10),
                    _fitMetricRow(
                      icon: Icons.straighten,
                      label: 'Length',
                      sublabel: 'below-knee length',
                      badge: 'Estimated',
                      badgeColor: Colors.blueGrey,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(height: 18),

                    // "Why L?" Explanation Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF222226) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why $recommendedSize?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your waist is ${measurements.waist.round()} cm. Size M supports up to 75 cm. Size $recommendedSize includes ${measurements.waist.round()} cm and better matches your ${_preferredFit.substring(0, 1).toUpperCase()}${_preferredFit.substring(1)} fit preference.',
                            style: TextStyle(fontSize: 12.5, color: textSecondary, height: 1.35),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is an estimate based on brand tailoring charts. Fabric, cut, and personal comfort preference can vary.',
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary.withValues(alpha: 0.75),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Fit Preference Toggle / Try another size button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _showSizeSelectorSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black87,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      'Try another size / fit preference',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Edit Avatar & Save Look Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => context.go('/avatar'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.grey.shade400,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                            'Edit avatar',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _onSaveLookPressed(
                            context,
                            ref,
                            garment,
                            measurements,
                            recommendedSize,
                            isPremium,
                            usage,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text(
                            'Save look',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Back to Catalog Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => context.go('/catalog'),
                    style: TextButton.styleFrom(
                      foregroundColor: textSecondary,
                    ),
                    child: const Text(
                      'Back to catalog',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _computeRecommendedSize(Garment garment, AvatarMeasurements m) {
    if (m.waist >= 80 || m.chest >= 98) return 'XL';
    if (m.waist >= 75 || m.chest >= 93) return 'L';
    if (m.waist >= 70 || m.chest >= 88) return 'M';
    return 'S';
  }

  Widget _fitMetricRow({
    required IconData icon,
    required String label,
    String? sublabel,
    required String badge,
    required MaterialColor badgeColor,
    required Color textPrimary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: textPrimary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
        if (sublabel != null) ...[
          const SizedBox(width: 6),
          Text(sublabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            badge,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _waistMetricRow({
    required AvatarMeasurements measurements,
    required String recommendedSize,
    required Color textPrimary,
  }) {
    return Row(
      children: [
        Icon(Icons.crop_free, size: 20, color: textPrimary),
        const SizedBox(width: 10),
        Text('Waist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
        const Spacer(),
        Wrap(
          spacing: 6,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Likely snug in M',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Comfortable in $recommendedSize',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSizeSelectorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Fit Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fitted', label: Text('Fitted')),
                  ButtonSegment(value: 'regular', label: Text('Regular')),
                  ButtonSegment(value: 'relaxed', label: Text('Relaxed')),
                ],
                selected: {_preferredFit},
                onSelectionChanged: (selection) {
                  setState(() {
                    _preferredFit = selection.first;
                  });
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _onSaveLookPressed(
    BuildContext context,
    WidgetRef ref,
    Garment garment,
    AvatarMeasurements measurements,
    String recommendedSize,
    bool isPremium,
    UsageLimits usage,
  ) {
    if (!isPremium && usage.savesUsed >= UsageLimits.freeSavesLimit) {
      context.push('/account/paywall');
      return;
    }

    final activeProfile = ref.read(avatarProfilesProvider).activeProfile;
    final personName = activeProfile?.name ?? 'Me';

    // Show "Save this look?" Modal Bottom Sheet matching Image 3
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
        final textPri = isDark ? Colors.white : Colors.black87;
        final textSec = isDark ? Colors.white70 : Colors.black54;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              const SizedBox(height: 16),
              Text(
                'Save this look?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPri),
              ),
              const SizedBox(height: 10),
              Text(
                'Dress: ${garment.name}',
                style: TextStyle(fontSize: 14.5, color: textPri, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Suggested size: $recommendedSize  ·  Fitting for: $personName',
                style: TextStyle(fontSize: 13.5, color: textSec),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(usageLimitsProvider.notifier).registerSave();
                    ref.read(savedAvatarsProvider.notifier).forceSave(
                          SavedAvatarEntry(
                            name: '${garment.name} - Size $recommendedSize ($personName)',
                            measurements: measurements,
                            garmentId: garment.id,
                          ),
                        );
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'ⓘ Look saved for $personName! Free saves: ${usage.savesUsed + 1} of ${UsageLimits.freeSavesLimit}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black87,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Save look', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text('Cancel', style: TextStyle(color: textSec, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
