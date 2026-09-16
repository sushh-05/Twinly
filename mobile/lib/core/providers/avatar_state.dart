import 'package:flutter/foundation.dart';

class AvatarMeasurements {
  final double height;
  final double shoulderWidth;
  final double chest;
  final double waist;
  final double hip;
  final double inseam;
  final bool isFeminine;
  final String skinTone;
  final String hairStyle;
  final String hairColor;

  const AvatarMeasurements({
    required this.height,
    this.shoulderWidth = 40,
    required this.chest,
    required this.waist,
    required this.hip,
    required this.inseam,
    required this.isFeminine,
    this.skinTone = 'medium',
    this.hairStyle = 'short',
    this.hairColor = 'black',
  });

  AvatarMeasurements copyWith({
    double? height,
    double? shoulderWidth,
    double? chest,
    double? waist,
    double? hip,
    double? inseam,
    bool? isFeminine,
    String? skinTone,
    String? hairStyle,
    String? hairColor,
  }) {
    return AvatarMeasurements(
      height: height ?? this.height,
      shoulderWidth: shoulderWidth ?? this.shoulderWidth,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hip: hip ?? this.hip,
      inseam: inseam ?? this.inseam,
      isFeminine: isFeminine ?? this.isFeminine,
      skinTone: skinTone ?? this.skinTone,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
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

class AvatarMeasurementsState extends ChangeNotifier {
  AvatarMeasurements value = AvatarMeasurements.defaultsFor(isFeminine: true);

  AvatarMeasurements get state => value;

  AvatarMeasurementsState();
  void _set(AvatarMeasurements next) {
    value = next;
    notifyListeners();
  }

  AvatarMeasurements build() {
    // Starting default — Sign up screen will overwrite this with the
    // chosen gender's defaults right after the user picks it.
    return value;
  }

  void setHeight(double v) => _set(value.copyWith(height: v, inseam: v * 0.45));
  void setChest(double v) => _set(value.copyWith(chest: v));
  void setWaist(double v) => _set(value.copyWith(waist: v));
  void setHip(double v) => _set(value.copyWith(hip: v));
  void setInseam(double v) => _set(value.copyWith(inseam: v));
  void setMeasurements(AvatarMeasurements next) => _set(next);

  // Called from the gender toggle on the Avatar screen — resets to that
  // gender's sensible defaults, since switching gender means switching
  // to a different person, not just relabeling the same numbers.
  void setGender(bool isFeminine) {
    _set(AvatarMeasurements.defaultsFor(isFeminine: isFeminine));
  }
}
