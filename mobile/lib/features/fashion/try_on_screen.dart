import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/providers/usage_limits_state.dart';
import '../../models/fashion_garment.dart';
import '../../models/fashion_profile.dart';
import '../../models/fit_guide.dart';
import '../../models/saved_fashion_look.dart';
import '../../services/fashion_api_service.dart';
import '../../services/fashion_state.dart';
import '../../services/revenuecat_service.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  final url = TextEditingController();
  final notes = TextEditingController();
  final api = FashionApiService();
  XFile? picked;
  Uint8List? bytes;
  FashionGarment? garment;
  String? imageUrl;
  FitGuide? fit;
  bool busy = false;
  bool manual = false;
  bool generationFailed = false;

  @override
  void dispose() {
    url.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> choose() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;
    final fileBytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      picked = file;
      bytes = fileBytes;
      url.clear();
    });
  }

  FashionGarment get fallback => FashionGarment(
    category: 'dress',
    color: 'soft neutral',
    styleNotes: notes.text.isEmpty ? 'clean, everyday style' : notes.text,
  );

  Future<void> analyze() async {
    if (picked == null && url.text.trim().isEmpty) return;
    setState(() {
      busy = true;
      manual = false;
      generationFailed = false;
    });
    try {
      final result = picked != null
          ? await api.analyzeImage(bytes!, picked!.name)
          : await api.analyzeUrl(url.text.trim());
      if (!mounted) return;
      setState(() {
        garment = result;
        notes.text = result.styleNotes;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        garment = fallback;
        manual = true;
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> generate() async {
    final profile =
        context.read<FashionProfileState>().profile ?? const FashionProfile();
    final currentGarment = garment ?? fallback;
    final revenueCat = context.read<RevenueCatService>();
    final usage = context.read<UsageLimitsState>();
    final savedLooks = context.read<SavedLooksState>();
    final premium = revenueCat.isPremium;
    if (!premium && usage.state.triesUsed >= UsageLimits.freeTriesLimit) {
      if (mounted) context.push('/premium');
      return;
    }

    final guide = FitGuide.calculate(
      bust: profile.bust,
      waist: profile.waist,
      hip: profile.hip,
    );
    setState(() {
      busy = true;
      generationFailed = false;
      fit = guide;
    });
    await usage.registerTryIfNew(
      DateTime.now().millisecondsSinceEpoch.toString(),
      isPremium: premium,
    );
    try {
      final generatedUrl = await api.generate(
        profile: profile,
        garment: currentGarment,
        url: url.text.trim().isEmpty ? null : url.text.trim(),
        imageBytes: bytes,
        filename: picked?.name,
      );
      await savedLooks.add(
        SavedFashionLook(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          imageUrl: generatedUrl,
          garment: currentGarment,
          fit: guide,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      setState(() => imageUrl = generatedUrl);
    } catch (_) {
      if (mounted) setState(() => generationFailed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget pills(String label, List<String> values) {
    final current = garment ?? fallback;
    final selected = label == 'Category' ? current.category : current.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: values
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: selected.toLowerCase() == value.toLowerCase(),
                  onSelected: (_) {
                    final next = FashionGarment(
                      category: label == 'Category'
                          ? value.toLowerCase()
                          : current.category,
                      color: label == 'Color'
                          ? value.toLowerCase()
                          : current.color,
                      pattern: current.pattern,
                      sleeveLength: current.sleeveLength,
                      neckline: current.neckline,
                      styleNotes: notes.text,
                    );
                    setState(() => garment = next);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentGarment = garment;
    return Scaffold(
      appBar: AppBar(title: const Text('Try something on')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Bring a garment. We’ll imagine the rest.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: choose,
            child: Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xfff1e8e2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: bytes == null
                  ? const Center(child: Text('＋  Upload a garment photo'))
                  : Image.memory(bytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          const Center(child: Text('or paste a product URL')),
          TextField(
            controller: url,
            onChanged: (_) {
              if (url.text.isNotEmpty) setState(() => picked = null);
            },
            decoration: const InputDecoration(
              hintText: 'https://shop.example.com/item',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: busy ? null : analyze,
            child: Text(busy ? 'Working…' : 'Analyze garment'),
          ),
          if (currentGarment != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manual ? 'MANUAL ENTRY' : 'GARMENT FOUND',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      '${currentGarment.color} ${currentGarment.category}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${currentGarment.styleNotes} · ${currentGarment.sleeveLength} sleeves · ${currentGarment.neckline} neckline',
                    ),
                    if (manual) ...[
                      const SizedBox(height: 14),
                      pills('Category', ['Dress', 'Top', 'Pants', 'Skirt']),
                      pills('Color', [
                        'Black',
                        'White',
                        'Soft neutral',
                        'Bright red',
                        'Navy',
                      ]),
                      TextField(
                        controller: notes,
                        decoration: const InputDecoration(
                          labelText: 'Style notes',
                        ),
                      ),
                    ],
                    FilledButton(
                      onPressed: busy ? null : generate,
                      child: const Text('Generate AI Style Preview'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (generationFailed)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('AI preview unavailable right now'),
            ),
          if (imageUrl != null) ...[
            const SizedBox(height: 20),
            CachedNetworkImage(
              imageUrl: imageUrl!,
              height: 320,
              fit: BoxFit.cover,
            ),
            const Text(
              'This preview is approximate and not an exact rendering of the product.',
            ),
          ],
          if (fit != null)
            Card(
              color: const Color(0xff2e2925),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FIT GUIDE',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      fit!.recommendedSize,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${fit!.confidence} confidence',
                      style: const TextStyle(color: Color(0xffe0c1b2)),
                    ),
                    const Text(
                      'Bust good · Waist good · Hip good',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      fit!.summary,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
