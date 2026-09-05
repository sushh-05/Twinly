import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/garment_catalog.dart';
import '../../core/providers/saved_avatars_state.dart';

class SavedLooksScreen extends ConsumerWidget {
  const SavedLooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLooks = ref.watch(savedAvatarsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved looks')),
      body: savedLooks.isEmpty
          ? const Center(child: Text('No saved looks yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedLooks.length,
              itemBuilder: (context, index) {
                final entry = savedLooks[index];
                final garment = garmentCatalog.firstWhere(
                  (g) => g.id == entry.garmentId,
                  orElse: () => garmentCatalog.first,
                );
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: garment.placeholderColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    title: Text(entry.name),
                    subtitle: Text(garment.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/account/saved/detail', extra: entry);
                    },
                  ),
                );
              },
            ),
    );
  }
}
