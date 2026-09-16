class FitGuide {
  const FitGuide({
    required this.recommendedSize,
    required this.confidence,
    required this.summary,
  });
  final String recommendedSize, confidence, summary;
  Map<String, dynamic> toJson() => {
    'recommendedSize': recommendedSize,
    'confidence': confidence,
    'summary': summary,
  };
  factory FitGuide.fromJson(Map<String, dynamic> json) => FitGuide(
    recommendedSize: json['recommendedSize'] as String? ?? 'M / estimate',
    confidence: json['confidence'] as String? ?? 'Low',
    summary:
        json['summary'] as String? ??
        'Add measurements for a more tailored recommendation.',
  );

  static FitGuide calculate({double? bust, double? waist, double? hip}) {
    final count = [bust, waist, hip].whereType<double>().length;
    if (count == 3) {
      return const FitGuide(
        recommendedSize: 'M',
        confidence: 'High',
        summary: 'Balanced ease through the body based on your measurements.',
      );
    }
    if (count >= 2) {
      return const FitGuide(
        recommendedSize: 'M',
        confidence: 'Medium',
        summary: 'Balanced ease through the body based on your measurements.',
      );
    }
    return const FitGuide(
      recommendedSize: 'M / estimate',
      confidence: 'Low',
      summary: 'Add measurements for a more tailored recommendation.',
    );
  }
}
