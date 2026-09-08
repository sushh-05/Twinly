class FitRegion {
  const FitRegion({required this.label, this.easeCm});
  final String label;
  final double? easeCm;
  factory FitRegion.fromJson(Map<String, dynamic> json) => FitRegion(
    label: json['label'] as String,
    easeCm: (json['easeCm'] as num?)?.toDouble(),
  );
}

class FitReport {
  const FitReport({
    required this.status,
    required this.garmentId,
    this.recommendedSize,
    this.confidence,
    required this.regions,
    required this.explanation,
    required this.disclaimer,
  });
  final String status;
  final String garmentId;
  final String? recommendedSize;
  final String? confidence;
  final Map<String, FitRegion> regions;
  final String explanation;
  final String disclaimer;

  factory FitReport.fromJson(Map<String, dynamic> json) {
    final rawRegions = Map<String, dynamic>.from(json['regions'] as Map? ?? {});
    return FitReport(
      status: json['status'] as String,
      garmentId: json['garmentId'] as String,
      recommendedSize: json['recommendedSize'] as String?,
      confidence: json['confidence'] as String?,
      regions: rawRegions.map(
        (key, value) => MapEntry(
          key,
          FitRegion.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
      explanation: json['explanation'] as String,
      disclaimer: json['disclaimer'] as String,
    );
  }
}
