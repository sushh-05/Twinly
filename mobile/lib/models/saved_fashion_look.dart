import 'fashion_garment.dart';
import 'fit_guide.dart';

class SavedFashionLook {
  const SavedFashionLook({
    required this.id,
    required this.imageUrl,
    required this.garment,
    required this.fit,
    required this.createdAt,
  });
  final String id, imageUrl;
  final FashionGarment garment;
  final FitGuide fit;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'garment': garment.toJson(),
    'fit': fit.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };
  factory SavedFashionLook.fromJson(Map<String, dynamic> json) =>
      SavedFashionLook(
        id: json['id'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        garment: FashionGarment.fromJson(
          Map<String, dynamic>.from(json['garment'] as Map),
        ),
        fit: FitGuide.fromJson(Map<String, dynamic>.from(json['fit'] as Map)),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
