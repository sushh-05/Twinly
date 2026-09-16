import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/garment_state.dart';
import '../../models/garment.dart';
import '../../widgets/garment_image.dart';
import '../../widgets/size_chart_sheet.dart';

class DressDetailsScreen extends StatefulWidget {
  final Garment garment;
  const DressDetailsScreen({super.key, required this.garment});

  @override
  State<DressDetailsScreen> createState() => _DressDetailsScreenState();
}

class _DressDetailsScreenState extends State<DressDetailsScreen> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.garment.availableSizes.isNotEmpty) {
      if (widget.garment.availableSizes.contains('L')) {
        _selectedSize = 'L';
      } else {
        _selectedSize = widget
            .garment
            .availableSizes[(widget.garment.availableSizes.length / 2).floor()];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.garment;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : const Color(0xFFF9FAFB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF4B5563);
    final sizeBoxBg = isDark ? const Color(0xFF222226) : Colors.white;
    final sizeBoxBorder = isDark ? Colors.white12 : Colors.grey.shade300;
    final buttonBg = isDark ? Colors.white : const Color(0xFF111827);
    final buttonText = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Hero Image with Floating Controls
              SizedBox(
                height: 410,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GarmentImage(garment: d),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _circleIconButton(
                              Icons.arrow_back,
                              () => Navigator.of(context).pop(),
                            ),
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
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        d.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.displayPrice,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _detailLine(
                        'Dress silhouette:',
                        d.silhouette ?? 'Wrap midi dress',
                        textSecondary,
                        textPrimary,
                      ),
                      _detailLine(
                        'Fabric stretch:',
                        d.stretch != null
                            ? '${d.stretch!} stretch'
                            : 'Low stretch',
                        textSecondary,
                        textPrimary,
                      ),
                      if (d.fabricMaterial != null &&
                          d.fabricMaterial!.isNotEmpty)
                        _detailLine(
                          'Fabric material:',
                          d.fabricMaterial!,
                          textSecondary,
                          textPrimary,
                        ),
                      const SizedBox(height: 20),

                      // Size Selector
                      Text(
                        'Size',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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
                                  color: isSelected
                                      ? (isDark ? Colors.white : Colors.black)
                                      : sizeBoxBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? Colors.white : Colors.black)
                                        : sizeBoxBorder,
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    if (!isDark && !isSelected)
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                  ],
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (isDark ? Colors.black : Colors.white)
                                        : textPrimary,
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View size chart',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 13.5,
                                    decoration: TextDecoration.underline,
                                    decorationColor: textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: textSecondary,
                                  size: 18,
                                ),
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
                  context.read<SelectedGarmentState>().select(d);
                  Navigator.of(context).pop();
                  context.go('/fitting');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: buttonText,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: Text(
                  'Check my fit',
                  style: TextStyle(
                    color: buttonText,
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

  Widget _detailLine(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: labelColor, fontSize: 13.5),
          children: [
            TextSpan(text: '$label '),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
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
