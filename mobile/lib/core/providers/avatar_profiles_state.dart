import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'avatar_state.dart';

/// Standard sizing presets for quick body setup
class AvatarSizePresets {
  static const List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  static AvatarMeasurements getMeasurements(bool isFeminine, String size) {
    if (isFeminine) {
      switch (size.toUpperCase()) {
        case 'XS':
          return const AvatarMeasurements(
            height: 158,
            chest: 80,
            waist: 62,
            hip: 86,
            inseam: 71,
            isFeminine: true,
          );
        case 'S':
          return const AvatarMeasurements(
            height: 162,
            chest: 86,
            waist: 68,
            hip: 92,
            inseam: 73,
            isFeminine: true,
          );
        case 'M':
          return const AvatarMeasurements(
            height: 166,
            chest: 92,
            waist: 74,
            hip: 98,
            inseam: 75,
            isFeminine: true,
          );
        case 'L':
          return const AvatarMeasurements(
            height: 170,
            chest: 98,
            waist: 80,
            hip: 104,
            inseam: 77,
            isFeminine: true,
          );
        case 'XL':
          return const AvatarMeasurements(
            height: 172,
            chest: 106,
            waist: 88,
            hip: 112,
            inseam: 77,
            isFeminine: true,
          );
        case 'XXL':
          return const AvatarMeasurements(
            height: 174,
            chest: 114,
            waist: 98,
            hip: 120,
            inseam: 78,
            isFeminine: true,
          );
        default:
          return AvatarMeasurements.defaultsFor(isFeminine: true);
      }
    } else {
      switch (size.toUpperCase()) {
        case 'XS':
        case 'S':
          return const AvatarMeasurements(
            height: 170,
            chest: 92,
            waist: 78,
            hip: 90,
            inseam: 76,
            isFeminine: false,
          );
        case 'M':
          return const AvatarMeasurements(
            height: 176,
            chest: 100,
            waist: 84,
            hip: 96,
            inseam: 79,
            isFeminine: false,
          );
        case 'L':
          return const AvatarMeasurements(
            height: 182,
            chest: 108,
            waist: 92,
            hip: 104,
            inseam: 82,
            isFeminine: false,
          );
        case 'XL':
        case 'XXL':
          return const AvatarMeasurements(
            height: 186,
            chest: 116,
            waist: 102,
            hip: 112,
            inseam: 83,
            isFeminine: false,
          );
        default:
          return AvatarMeasurements.defaultsFor(isFeminine: false);
      }
    }
  }
}

/// A named avatar profile under the user's account (e.g. "Priya (Me)", "Sister", "Mom")
class AvatarProfile {
  final String id;
  final String name;
  final String relation; // "Myself", "Sister", "Friend", "Family", "Other"
  final bool isFeminine;
  final String sizePreset; // 'XS', 'S', 'M', 'L', 'XL'
  final AvatarMeasurements measurements;

  const AvatarProfile({
    required this.id,
    required this.name,
    this.relation = 'Myself',
    required this.isFeminine,
    required this.sizePreset,
    required this.measurements,
  });

  AvatarProfile copyWith({
    String? id,
    String? name,
    String? relation,
    bool? isFeminine,
    String? sizePreset,
    AvatarMeasurements? measurements,
  }) {
    return AvatarProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      isFeminine: isFeminine ?? this.isFeminine,
      sizePreset: sizePreset ?? this.sizePreset,
      measurements: measurements ?? this.measurements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'isFeminine': isFeminine,
      'sizePreset': sizePreset,
      'height': measurements.height,
      'chest': measurements.chest,
      'waist': measurements.waist,
      'hip': measurements.hip,
      'inseam': measurements.inseam,
    };
  }

  factory AvatarProfile.fromJson(Map<String, dynamic> json) {
    final isFem = json['isFeminine'] as bool? ?? true;
    return AvatarProfile(
      id: json['id'] as String? ?? UniqueKey().toString(),
      name: json['name'] as String? ?? 'Me',
      relation: json['relation'] as String? ?? 'Myself',
      isFeminine: isFem,
      sizePreset: json['sizePreset'] as String? ?? 'M',
      measurements: AvatarMeasurements(
        height: (json['height'] as num?)?.toDouble() ?? (isFem ? 162 : 175),
        chest: (json['chest'] as num?)?.toDouble() ?? (isFem ? 90 : 100),
        waist: (json['waist'] as num?)?.toDouble() ?? (isFem ? 75 : 85),
        hip: (json['hip'] as num?)?.toDouble() ?? (isFem ? 95 : 95),
        inseam: (json['inseam'] as num?)?.toDouble() ?? (isFem ? 74 : 79),
        isFeminine: isFem,
      ),
    );
  }
}

