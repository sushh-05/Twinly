class FashionProfile {
  const FashionProfile({
    this.height,
    this.shoulderWidth,
    this.bust,
    this.waist,
    this.hip,
    this.bodyShape = 'hourglass',
    this.preferredFit = 'regular',
    this.skinTone = 'Medium',
    this.hairType = 'short',
    this.style = 'casual',
    this.budget = '\$50–100',
  });

  final double? height;
  final double? shoulderWidth;
  final double? bust;
  final double? waist;
  final double? hip;
  final String bodyShape;
  final String preferredFit;
  final String skinTone;
  final String hairType;
  final String style;
  final String budget;

  Map<String, dynamic> toJson() => {
    'height': height?.toString(),
    'shoulderWidth': shoulderWidth?.toString(),
    'bust': bust?.toString(),
    'waist': waist?.toString(),
    'hip': hip?.toString(),
    'bodyShape': bodyShape,
    'preferredFit': preferredFit,
    'skinTone': skinTone,
    'hairType': hairType,
    'style': style,
    'budget': budget,
  };

  factory FashionProfile.fromJson(Map<String, dynamic> json) => FashionProfile(
    height: double.tryParse('${json['height'] ?? ''}'),
    shoulderWidth: double.tryParse('${json['shoulderWidth'] ?? ''}'),
    bust: double.tryParse('${json['bust'] ?? ''}'),
    waist: double.tryParse('${json['waist'] ?? ''}'),
    hip: double.tryParse('${json['hip'] ?? ''}'),
    bodyShape: json['bodyShape'] as String? ?? 'hourglass',
    preferredFit: json['preferredFit'] as String? ?? 'regular',
    skinTone: json['skinTone'] as String? ?? 'Medium',
    hairType: json['hairType'] as String? ?? 'short',
    style: json['style'] as String? ?? 'casual',
    budget: json['budget'] as String? ?? '\$50–100',
  );
}
