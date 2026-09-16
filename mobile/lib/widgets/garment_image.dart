import 'package:flutter/material.dart';

import '../models/garment.dart';

class GarmentImage extends StatelessWidget {
  final Garment garment;
  final BoxFit fit;

  const GarmentImage({
    super.key,
    required this.garment,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (garment.assetImagePath != null && garment.assetImagePath!.isNotEmpty) {
      return Image.asset(
        garment.assetImagePath!,
        width: double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Failed to load asset ${garment.assetImagePath}: $error');
          if (garment.fallbackImageUrl != null &&
              garment.fallbackImageUrl!.isNotEmpty) {
            return Image.network(
              garment.fallbackImageUrl!,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            );
          }
          return _placeholder();
        },
      );
    } else if (garment.fallbackImageUrl != null &&
        garment.fallbackImageUrl!.isNotEmpty) {
      return Image.network(
        garment.fallbackImageUrl!,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.teal,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: garment.placeholderColor,
      child: const Center(
        child: Icon(Icons.checkroom, color: Colors.white38, size: 40),
      ),
    );
  }
}
