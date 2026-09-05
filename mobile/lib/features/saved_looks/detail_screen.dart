import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/garment_catalog.dart';
import '../../core/logic/fit_engine.dart';
import '../../core/providers/saved_avatars_state.dart';
import '../avatar/body_painter.dart';
import '../fitting/screen.dart'; // reuses the private-package _FitRow? see note below

class SavedLookDetailScreen extends StatelessWidget {
  const SavedLookDetailScreen({super.key, required this.entry});

  final SavedAvatarEntry entry;

  @override
  Widget build(BuildContext context) {
    final garment = garmentCatalog.firstWhere(
      (g) => g.id == entry.garmentId,
      orElse: () => garmentCatalog.first,
    );
    final fitResults = computeFit(entry.measurements, garment);

    return Scaffold(
      appBar: AppBar(title: Text(entry.name)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(280, 500),
                      painter: BodyPainter(
                        height: entry.measurements.height,
                        chest: entry.measurements.chest,
                        waist: entry.measurements.waist,
                        hip: entry.measurements.hip,
                        inseam: entry.measurements.inseam,
                        isSideView: false,
                      ),
                    ),
                    Positioned(
                      top: 90,
                      child: Container(
                        width: 90,
                        height: 160,
                        decoration: BoxDecoration(
                          color: garment.placeholderColor.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: fitResults
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: r.verdict == FitVerdict.tight
                                    ? Colors.red
                                    : r.verdict == FitVerdict.good
                                    ? Colors.green
                                    : Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(r.note),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