/// State holder for multiple avatar profiles
class AvatarProfilesState {
  final List<AvatarProfile> profiles;
  final String activeProfileId;

  const AvatarProfilesState({
    required this.profiles,
    required this.activeProfileId,
  });

  AvatarProfile? get activeProfile {
    try {
      return profiles.firstWhere((p) => p.id == activeProfileId);
    } catch (_) {
      return profiles.isNotEmpty ? profiles.first : null;
    }
  }

  AvatarProfilesState copyWith({
    List<AvatarProfile>? profiles,
    String? activeProfileId,
  }) {
    return AvatarProfilesState(
      profiles: profiles ?? this.profiles,
      activeProfileId: activeProfileId ?? this.activeProfileId,
    );
  }
}

class AvatarProfilesNotifier extends Notifier<AvatarProfilesState> {
  static const _keyProfiles = 'twinly_saved_profiles_json';
  static const _keyActiveId = 'twinly_active_profile_id';

  @override
  AvatarProfilesState build() {
    _loadFromDisk();
    // Default initial profile
    const defaultProfile = AvatarProfile(
      id: 'default_me',
      name: 'Me',
      relation: 'Myself',
      isFeminine: true,
      sizePreset: 'M',
      measurements: AvatarMeasurements(
        height: 165,
        chest: 90,
        waist: 72,
        hip: 96,
        inseam: 74,
        isFeminine: true,
      ),
    );
    return const AvatarProfilesState(
      profiles: [defaultProfile],
      activeProfileId: 'default_me',
    );
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyProfiles);
      final activeId = prefs.getString(_keyActiveId);

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        final loadedProfiles = list
            .map((item) => AvatarProfile.fromJson(item as Map<String, dynamic>))
            .toList();

        if (loadedProfiles.isNotEmpty) {
          final targetActiveId = activeId != null &&
                  loadedProfiles.any((p) => p.id == activeId)
              ? activeId
              : loadedProfiles.first.id;

          state = AvatarProfilesState(
            profiles: loadedProfiles,
            activeProfileId: targetActiveId,
          );

          // Update active avatar measurements
          final active = state.activeProfile;
          if (active != null) {
            ref.read(avatarMeasurementsProvider.notifier).setHeight(active.measurements.height);
            ref.read(avatarMeasurementsProvider.notifier).setChest(active.measurements.chest);
            ref.read(avatarMeasurementsProvider.notifier).setWaist(active.measurements.waist);
            ref.read(avatarMeasurementsProvider.notifier).setHip(active.measurements.hip);
            ref.read(avatarMeasurementsProvider.notifier).setInseam(active.measurements.inseam);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading avatar profiles: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(state.profiles.map((p) => p.toJson()).toList());
      await prefs.setString(_keyProfiles, jsonStr);
      await prefs.setString(_keyActiveId, state.activeProfileId);
    } catch (e) {
      debugPrint('Error saving avatar profiles: $e');
    }
  }

  /// Create and set the primary profile upon account signup / onboarding
  Future<void> setInitialProfile({
    required String name,
    required bool isFeminine,
    required String sizePreset,
  }) async {
    final measurements = AvatarSizePresets.getMeasurements(isFeminine, sizePreset);
    final primaryProfile = AvatarProfile(
      id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      name: name.isEmpty ? 'Me' : name,
      relation: 'Myself',
      isFeminine: isFeminine,
      sizePreset: sizePreset,
      measurements: measurements,
    );

    state = AvatarProfilesState(
      profiles: [primaryProfile],
      activeProfileId: primaryProfile.id,
    );

    // Apply to avatar state
    ref.read(avatarMeasurementsProvider.notifier).setGender(isFeminine);
    ref.read(avatarMeasurementsProvider.notifier).setHeight(measurements.height);
    ref.read(avatarMeasurementsProvider.notifier).setChest(measurements.chest);
    ref.read(avatarMeasurementsProvider.notifier).setWaist(measurements.waist);
    ref.read(avatarMeasurementsProvider.notifier).setHip(measurements.hip);
    ref.read(avatarMeasurementsProvider.notifier).setInseam(measurements.inseam);

    await _persist();
  }

