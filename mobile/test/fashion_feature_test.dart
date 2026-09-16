import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/models/fit_guide.dart';

void main() {
  test('fit guide uses low confidence with no measurements', () {
    expect(FitGuide.calculate().confidence, 'Low');
    expect(FitGuide.calculate().recommendedSize, 'M / estimate');
  });
  test('fit guide uses medium confidence with two measurements', () {
    expect(FitGuide.calculate(bust: 90, waist: 70).confidence, 'Medium');
  });
  test('fit guide uses high confidence with three measurements', () {
    expect(FitGuide.calculate(bust: 90, waist: 70, hip: 95).confidence, 'High');
  });
}
