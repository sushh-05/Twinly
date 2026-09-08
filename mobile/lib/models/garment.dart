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
  final List<String> availableSizes;
  final String? stretch;
  final String? brand,
      currencySymbol,
      silhouette,
      fabricStretch,
      fabricMaterial,
      assetImagePath,
      fallbackImageUrl,
      description;
  final bool verifiedSizeChart;
  final List<SizeChartRow> sizeChart;

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
    this.availableSizes = const [],
    this.stretch,
    this.brand,
    this.currencySymbol,
    this.silhouette,
    this.fabricStretch,
    this.fabricMaterial,
    this.assetImagePath,
    this.fallbackImageUrl,
    this.description,
    this.verifiedSizeChart = false,
    this.sizeChart = const [],
  });

  factory Garment.fromApi(Map<String, dynamic> json) {
    final rawChart = json['sizeChart'];
    final charts = rawChart is Map
        ? Map<String, dynamic>.from(rawChart)
        : <String, dynamic>{};
    final structuredRows = rawChart is List
        ? rawChart
              .map(
                (row) => SizeChartRow.fromJson(
                  Map<String, dynamic>.from(row as Map),
                ),
              )
              .toList()
        : const <SizeChartRow>[];
    final legacyRows = charts.entries.map((entry) {
      final values = Map<String, dynamic>.from(entry.value as Map);
      String? value(String key) => values[key]?.toString();
      return SizeChartRow(
        size: entry.key,
        bustRange: value('bustCm') ?? value('chestCm'),
        waistRange: value('waistCm'),
        hipRange: value('hipCm'),
      );
    }).toList();
    final sizes =
        (json['availableSizes'] as List<dynamic>? ??
                json['sizes'] as List<dynamic>? ??
                const [])
            .map((size) => size.toString())
            .where(
              (value) =>
                  charts.isEmpty ||
                  charts.containsKey(value) ||
                  structuredRows.any((row) => row.size == value),
            )
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
      availableSizes: sizes.isEmpty
          ? structuredRows.map((row) => row.size).toList()
          : sizes,
      stretch: json['stretch'] as String?,
      brand: json['brand'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
      silhouette: json['silhouette'] as String?,
      fabricStretch: json['fabricStretch'] as String?,
      fabricMaterial: json['fabricMaterial'] as String?,
      assetImagePath:
          json['assetImagePath'] as String? ?? _assetFor(json['id'] as String),
      fallbackImageUrl: json['fallbackImageUrl'] as String?,
      description: json['description'] as String?,
      verifiedSizeChart:
          json['verifiedSizeChart'] as bool? ??
          json['sizeChartVerified'] as bool? ??
          false,
      sizeChart: structuredRows.isEmpty ? legacyRows : structuredRows,
    );
  }

  static Color _colorFor(String? category) => switch (category) {
    'dress' => Colors.black87,
    'shirt' => Colors.blueGrey,
    'suit' => Colors.indigo,
    _ => Colors.deepPurple,
  };

  static String? _assetFor(String id) => const {
    'dress_001': 'assets/dresses/black-dress-1.jpg',
    'dress_black_02': 'assets/dresses/black-dress-2.jpg',
    'dress_blue_01': 'assets/dresses/blue-dress.jpg',
    'dress_purple_01': 'assets/dresses/purple-dress.jpg',
    'dress_red_01': 'assets/dresses/red-dress-1.jpg',
    'dress_red_02': 'assets/dresses/red-dress-2.jpg',
    'dress_white_01': 'assets/dresses/white-dress-1.jpg',
    'dress_white_02': 'assets/dresses/white-dress-2.jpg',
  }[id];
}

class SizeChartRow {
  const SizeChartRow({
    required this.size,
    this.bustRange,
    this.waistRange,
    this.hipRange,
    this.lengthCm,
  });
  final String size;
  final String? bustRange, waistRange, hipRange;
  final double? lengthCm;
  factory SizeChartRow.fromJson(Map<String, dynamic> json) => SizeChartRow(
    size: json['size'].toString(),
    bustRange: json['bustRange'] as String?,
    waistRange: json['waistRange'] as String?,
    hipRange: json['hipRange'] as String?,
    lengthCm: (json['lengthCm'] as num?)?.toDouble(),
  );
}
