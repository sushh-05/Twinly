import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/avatar_state.dart';

class SavedAvatarEntry {
  final String name;
  final AvatarMeasurements measurements;
  final String garmentId;

  const SavedAvatarEntry({
    required this.name,
    required this.measurements,
    required this.garmentId,
  });

  bool matches(SavedAvatarEntry other) {
    final m = measurements, o = other.measurements;
    return name == other.name &&
        garmentId == other.garmentId &&
        m.height == o.height &&
        m.chest == o.chest &&
        m.waist == o.waist &&
        m.hip == o.hip &&
        m.inseam == o.inseam &&
        m.isFeminine == o.isFeminine;
  }
}

class SavedAvatarsNotifier extends Notifier<List<SavedAvatarEntry>> {
  @override
  List<SavedAvatarEntry> build() => [];

  // Returns true if a matching entry already existed (caller shows the
  // "save as new copy or skip?" prompt); always call forceSave() after
  // the user's choice — this method itself never blocks on the check.
  bool hasDuplicate(SavedAvatarEntry candidate) {
    return state.any((e) => e.matches(candidate));
  }

  void forceSave(SavedAvatarEntry entry) {
    state = [...state, entry];
  }
}

final savedAvatarsProvider =
    NotifierProvider<SavedAvatarsNotifier, List<SavedAvatarEntry>>(
      SavedAvatarsNotifier.new,
    );
