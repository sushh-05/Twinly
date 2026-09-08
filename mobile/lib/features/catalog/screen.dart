import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/garment_state.dart';
import '../../core/widgets/garment_image.dart';
import '../../models/garment.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(remoteGarmentsProvider);
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Twinly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (kDebugMode && catalog.hasValue)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Chip(
                    label: Text(
                      catalog.requireValue.usingOfflineCatalog
                          ? 'Offline catalog'
                          : 'Backend connected',
                    ),
                  ),
                ),
              ),
            Expanded(
              child: catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => const Center(
                  child: Text(
                    'Unable to load catalog',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                data: (state) {
                  final dresses = state.garments
                      .where((g) => g.category == 'dress')
                      .toList();
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: .47,
                        ),
                    itemCount: dresses.length,
                    itemBuilder: (_, i) => _Card(dresses[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card(this.g);
  final Garment g;
  @override
  Widget build(BuildContext c, WidgetRef r) => InkWell(
    onTap: () => c.push('/catalog/detail', extra: g),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xff1c1c1c),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GarmentImage(garment: g),
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0x88000000),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              if (g.verifiedSizeChart)
                const Positioned(
                  left: 7,
                  bottom: 7,
                  child: Chip(
                    label: Text(
                      'Verified size chart',
                      style: TextStyle(fontSize: 9, color: Colors.black),
                    ),
                    backgroundColor: Color(0xff62e6df),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            g.brand ?? 'Twinly Edit',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          Text(
            g.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${g.currencySymbol ?? '₹'}${g.price?.toStringAsFixed(0) ?? ''}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Sizes: ${g.availableSizes.isEmpty ? '—' : '${g.availableSizes.first}–${g.availableSizes.last}'}',
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                r.read(selectedGarmentProvider.notifier).select(g);
                c.go('/fitting');
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff62e6df),
                foregroundColor: Colors.black,
              ),
              child: const Text('Try on'),
            ),
          ),
        ],
      ),
    ),
  );
}
