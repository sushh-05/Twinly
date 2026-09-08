import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/garment_state.dart';
import '../../models/garment.dart';
import '../../widgets/garment_image.dart';
import '../../widgets/size_chart_sheet.dart';

class DressDetailsScreen extends ConsumerStatefulWidget {
  final Garment garment;
  const DressDetailsScreen({super.key, required this.garment});

  @override
  ConsumerState<DressDetailsScreen> createState() => _DressDetailsScreenState();
}

class _DressDetailsScreenState extends ConsumerState<DressDetailsScreen> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.garment.availableSizes.isNotEmpty) {
      // Pre-select 'L' if available, otherwise mid-range size
      if (widget.garment.availableSizes.contains('L')) {
        _selectedSize = 'L';
      } else {
        _selectedSize = widget.garment.availableSizes[
            (widget.garment.availableSizes.length / 2).floor()];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.garment;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              // Hero Image with Floating Controls
              SizedBox(
                height: 400,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GarmentImage(garment: d),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _circleIconButton(Icons.arrow_back, () => Navigator.of(context).pop()),
                            _circleIconButton(Icons.ios_share, () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sharing ${d.name}...')),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Garment Information
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (d.brand != null)
                        Text(
                          d.brand!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        d.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.displayPrice,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _detailLine('Dress silhouette:', d.silhouette ?? 'Wrap midi dress'),
                      _detailLine(
                        'Fabric stretch:',
                        d.stretch != null ? '${d.stretch!} stretch' : 'Low stretch',
                      ),
                      if (d.fabricMaterial != null && d.fabricMaterial!.isNotEmpty)
                        _detailLine('Fabric material:', d.fabricMaterial!),
                      const SizedBox(height: 20),

                      // Size Selector
                      const Text(
                        'Size',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: d.availableSizes.map((s) {
                          final isSelected = s == _selectedSize;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSize = s),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : const Color(0xFF222226),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white12,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // View Size Chart Link
                      Center(
                        child: InkWell(
                          onTap: () => SizeChartSheet.show(context, d),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View size chart',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13.5,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white38,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom "Check my fit" Action Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(selectedGarmentProvider.notifier).select(d);
                  Navigator.of(context).pop();
                  context.go('/fitting');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Check my fit',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black.withValues(alpha: 0.55),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
