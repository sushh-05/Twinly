import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logic/fit_engine.dart';
import '../../core/providers/avatar_state.dart';
import '../../core/providers/garment_state.dart';
import '../../core/providers/saved_avatars_state.dart';
import '../../core/providers/usage_limits_state.dart';
import '../../models/fit_report.dart';
import '../avatar/body_painter.dart';

class FittingScreen extends ConsumerStatefulWidget {
  const FittingScreen({super.key});

  @override
  ConsumerState<FittingScreen> createState() => _FittingScreenState();
}

class _FittingScreenState extends ConsumerState<FittingScreen> {
  // Guards against re-registering a try on every rebuild — only the
  // first build for a given garment id should ever count it.
  String? _registeredForGarmentId;
  String _preferredFit = 'regular';
  String? _reportKey;
  Future<FitReport>? _reportFuture;

  @override
  Widget build(BuildContext context) {
    final garment = ref.watch(selectedGarmentProvider);
    final measurements = ref.watch(avatarMeasurementsProvider);
    final usage = ref.watch(usageLimitsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    // Reached via bottom nav with nothing selected yet.
    if (garment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fitting')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No look yet — pick a dress to try on.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                child: const Text('Go to Catalog'),
              ),
            ],
          ),
        ),
      );
    }

    final atFreeLimit =
        !isPremium && usage.triesUsed >= UsageLimits.freeTriesLimit;
    final isNewGarment = garment.id != usage.lastCountedGarmentId;

    // Blocked: free tier, already at the cap, and this is a garment
    // they haven't already "spent" a try viewing.
    if (atFreeLimit && isNewGarment) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fitting')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You've used your ${UsageLimits.freeTriesLimit} free try-ons",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text('Upgrade for unlimited try-ons and saving.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/account/paywall'),
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Register the try exactly once per garment selection — guarded by
    // local widget state, not just the provider's own dedupe check, so
    // repeated rebuilds of the same garment can never double-fire this.
    if (_registeredForGarmentId != garment.id) {
      _registeredForGarmentId = garment.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(usageLimitsProvider.notifier)
            .registerTryIfNew(garment.id, isPremium: isPremium);
      });
    }

    final reportKey =
        '${garment.id}:${measurements.chest}:${measurements.waist}:${measurements.hip}:$_preferredFit';
    if (_reportKey != reportKey) {
      _reportKey = reportKey;
      _reportFuture = ref
          .read(twinlyApiServiceProvider)
          .getFitReport(
            garmentId: garment.id,
            bustCm: measurements.chest,
            waistCm: measurements.waist,
            hipCm: measurements.hip,
            preferredFit: _preferredFit,
          );
    }

    return Scaffold(
      appBar: AppBar(title: Text(garment.name)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(280, 500),
                      painter: BodyPainter(
                        height: measurements.height,
                        chest: measurements.chest,
                        waist: measurements.waist,
                        hip: measurements.hip,
                        inseam: measurements.inseam,
                        isSideView: false,
                      ),
                    ),
                    // Simple placeholder garment overlay — a translucent
                    // colored panel over the torso, standing in for the
                    // real garment mesh until real assets/rendering exist.
                    Positioned(
                      top: 90,
                      child: Container(
                        width: 90,
                        height: 160,
                        decoration: BoxDecoration(
                          color: garment.placeholderColor.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'fitted', label: Text('Fitted')),
                      ButtonSegment(value: 'regular', label: Text('Regular')),
                      ButtonSegment(value: 'relaxed', label: Text('Relaxed')),
                    ],
                    selected: {_preferredFit},
                    onSelectionChanged: (selection) => setState(() {
                      _preferredFit = selection.first;
                      _reportKey = null;
                    }),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<FitReport>(
                    future: _reportFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        final offline = computeFit(measurements, garment);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Offline estimate',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _reportKey = null),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                            ...offline.map(_FitRow.new),
                          ],
                        );
                      }
                      final report = snapshot.requireData;
                      if (report.status == 'insufficient_data') {
                        return Text(report.explanation);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended size: ${report.recommendedSize ?? 'Unavailable'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (report.confidence != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Chip(
                                label: Text(
                                  'Confidence: ${report.confidence!}',
                                ),
                              ),
                            ),
                          ...['bust', 'waist', 'hip'].map(
                            (region) =>
                                _BackendFitRow(region, report.regions[region]),
                          ),
                          const SizedBox(height: 4),
                          Text(report.explanation),
                          const SizedBox(height: 4),
                          Text(
                            report.disclaimer,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/catalog'),
                      child: const Text('Try another'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onSavePressed(
                        context,
                        ref,
                        garment,
                        measurements,
                        isPremium,
                        usage,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSavePressed(
    BuildContext context,
    WidgetRef ref,
    garment,
    AvatarMeasurements measurements,
    bool isPremium,
    UsageLimits usage,
  ) async {
    if (!isPremium && usage.savesUsed >= UsageLimits.freeSavesLimit) {
      if (!context.mounted) return;
      context.push('/account/paywall');
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: 'Me');
        return AlertDialog(
          title: const Text('Save this look'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Save as'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (name == null || name.isEmpty) return;
    if (!context.mounted) return;

    final candidate = SavedAvatarEntry(
      name: name,
      measurements: measurements,
      garmentId: garment.id,
    );
    final savedNotifier = ref.read(savedAvatarsProvider.notifier);

    if (savedNotifier.hasDuplicate(candidate)) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already saved'),
          content: const Text('Save as a new copy, or skip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save as new'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    savedNotifier.forceSave(candidate);
    await ref.read(usageLimitsProvider.notifier).registerSave();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }
}

class _FitRow extends StatelessWidget {
  const _FitRow(this.fit);
  final RegionFit fit;

  Color get _color {
    switch (fit.verdict) {
      case FitVerdict.tight:
        return Colors.red;
      case FitVerdict.good:
        return Colors.green;
      case FitVerdict.loose:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(fit.note),
        ],
      ),
    );
  }
}

class _BackendFitRow extends StatelessWidget {
  const _BackendFitRow(this.region, this.fit);
  final String region;
  final FitRegion? fit;

  @override
  Widget build(BuildContext context) {
    final name = switch (region) {
      'bust' => 'Bust/Chest',
      'hip' => 'Hips',
      _ => 'Waist',
    };
    final label = fit?.label.replaceAll('_', ' ') ?? 'unknown';
    final ease = fit?.easeCm == null
        ? ''
        : ' (${fit!.easeCm!.toStringAsFixed(1)} cm ease)';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text('$name: $label$ease'),
    );
  }
}
