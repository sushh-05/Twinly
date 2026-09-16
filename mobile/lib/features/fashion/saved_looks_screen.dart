import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/fashion_state.dart';

class FashionSavedLooksScreen extends StatelessWidget {
  const FashionSavedLooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final looks = context.watch<SavedLooksState>().looks;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved looks')),
      body: looks.isEmpty
          ? const Center(child: Text('Your generated looks will live here.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: looks.length,
              itemBuilder: (context, index) {
                final look = looks[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (look.imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: look.imageUrl,
                          height: 270,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${look.garment.color} ${look.garment.category}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${look.fit.recommendedSize} · ${look.fit.confidence} confidence',
                            ),
                            TextButton(
                              onPressed: () => _share(context, look.imageUrl),
                              child: const Text('Share preview'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _share(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This preview is unavailable to share.')),
      );
      return;
    }
    try {
      await Share.share(url, subject: 'My Twinly look');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is unavailable on this device.')),
      );
    }
  }
}
