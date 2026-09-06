import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/providers/avatar_state.dart';

class Avatar3DView extends ConsumerWidget {
  final double height;
  final bool isSideView;
  final Widget? overlay;

  const Avatar3DView({
    super.key,
    this.height = 300,
    this.isSideView = false,
    this.overlay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read shared measurements from Person A's Riverpod state
    final m = ref.watch(avatarMeasurementsProvider);

    // Person B baseline scaling (Contract: Height 165cm, Waist 72cm, Hip 95cm)
    final double scaleX = (m.waist / 72.0).clamp(0.70, 1.40);
    final double scaleY = (m.height / 165.0).clamp(0.75, 1.30);
    final double scaleZ = (m.hip / 95.0).clamp(0.70, 1.40);

    final scaleString =
        '${scaleX.toStringAsFixed(2)} ${scaleY.toStringAsFixed(2)} ${scaleZ.toStringAsFixed(2)}';

    // Switch between front (0deg) and side (90deg) camera orbit
    final cameraOrbit = isSideView ? '90deg 75deg 3.5m' : '0deg 75deg 3.5m';

    final modelAsset = m.isFeminine
        ? 'assets/models/avatar_feminine.glb'
        : 'assets/models/avatar_masculine.glb';

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          ModelViewer(
            key: ValueKey('$modelAsset-$scaleString-$cameraOrbit'),
            src: modelAsset,
            alt: '3D Humanoid Mannequin',
            ar: false,
            autoRotate: false,
            cameraControls: true,
            scale: scaleString,
            cameraOrbit: cameraOrbit,
            backgroundColor: const Color(0xFFF5F5F7),
          ),
          ?overlay,
        ],
      ),
    );
  }
}
