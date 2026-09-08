import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_profiles_state.dart';
import '../../core/providers/avatar_state.dart';
import '../../widgets/avatar_profile_sheet.dart';
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
    final profilesState = ref.watch(avatarProfilesProvider);
    final activeProfile = profilesState.activeProfile;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF7F8FA);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          'Your Avatar',
          style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        actions: [
          // Switch between feminine & masculine
          IconButton(
            icon: Icon(measurements.isFeminine ? Icons.female : Icons.male),
            tooltip: measurements.isFeminine
                ? 'Switch to male profile'
                : 'Switch to female profile',
            onPressed: () {
              final newGender = !measurements.isFeminine;
              notifier.setGender(newGender);
              ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(
                    AvatarMeasurements.defaultsFor(isFeminine: newGender),
                  );
            },
          ),
          // Front / Side view toggle
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
            // Active Person Profile Switcher Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => showAvatarProfileSheet(context, ref),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF182828) : Colors.teal.shade50.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.teal,
                              child: Icon(
                                measurements.isFeminine ? Icons.female : Icons.male,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Profile: ${activeProfile?.name ?? "Me"} (${activeProfile?.relation ?? "Myself"})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.teal.shade200 : Colors.teal.shade900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Size ${activeProfile?.sizePreset ?? "S"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade300,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: Colors.teal.shade400),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    tooltip: 'Add new person',
                    color: Colors.teal.shade400,
                    onPressed: () => showAvatarProfileSheet(context, ref),
                  ),
                ],
              ),
            ),

            // 3D Avatar Display Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16161A) : const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
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

            // Quick Size Presets Selector Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Size Presets:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: AvatarSizePresets.sizes.map((size) {
                          final isSel = activeProfile?.sizePreset == size;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(size, style: const TextStyle(fontSize: 12)),
                              selected: isSel,
                              selectedColor: Colors.teal,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : textPrimary,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                final std = AvatarSizePresets.getMeasurements(
                                  measurements.isFeminine,
                                  size,
                                );
                                notifier.setHeight(std.height);
                                notifier.setChest(std.chest);
                                notifier.setWaist(std.waist);
                                notifier.setHip(std.hip);
                                notifier.setInseam(std.inseam);
                                ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(std);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Sliders Control Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              constraints: const BoxConstraints(maxHeight: 250),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSlider(
                      label: 'Height',
                      value: measurements.height,
                      min: 140,
                      max: 200,
                      suffix: 'cm',
                      textColor: textPrimary,
                      textSecColor: textSecondary,
                      onChanged: (v) {
                        notifier.setHeight(v);
                        ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(
                              measurements.copyWith(height: v, inseam: v * 0.45),
                            );
                      },
                    ),
                    _buildSlider(
                      label: measurements.isFeminine ? 'Bust (Chest)' : 'Chest',
                      value: measurements.chest,
                      min: 70,
                      max: 130,
                      suffix: 'cm',
                      textColor: textPrimary,
                      textSecColor: textSecondary,
                      onChanged: (v) {
                        notifier.setChest(v);
                        ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(
                              measurements.copyWith(chest: v),
                            );
                      },
                    ),
                    _buildSlider(
                      label: 'Waist',
                      value: measurements.waist,
                      min: 55,
                      max: 120,
                      suffix: 'cm',
                      textColor: textPrimary,
                      textSecColor: textSecondary,
                      onChanged: (v) {
                        notifier.setWaist(v);
                        ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(
                              measurements.copyWith(waist: v),
                            );
                      },
                    ),
                    _buildSlider(
                      label: 'Hip',
                      value: measurements.hip,
                      min: 75,
                      max: 140,
                      suffix: 'cm',
                      textColor: textPrimary,
                      textSecColor: textSecondary,
                      onChanged: (v) {
                        notifier.setHip(v);
                        ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(
                              measurements.copyWith(hip: v),
                            );
                      },
                    ),
                    _buildSlider(
                      label: 'Leg length (inseam)',
                      value: measurements.inseam,
                      min: 60,
                      max: 100,
                      suffix: 'cm',
                      textColor: textPrimary,
                      textSecColor: textSecondary,
                      onChanged: (v) {
                        notifier.setInseam(v);
                        ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(
                              measurements.copyWith(inseam: v),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/catalog');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Catalog',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
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
    required Color textColor,
    required Color textSecColor,
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
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: textColor),
            ),
            Text(
              '${value.round()} $suffix',
              style: TextStyle(
                fontSize: 13.5,
                color: textSecColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.teal,
          divisions: (max - min).toInt(),
          label: '${value.round()} $suffix',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
