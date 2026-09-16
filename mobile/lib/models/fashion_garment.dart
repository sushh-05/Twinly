class FashionGarment {
  const FashionGarment({
    required this.category,
    required this.color,
    this.pattern = 'solid',
    this.sleeveLength = 'short',
    this.neckline = 'round',
    this.styleNotes = 'clean, everyday style',
  });
  final String category, color, pattern, sleeveLength, neckline, styleNotes;
  Map<String, dynamic> toJson() => {
    'category': category,
    'color': color,
    'pattern': pattern,
    'sleeveLength': sleeveLength,
    'neckline': neckline,
    'styleNotes': styleNotes,
  };
  factory FashionGarment.fromJson(Map<String, dynamic> json) => FashionGarment(
    category: json['category'] as String? ?? 'dress',
    color: json['color'] as String? ?? 'soft neutral',
    pattern: json['pattern'] as String? ?? 'solid',
    sleeveLength: json['sleeveLength'] as String? ?? 'short',
    neckline: json['neckline'] as String? ?? 'round',
    styleNotes: json['styleNotes'] as String? ?? 'clean, everyday style',
  );
}
