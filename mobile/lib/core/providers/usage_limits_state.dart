import 'package:flutter/foundation.dart';
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

class UsageLimitsState extends ChangeNotifier {
  static const _keyTries = 'usage_tries';
  static const _keySaves = 'usage_saves';
  static const _keyLastGarment = 'usage_last_garment';

  UsageLimits value = const UsageLimits(
    triesUsed: 0,
    savesUsed: 0,
    lastCountedGarmentId: null,
  );
  UsageLimits get state => value;

  UsageLimitsState() {
    // Synchronous default; refreshed from disk right after via _loadFromDisk().
    Future.microtask(_loadFromDisk);
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    value = UsageLimits(
      triesUsed: prefs.getInt(_keyTries) ?? 0,
      savesUsed: prefs.getInt(_keySaves) ?? 0,
      lastCountedGarmentId: prefs.getString(_keyLastGarment),
    );
    notifyListeners();
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
      value = UsageLimits(
        triesUsed: state.triesUsed,
        savesUsed: state.savesUsed,
        lastCountedGarmentId: garmentId,
      );
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final newTries = state.triesUsed + 1;
    await prefs.setInt(_keyTries, newTries);
    await prefs.setString(_keyLastGarment, garmentId);
    value = UsageLimits(
      triesUsed: newTries,
      savesUsed: state.savesUsed,
      lastCountedGarmentId: garmentId,
    );
  }

  Future<void> registerSave() async {
    final prefs = await SharedPreferences.getInstance();
    final newSaves = state.savesUsed + 1;
    await prefs.setInt(_keySaves, newSaves);
    value = UsageLimits(
      triesUsed: state.triesUsed,
      savesUsed: newSaves,
      lastCountedGarmentId: state.lastCountedGarmentId,
    );
    notifyListeners();
  }
}
// Stub for now — wire to RevenueCat's customer info / entitlement check
// once the dashboard is set up. Everything else reads this, so swapping
// the implementation later doesn't touch any calling code.

// TEMP: forcing premium on for development so the team can test try-ons
// and saves without hitting limits. MUST be reverted before any real
// testing of the free-tier flow, and definitely before submission.
