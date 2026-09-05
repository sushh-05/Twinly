import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvatarMeasurements {
  final double height;
  final double chest;
  final double waist;
  final double hip;
  final double inseam;
  final bool isFeminine;

  const AvatarMeasurements({
    required this.height,
    required this.chest,
    required this.waist,
    required this.hip,
    required this.inseam,
    required this.isFeminine,
  });

  AvatarMeasurements copyWith({
    double? height,
    double? chest,
    double? waist,
    double? hip,
    double? inseam,
    bool? isFeminine,
  }) {
    return AvatarMeasurements(
      height: height ?? this.height,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hip: hip ?? this.hip,
      inseam: inseam ?? this.inseam,
      isFeminine: isFeminine ?? this.isFeminine,
    );
  }

  // Default measurements, keyed by gender — replaces the old profile-picker screen's data
  factory AvatarMeasurements.defaultsFor({required bool isFeminine}) {
    return isFeminine
        ? const AvatarMeasurements(
            height: 162,
            chest: 90,
            waist: 75,
            hip: 95,
            inseam: 74,
            isFeminine: true,
          )
        : const AvatarMeasurements(
            height: 175,
            chest: 100,
            waist: 85,
            hip: 95,
            inseam: 79,
            isFeminine: false,
          );
  }
}

class AvatarMeasurementsNotifier extends Notifier<AvatarMeasurements> {
  @override
  AvatarMeasurements build() {
    // Starting default — Sign up screen will overwrite this with the
    // chosen gender's defaults right after the user picks it.
    return AvatarMeasurements.defaultsFor(isFeminine: true);
  }

  void setHeight(double v) =>
      state = state.copyWith(height: v, inseam: v * 0.45);
  void setChest(double v) => state = state.copyWith(chest: v);
  void setWaist(double v) => state = state.copyWith(waist: v);
  void setHip(double v) => state = state.copyWith(hip: v);
  void setInseam(double v) => state = state.copyWith(inseam: v);

  // Called from the gender toggle on the Avatar screen — resets to that
  // gender's sensible defaults, since switching gender means switching
  // to a different person, not just relabeling the same numbers.
  void setGender(bool isFeminine) {
    state = AvatarMeasurements.defaultsFor(isFeminine: isFeminine);
  }
}

final avatarMeasurementsProvider =
    NotifierProvider<AvatarMeasurementsNotifier, AvatarMeasurements>(
      AvatarMeasurementsNotifier.new,
    );
