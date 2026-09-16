import 'package:flutter/material.dart';

class Garment {
  final String id;
  final String name;
  final Color placeholderColor;
  // Size chart for a "standard" size of this garment — the fit engine
  // compares the user's measurements against these.
  final double chartChest;
  final double chartWaist;
  final double chartHip;
  final String size;
  final String? category;
  final double? price;
  final String? currency;
  final String? currencySymbol;
  final List<String> availableSizes;
  final String? stretch;
  final String? brand;
  final String? silhouette;
  final String? assetImagePath;
  final String? fallbackImageUrl;
  final bool verifiedSizeChart;
  final String? fabricMaterial;
  final String? description;
  final Map<String, dynamic>? rawSizeChart;

  const Garment({
    required this.id,
    required this.name,
    required this.placeholderColor,
    required this.chartChest,
    required this.chartWaist,
    required this.chartHip,
    this.size = 'M',
    this.category,
    this.price,
    this.currency,
    this.currencySymbol,
    this.availableSizes = const [],
    this.stretch,
    this.brand,
    this.silhouette,
    this.assetImagePath,
    this.fallbackImageUrl,
    this.verifiedSizeChart = false,
    this.fabricMaterial,
    this.description,
    this.rawSizeChart,
  });

  String get displayPrice {
    if (price == null) return '';
    final sym = currencySymbol ?? (currency == 'INR' ? '₹' : '\$');
    return '$sym${price!.toStringAsFixed(0)}';
  }

  String get sizeRangeLabel {
    if (availableSizes.isEmpty) return 'Free size';
    return '${availableSizes.first}-${availableSizes.last}';
  }

  factory Garment.fromApi(Map<String, dynamic> json) {
    final charts = json['sizeChart'] is Map
        ? Map<String, dynamic>.from(json['sizeChart'] as Map)
        : <String, dynamic>{};
    final sizes = (json['sizes'] as List<dynamic>? ?? const [])
        .map((size) => size.toString())
        .where(charts.containsKey)
        .toList();
    final size = sizes.contains('M')
        ? 'M'
        : (sizes.isEmpty ? 'M' : sizes.first);
    final chart = charts[size] is Map
        ? Map<String, dynamic>.from(charts[size] as Map)
        : const <String, dynamic>{};
    double measurement(String primary, [String? alternative]) =>
        ((chart[primary] ?? (alternative == null ? null : chart[alternative]))
                as num?)
            ?.toDouble() ??
        0;

    return Garment(
      id: json['id'] as String,
      name: json['name'] as String,
      placeholderColor: _colorFor(json['category'] as String?),
      chartChest: measurement('chestCm', 'bustCm'),
      chartWaist: measurement('waistCm'),
      chartHip: measurement('hipCm'),
      size: size,
      category: json['category'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
      availableSizes: sizes.isNotEmpty ? sizes : const ['S', 'M', 'L', 'XL'],
      stretch: (json['stretch'] ?? json['fabricStretch']) as String?,
      brand: json['brand'] as String?,
      silhouette: json['silhouette'] as String?,
      assetImagePath: json['assetImagePath'] as String?,
      fallbackImageUrl:
          (json['fallbackImageUrl'] ?? json['imageUrl']) as String?,
      verifiedSizeChart:
          json['sizeChartVerified'] == true ||
          json['verifiedSizeChart'] == true,
      fabricMaterial: json['fabricMaterial'] as String?,
      description: json['description'] as String?,
      rawSizeChart: charts,
    );
  }

  static Color _colorFor(String? category) => switch (category) {
    'dress' => Colors.black87,
    'shirt' => Colors.blueGrey,
    'suit' => Colors.indigo,
    _ => Colors.deepPurple,
  };
}
