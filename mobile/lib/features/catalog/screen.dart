import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/garment_catalog.dart';
import '../../core/providers/garment_state.dart';
import '../../models/garment.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedGarmentProvider);
    final notifier = ref.read(selectedGarmentProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: garmentCatalog.length,
                itemBuilder: (context, index) {
                  final garment = garmentCatalog[index];
                  final isSelected = selected?.id == garment.id;
                  return _GarmentCard(
                    garment: garment,
                    isSelected: isSelected,
                    onTap: () => notifier.select(garment),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () => context.go('/fitting'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text('Try on', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GarmentCard extends StatelessWidget {
  const _GarmentCard({
    required this.garment,
    required this.isSelected,
    required this.onTap,
  });

  final Garment garment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: garment.placeholderColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              garment.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
