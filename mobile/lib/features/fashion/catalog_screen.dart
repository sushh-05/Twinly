import 'package:flutter/material.dart';

class FashionCatalogScreen extends StatelessWidget {
  const FashionCatalogScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Catalog')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'A few starting points for your next look.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        _card(
          'Soft tailoring',
          'Neutral layers for everyday polish',
          const Color(0xffd8c5b8),
        ),
        _card(
          'Weekend linen',
          'Easy silhouettes, warm tones',
          const Color(0xffd2d9c2),
        ),
        _card(
          'City night',
          'A little drama, very wearable',
          const Color(0xffc7b7c7),
        ),
      ],
    ),
  );
  Widget _card(String title, String subtitle, Color color) => Container(
    height: 150,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(subtitle),
      ],
    ),
  );
}
