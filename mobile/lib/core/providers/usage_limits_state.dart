import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageLimits {
  final int triesUsed;
  final int savesUsed;
  final String? lastCountedGarmentId;

  const UsageLimits({
    required this.triesUsed,
    required this.savesUsed,
    required this.lastCountedGarmentId,
  });

  static const freeTriesLimit = 3;
  static const freeSavesLimit = 1;
}

class UsageLimitsNotifier extends Notifier<UsageLimits> {
  static const _keyTries = 'usage_tries';
  static const _keySaves = 'usage_saves';
  static const _keyLastGarment = 'usage_last_garment';

  @override
  UsageLimits build() {
    // Synchronous default; refreshed from disk right after via _loadFromDisk().
    Future.microtask(_loadFromDisk);
    return const UsageLimits(
      triesUsed: 0,
      savesUsed: 0,
      lastCountedGarmentId: null,
    );
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    state = UsageLimits(
      triesUsed: prefs.getInt(_keyTries) ?? 0,
      savesUsed: prefs.getInt(_keySaves) ?? 0,
      lastCountedGarmentId: prefs.getString(_keyLastGarment),
    );
  }

  // Call when a NEW distinct garment reaches Fitting. No-ops if this
  // garment was the last one already counted (avoids double-counting
  // on tab revisits) or if premium (unlimited, nothing to track).
  Future<void> registerTryIfNew(
    String garmentId, {
    required bool isPremium,
  }) async {
    if (garmentId == state.lastCountedGarmentId) return;
    if (isPremium) {
      state = UsageLimits(
        triesUsed: state.triesUsed,
        savesUsed: state.savesUsed,
        lastCountedGarmentId: garmentId,
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final newTries = state.triesUsed + 1;
    await prefs.setInt(_keyTries, newTries);
    await prefs.setString(_keyLastGarment, garmentId);
    state = UsageLimits(
      triesUsed: newTries,
      savesUsed: state.savesUsed,
      lastCountedGarmentId: garmentId,
    );
  }

  Future<void> registerSave() async {
    final prefs = await SharedPreferences.getInstance();
    final newSaves = state.savesUsed + 1;
    await prefs.setInt(_keySaves, newSaves);
    state = UsageLimits(
      triesUsed: state.triesUsed,
      savesUsed: newSaves,
      lastCountedGarmentId: state.lastCountedGarmentId,
    );
  }
}

final usageLimitsProvider = NotifierProvider<UsageLimitsNotifier, UsageLimits>(
  UsageLimitsNotifier.new,
);

// Stub for now — wire to RevenueCat's customer info / entitlement check
// once the dashboard is set up. Everything else reads this, so swapping
// the implementation later doesn't touch any calling code.

// TEMP: forcing premium on for development so the team can test try-ons
// and saves without hitting limits. MUST be reverted before any real
// testing of the free-tier flow, and definitely before submission.
// See "Usage limits — decide with team" note.
final isPremiumProvider = Provider<bool>((ref) => true);