  /// Add a new person's avatar profile to the account
  Future<void> addProfile({
    required String name,
    required String relation,
    required bool isFeminine,
    required String sizePreset,
    AvatarMeasurements? customMeasurements,
  }) async {
    final measurements = customMeasurements ??
        AvatarSizePresets.getMeasurements(isFeminine, sizePreset);

    final newProfile = AvatarProfile(
      id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Friend' : name.trim(),
      relation: relation,
      isFeminine: isFeminine,
      sizePreset: sizePreset,
      measurements: measurements,
    );

    state = state.copyWith(
      profiles: [...state.profiles, newProfile],
      activeProfileId: newProfile.id,
    );

    // Switch avatar state
    ref.read(avatarMeasurementsProvider.notifier).setGender(isFeminine);
    ref.read(avatarMeasurementsProvider.notifier).setHeight(measurements.height);
    ref.read(avatarMeasurementsProvider.notifier).setChest(measurements.chest);
    ref.read(avatarMeasurementsProvider.notifier).setWaist(measurements.waist);
    ref.read(avatarMeasurementsProvider.notifier).setHip(measurements.hip);
    ref.read(avatarMeasurementsProvider.notifier).setInseam(measurements.inseam);

    await _persist();
  }

  /// Switch the active avatar to another saved person
  Future<void> switchProfile(String profileId) async {
    if (state.activeProfileId == profileId) return;

    final target = state.profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => state.profiles.first,
    );

    state = state.copyWith(activeProfileId: target.id);

    // Update avatar measurements to match this person
    ref.read(avatarMeasurementsProvider.notifier).setGender(target.isFeminine);
    ref.read(avatarMeasurementsProvider.notifier).setHeight(target.measurements.height);
    ref.read(avatarMeasurementsProvider.notifier).setChest(target.measurements.chest);
    ref.read(avatarMeasurementsProvider.notifier).setWaist(target.measurements.waist);
    ref.read(avatarMeasurementsProvider.notifier).setHip(target.measurements.hip);
    ref.read(avatarMeasurementsProvider.notifier).setInseam(target.measurements.inseam);

    await _persist();
  }

  /// Update the current active profile's measurements from sliders
  Future<void> updateActiveMeasurements(AvatarMeasurements measurements) async {
    final active = state.activeProfile;
    if (active == null) return;

    final updated = active.copyWith(measurements: measurements);
    final updatedList = state.profiles
        .map((p) => p.id == active.id ? updated : p)
        .toList();

    state = state.copyWith(profiles: updatedList);
    await _persist();
  }

  /// Delete a secondary profile
  Future<void> deleteProfile(String profileId) async {
    if (state.profiles.length <= 1) return; // Keep at least one profile

    final remaining = state.profiles.where((p) => p.id != profileId).toList();
    final newActiveId = state.activeProfileId == profileId
        ? remaining.first.id
        : state.activeProfileId;

    state = AvatarProfilesState(
      profiles: remaining,
      activeProfileId: newActiveId,
    );

    if (state.activeProfile != null) {
      final active = state.activeProfile!;
      ref.read(avatarMeasurementsProvider.notifier).setGender(active.isFeminine);
      ref.read(avatarMeasurementsProvider.notifier).setHeight(active.measurements.height);
      ref.read(avatarMeasurementsProvider.notifier).setChest(active.measurements.chest);
      ref.read(avatarMeasurementsProvider.notifier).setWaist(active.measurements.waist);
      ref.read(avatarMeasurementsProvider.notifier).setHip(active.measurements.hip);
      ref.read(avatarMeasurementsProvider.notifier).setInseam(active.measurements.inseam);
    }

    await _persist();
  }
}

final avatarProfilesProvider =
    NotifierProvider<AvatarProfilesNotifier, AvatarProfilesState>(
  AvatarProfilesNotifier.new,
);
