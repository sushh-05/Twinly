import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/garment_state.dart';
import '../../core/widgets/garment_image.dart';
import '../../models/garment.dart';

class DressDetailScreen extends ConsumerStatefulWidget {
  const DressDetailScreen({super.key, required this.garment});

  final Garment garment;

  @override
  ConsumerState<DressDetailScreen> createState() => _DressDetailScreenState();
}

class _DressDetailScreenState extends ConsumerState<DressDetailScreen> {
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = _initialSelectedSize(widget.garment.availableSizes);
  }

  String _initialSelectedSize(List<String> sizes) {
    if (sizes.contains('M')) return 'M';
    if (sizes.isNotEmpty) return sizes.first;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final garment = widget.garment;
    final canViewChart =
        garment.verifiedSizeChart && garment.sizeChart.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.ios_share, color: Colors.white),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GarmentImage(garment: garment, aspectRatio: 0.72),
                    const SizedBox(height: 18),
                    Text(
                      garment.brand ?? 'Twinly Edit',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      garment.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${garment.currencySymbol ?? '₹'}${garment.price?.toStringAsFixed(0) ?? '—'}',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    if (garment.silhouette != null)
                      _MetadataRow('Dress silhouette', garment.silhouette!),
                    if (garment.fabricStretch != null)
                      _MetadataRow('Fabric stretch', garment.fabricStretch!),
                    if (garment.fabricMaterial != null)
                      _MetadataRow('Material', garment.fabricMaterial!),
                    const SizedBox(height: 16),
                    const Text(
                      'Size',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: garment.availableSizes.map((size) {
                        final selected = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedSize = size),
                          selectedColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: selected ? Colors.white : Colors.white54,
                          ),
                          labelStyle: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: canViewChart
                          ? () => _showSizeChart(context)
                          : null,
                      child: Text(
                        canViewChart
                            ? 'View size chart'
                            : 'Verified size chart unavailable',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const OutlinedButton(
                      onPressed: null,
                      child: Text('Paste product link — coming soon'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref.read(selectedGarmentProvider.notifier).select(garment);
                    context.go('/fitting');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Check my fit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSizeChart(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF202020),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Structural size chart',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 4),
              const Text('cm', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Size')),
                    DataColumn(label: Text('Bust')),
                    DataColumn(label: Text('Waist')),
                    DataColumn(label: Text('Hips')),
                    DataColumn(label: Text('Length')),
                  ],
                  rows: widget.garment.sizeChart.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(row.size)),
                        DataCell(Text(row.bustRange ?? '—')),
                        DataCell(Text(row.waistRange ?? '—')),
                        DataCell(Text(row.hipRange ?? '—')),
                        DataCell(
                          Text(
                            row.lengthCm == null
                                ? '—'
                                : '${row.lengthCm!.toStringAsFixed(0)} cm',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recommendations are estimates, not guarantees.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
