import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/core/providers/avatar_profiles_state.dart';
import 'package:twinly/core/providers/avatar_state.dart';

void main() {
  test('avatar defaults include safe appearance values', () {
    final avatar = AvatarMeasurements.defaultsFor(isFeminine: true);

    expect(avatar.isFeminine, isTrue);
    expect(avatar.skinTone, 'medium');
    expect(avatar.hairStyle, 'short');
    expect(avatar.hairColor, 'black');
  });

  test('old saved profile gets backward-compatible appearance defaults', () {
    final profile = AvatarProfile.fromJson({
      'id': 'old-profile',
      'name': 'Me',
      'isFeminine': false,
      'sizePreset': 'M',
      'height': 175,
      'chest': 100,
      'waist': 85,
      'hip': 95,
      'inseam': 79,
    });

    expect(profile.measurements.skinTone, 'medium');
    expect(profile.measurements.hairStyle, 'short');
    expect(profile.measurements.hairColor, 'black');
    expect(profile.measurements.height, 175);
    expect(profile.measurements.chest, 100);
  });

  test('appearance changes preserve measurements', () {
    const original = AvatarMeasurements(
      height: 168,
      chest: 94,
      waist: 76,
      hip: 101,
      inseam: 76,
      isFeminine: true,
    );
    final styled = original.copyWith(
      skinTone: 'deep',
      hairStyle: 'curly',
      hairColor: 'auburn',
    );

    expect(styled.height, original.height);
    expect(styled.chest, original.chest);
    expect(styled.waist, original.waist);
    expect(styled.hip, original.hip);
    expect(styled.inseam, original.inseam);
  });

  test('frame selection changes only the frame value when requested', () {
    const original = AvatarMeasurements(
      height: 168,
      chest: 94,
      waist: 76,
      hip: 101,
      inseam: 76,
      isFeminine: true,
    );
    final masculine = original.copyWith(isFeminine: false);

    expect(masculine.isFeminine, isFalse);
    expect(masculine.height, original.height);
    expect(masculine.chest, original.chest);
    expect(masculine.waist, original.waist);
    expect(masculine.hip, original.hip);
    expect(masculine.inseam, original.inseam);
  });
}
