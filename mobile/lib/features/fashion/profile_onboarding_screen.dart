import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/fashion_profile.dart';
import '../../services/fashion_api_service.dart';
import '../../services/fashion_state.dart';

class ProfileOnboardingScreen extends StatefulWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  final fields = {
    for (final key in ['height', 'bust', 'waist', 'hip'])
      key: TextEditingController(),
  };
  int step = 0;
  String shape = 'hourglass';
  String fit = 'regular';
  String tone = 'Medium';
  String style = 'casual';
  String budget = '\$50–100';

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> finish({bool skip = false}) async {
    final profile = skip
        ? const FashionProfile()
        : FashionProfile(
            height: double.tryParse(fields['height']!.text),
            bust: double.tryParse(fields['bust']!.text),
            waist: double.tryParse(fields['waist']!.text),
            hip: double.tryParse(fields['hip']!.text),
            bodyShape: shape,
            preferredFit: fit,
            skinTone: tone,
            style: style,
            budget: budget,
          );
    final profileState = context.read<FashionProfileState>();
    await profileState.save(profile);
    unawaited(FashionApiService().saveProfile(profile));
    if (!mounted) return;
    context.go('/avatar');
  }

  Widget chips(
    List<String> values,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => ChoiceChip(
              label: Text(value),
              selected: selected == value,
              onSelected: (_) => onChanged(value),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstStep = step == 0;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'TWINLY / YOUR STYLE TWIN',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              firstStep
                  ? 'Let’s make this feel like you.'
                  : 'A few details, then we style.',
              style: theme.textTheme.displaySmall,
            ),
            Text(
              'Your profile helps us make more personal outfit previews.',
              style: theme.textTheme.bodyLarge,
            ),
            if (firstStep) ...[
              const SizedBox(height: 28),
              Text(
                'Measurements (cm, optional)',
                style: theme.textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fields.entries
                    .map(
                      (entry) => SizedBox(
                        width: 150,
                        child: TextField(
                          controller: entry.value,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: entry.key),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Text('Body shape', style: theme.textTheme.titleMedium),
              chips(
                ['hourglass', 'pear', 'apple', 'rectangle', 'athletic'],
                shape,
                (value) => setState(() => shape = value),
              ),
              const SizedBox(height: 20),
              Text('Preferred fit', style: theme.textTheme.titleMedium),
              chips(
                ['fitted', 'regular', 'loose'],
                fit,
                (value) => setState(() => fit = value),
              ),
            ] else ...[
              const SizedBox(height: 28),
              Text('Skin tone', style: theme.textTheme.titleMedium),
              chips(
                ['Porcelain', 'Fair', 'Medium', 'Olive', 'Deep', 'Rich'],
                tone,
                (value) => setState(() => tone = value),
              ),
              const SizedBox(height: 20),
              Text('Style preference', style: theme.textTheme.titleMedium),
              chips(
                ['casual', 'formal', 'streetwear', 'classic'],
                style,
                (value) => setState(() => style = value),
              ),
              const SizedBox(height: 20),
              Text('Typical budget', style: theme.textTheme.titleMedium),
              chips(
                ['Under \$50', '\$50–100', '\$100–200', '\$200+'],
                budget,
                (value) => setState(() => budget = value),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!firstStep)
                  TextButton(
                    onPressed: () => setState(() => step = 0),
                    child: const Text('Back'),
                  ),
                FilledButton(
                  onPressed: firstStep
                      ? () => setState(() => step = 1)
                      : finish,
                  child: Text(firstStep ? 'Continue' : 'Enter Twinly'),
                ),
              ],
            ),
            if (firstStep)
              TextButton(
                onPressed: () => finish(skip: true),
                child: const Text('Skip for now'),
              ),
          ],
        ),
      ),
    );
  }
}
