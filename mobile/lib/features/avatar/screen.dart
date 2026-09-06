import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_state.dart';
import 'avatar_3d_view.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  // Front vs Side view orbit angle for the 3D model
  bool _isSideView = false;

  @override
  Widget build(BuildContext context) {
    final measurements = ref.watch(avatarMeasurementsProvider);
    final notifier = ref.read(avatarMeasurementsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Avatar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Gender toggle — switches between feminine & masculine GLBs
          IconButton(
            icon: Icon(measurements.isFeminine ? Icons.female : Icons.male),
            tooltip: measurements.isFeminine
                ? 'Switch to male profile'
                : 'Switch to female profile',
            onPressed: () {
              notifier.setGender(!measurements.isFeminine);
            },
          ),
          // Front / Side view toggle — orbits 3D camera 90 degrees
          IconButton(
            icon: Icon(_isSideView ? Icons.person : Icons.person_outline),
            tooltip: _isSideView ? 'Front view' : 'Side view',
            onPressed: () {
              setState(() => _isSideView = !_isSideView);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3D Avatar Display Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Avatar3DView(
                      height: double.infinity,
                      isSideView: _isSideView,
                    ),
                  ),
                ),
              ),
            ),

            // Sliders Control Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSlider(
                      label: 'Height',
                      value: measurements.height,
                      min: 140,
                      max: 200,
                      suffix: 'cm',
                      onChanged: notifier.setHeight,
                    ),
                    _buildSlider(
                      label: 'Chest',
                      value: measurements.chest,
                      min: 70,
                      max: 130,
                      suffix: 'cm',
                      onChanged: notifier.setChest,
                    ),
                    _buildSlider(
                      label: 'Waist',
                      value: measurements.waist,
                      min: 55,
                      max: 120,
                      suffix: 'cm',
                      onChanged: notifier.setWaist,
                    ),
                    _buildSlider(
                      label: 'Hip',
                      value: measurements.hip,
                      min: 75,
                      max: 140,
                      suffix: 'cm',
                      onChanged: notifier.setHip,
                    ),
                    _buildSlider(
                      label: 'Leg length (inseam)',
                      value: measurements.inseam,
                      min: 60,
                      max: 100,
                      suffix: 'cm',
                      onChanged: notifier.setInseam,
                    ),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/catalog');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue to Catalog',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '${value.round()} $suffix',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: '${value.round()} $suffix',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
