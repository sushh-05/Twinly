import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/avatar_profiles_state.dart';
import '../../core/providers/avatar_state.dart';
import '../../widgets/avatar_profile_sheet.dart';
import 'body_painter.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});
  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  bool _isSideView = false;

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(avatarMeasurementsProvider);
    final profiles = ref.watch(avatarProfilesProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = dark ? Colors.white : const Color(0xff111827);
    final secondary = dark ? Colors.white70 : const Color(0xff6b7280);
    final card = dark ? const Color(0xff16161a) : Colors.white;

    void update(AvatarMeasurements next) {
      ref.read(avatarMeasurementsProvider.notifier).setMeasurements(next);
      ref.read(avatarProfilesProvider.notifier).updateActiveMeasurements(next);
    }

    return Scaffold(
      backgroundColor: dark ? Colors.black : const Color(0xfff7f8fa),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Build your avatar',
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSideView ? Icons.person : Icons.person_outline),
            tooltip: 'Toggle view',
            onPressed: () => setState(() => _isSideView = !_isSideView),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust your measurements anytime. This is a visual representation, not a body scan.',
                style: TextStyle(color: secondary, height: 1.35),
              ),
              const SizedBox(height: 16),
              Container(
                height: 330,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: dark ? Colors.white12 : Colors.black12,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      dark ? const Color(0xff202b2d) : const Color(0xffeef8f7),
                      card,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 18,
                      top: 16,
                      child: Text(
                        'Visual profile',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Center(
                      child: CustomPaint(
                        size: const Size(260, 300),
                        painter: BodyPainter(
                          height: m.height,
                          chest: m.chest,
                          waist: m.waist,
                          hip: m.hip,
                          inseam: m.inseam,
                          isFeminine: m.isFeminine,
                          isSideView: _isSideView,
                          skinTone: m.skinTone,
                          hairStyle: m.hairStyle,
                          hairColor: m.hairColor,
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 18,
                      bottom: 16,
                      child: Text(
                        'Measurement-based mannequin',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _label('Body frame', primary),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Feminine'),
                    icon: Icon(Icons.female),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Masculine'),
                    icon: Icon(Icons.male),
                  ),
                ],
                selected: {m.isFeminine},
                onSelectionChanged: (s) {
                  final next = AvatarMeasurements.defaultsFor(
                    isFeminine: s.first,
                  );
                  update(next);
                },
              ),
              const SizedBox(height: 18),
              _label('Measurements', primary),
              _slider(
                'Height',
                m.height,
                140,
                200,
                m,
                secondary,
                (v) => update(m.copyWith(height: v)),
              ),
              _slider(
                m.isFeminine ? 'Bust' : 'Chest',
                m.chest,
                70,
                130,
                m,
                secondary,
                (v) => update(m.copyWith(chest: v)),
              ),
              _slider(
                'Waist',
                m.waist,
                55,
                120,
                m,
                secondary,
                (v) => update(m.copyWith(waist: v)),
              ),
              _slider(
                'Hip',
                m.hip,
                75,
                140,
                m,
                secondary,
                (v) => update(m.copyWith(hip: v)),
              ),
              _slider(
                'Leg length / inseam',
                m.inseam,
                60,
                100,
                m,
                secondary,
                (v) => update(m.copyWith(inseam: v)),
              ),
              const SizedBox(height: 8),
              _label('Skin tone', primary),
              _chips(
                ['fair', 'light', 'medium', 'tan', 'deep'],
                m.skinTone,
                (v) => update(m.copyWith(skinTone: v)),
                secondary,
              ),
              const SizedBox(height: 12),
              _label('Hair style', primary),
              _chips(
                ['short', 'long straight', 'wavy', 'curly', 'bun', 'ponytail'],
                m.hairStyle,
                (v) => update(m.copyWith(hairStyle: v)),
                secondary,
              ),
              const SizedBox(height: 12),
              _label('Hair color', primary),
              _chips(
                ['black', 'dark brown', 'brown', 'blonde', 'auburn', 'gray'],
                m.hairColor,
                (v) => update(m.copyWith(hairColor: v)),
                secondary,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(avatarProfilesProvider.notifier)
                        .updateActiveMeasurements(m);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Avatar saved locally.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Save avatar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.push('/catalog'),
                  child: const Text('Explore dresses'),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Twinly uses your entered measurements to create a visual mannequin. It does not create an exact body scan or guarantee fit.',
                style: TextStyle(color: secondary, fontSize: 12, height: 1.35),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => showAvatarProfileSheet(context, ref),
                icon: const Icon(Icons.people_outline),
                label: Text('Profile: ${profiles.activeProfile?.name ?? 'Me'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(
    text,
    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
  );

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    AvatarMeasurements m,
    Color secondary,
    ValueChanged<double> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${value.round()} cm', style: TextStyle(color: secondary)),
        ],
      ),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: (max - min).round(),
        activeColor: Colors.teal,
        onChanged: onChanged,
      ),
    ],
  );

  Widget _chips(
    List<String> values,
    String selected,
    ValueChanged<String> onTap,
    Color secondary,
  ) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: values
        .map(
          (v) => Semantics(
            button: true,
            label: v,
            selected: selected == v,
            child: ChoiceChip(
              label: Text(v),
              selected: selected == v,
              selectedColor: Colors.teal,
              labelStyle: TextStyle(
                color: selected == v ? Colors.white : secondary,
              ),
              onSelected: (_) => onTap(v),
            ),
          ),
        )
        .toList(),
  );
}
