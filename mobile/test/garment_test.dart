import 'package:flutter_test/flutter_test.dart';
import 'package:twinly/models/garment.dart';

void main() {
  test('parses rich structured garments', () {
    final garment = Garment.fromApi({
      'id': 'dress_blue_01',
      'name': 'Blue Floral Dress',
      'category': 'dress',
      'price': 2499,
      'currency': 'INR',
      'currencySymbol': '₹',
      'availableSizes': ['S', 'M', 'L', 'XL'],
      'verifiedSizeChart': true,
      'sizeChart': [
        {
          'size': 'S',
          'bustRange': '82 - 86',
          'waistRange': '64 - 68',
          'hipRange': '90 - 94',
          'lengthCm': 113,
        },
      ],
    });
    expect(garment.availableSizes, ['S', 'M', 'L', 'XL']);
    expect(garment.sizeChart.single.lengthCm, 113);
    expect(garment.verifiedSizeChart, isTrue);
  });

  test('keeps legacy charts and tolerates missing image fields', () {
    final garment = Garment.fromApi({
      'id': 'legacy',
      'name': 'Legacy',
      'category': 'dress',
      'sizes': ['S'],
      'sizeChart': {
        'S': {'bustCm': 86, 'waistCm': 70, 'hipCm': 94},
      },
    });
    expect(garment.sizeChart.single.bustRange, '86');
    expect(garment.assetImagePath, isNull);
    expect(garment.fallbackImageUrl, isNull);
    expect(garment.verifiedSizeChart, isFalse);
  });
}
