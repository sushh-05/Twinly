import 'package:flutter/material.dart';

import '../../models/garment.dart';

class GarmentImage extends StatelessWidget {
  const GarmentImage({super.key, required this.garment, this.aspectRatio});
  final Garment garment;
  final double? aspectRatio;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: AspectRatio(
      aspectRatio: aspectRatio ?? .72,
      child: _assetOrFallback(),
    ),
  );
  Widget _assetOrFallback() {
    if ((garment.assetImagePath ?? '').isNotEmpty) {
      return Image.asset(
        garment.assetImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if ((garment.fallbackImageUrl ?? '').isNotEmpty) {
      return Image.network(
        garment.fallbackImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xff29212e), Color(0xff121212)]),
    ),
    child: const Icon(
      Icons.checkroom_outlined,
      color: Colors.white70,
      size: 40,
    ),
  );
}
