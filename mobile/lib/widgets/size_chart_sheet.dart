import 'package:flutter/material.dart';
import '../models/garment.dart';

class SizeChartSheet extends StatelessWidget {
  final Garment garment;
  const SizeChartSheet({super.key, required this.garment});

  static Future<void> show(BuildContext context, Garment garment) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SizeChartSheet(garment: garment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawChart = garment.rawSizeChart ?? {};
    final sizes = ['S', 'M', 'L', 'XL'];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF242428),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Structural size chart',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.close, size: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.0),
                1: FlexColumnWidth(1.3),
                2: FlexColumnWidth(1.3),
                3: FlexColumnWidth(1.1),
              },
              children: [
                _headerRow(),
                ...sizes.map((s) {
                  final data = rawChart[s] as Map<String, dynamic>? ?? {};
                  final bust = data['bustRange'] ?? '${data["bustCm"] ?? "-"}';
                  final waist = data['waistRange'] ?? '${data["waistCm"] ?? "-"}';
                  final len = data['lengthCm'] != null ? '${data["lengthCm"]}' : '-';
                  return _dataRow(s, bust.toString(), waist.toString(), len.toString());
                }),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Recommendations are estimates, not guarantees.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow() {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.white70);
    return const TableRow(children: [
      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Size', style: style)),
      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Bust range', style: style)),
      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Waist range', style: style)),
      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Length cm', style: style)),
    ]);
  }

  TableRow _dataRow(String size, String bust, String waist, String length) {
    const style = TextStyle(fontSize: 12, color: Colors.white);
    return TableRow(children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Text(size, style: style)),
      Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Text(bust, style: style)),
      Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Text(waist, style: style)),
      Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Text(length, style: style)),
    ]);
  }
}
