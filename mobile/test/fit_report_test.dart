import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/models/fit_report.dart';

void main() {
  test('FitReport parses an explainable backend response', () {
    final report = FitReport.fromJson({
      'status': 'ok',
      'garmentId': 'dress_001',
      'recommendedSize': 'M',
      'confidence': 'high',
      'regions': {
        'bust': {'label': 'good', 'easeCm': 3.0},
      },
      'explanation': 'Chart-based guidance.',
      'disclaimer': 'Not guaranteed.',
    });
    expect(report.recommendedSize, 'M');
    expect(report.regions['bust']!.easeCm, 3.0);
  });
}
