import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/garment_state.dart';
import '../../core/providers/theme_state.dart';
import '../../models/garment.dart';
import '../../widgets/garment_image.dart';
import 'dress_details_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _selectedCategory = 'All Dresses';
  String _selectedBrand = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All Dresses',
    'Wrap Midi',
    'A-Line',
    'Party & Satin',
    'Floral',
    'Casual Poplin',
  ];

  final List<String> _brands = ['All', 'Aurelia', 'Vero Moda', 'ZARA', 'H&M'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesCategory(Garment g, String cat) {
    if (cat == 'All Dresses') return true;
    final sil = (g.silhouette ?? '').toLowerCase();
    final name = g.name.toLowerCase();
    final desc = (g.description ?? '').toLowerCase();
    final mat = (g.fabricMaterial ?? '').toLowerCase();

    switch (cat) {
      case 'Wrap Midi':
        return sil.contains('wrap') || name.contains('wrap');
      case 'A-Line':
        return sil.contains('a-line') || name.contains('a-line');
      case 'Party & Satin':
        return mat.contains('satin') || name.contains('satin') || name.contains('party');
      case 'Floral':
        return name.contains('floral') || desc.contains('floral');
      case 'Casual Poplin':
        return mat.contains('poplin') || mat.contains('cotton') || name.contains('poplin');
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(remoteGarmentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : const Color(0xFFF7F8FA);
    final cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final chipUnselectedBg = isDark ? const Color(0xFF1C1C20) : const Color(0xFFE5E7EB);
    final chipUnselectedText = isDark ? Colors.white70 : const Color(0xFF374151);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search dresses, styles, fabrics...',
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : Row(
                children: [
                  Text(
                    'Twinly',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Catalog',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: textPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          // Theme Toggle Button (Dark / Light mode)
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? Colors.amber : Colors.indigo.shade700,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: textSecondary, size: 20),
            onPressed: () => ref.invalidate(remoteGarmentsProvider),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter Tabs
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : chipUnselectedText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade700,
                  backgroundColor: chipUnselectedBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isSelected ? Colors.teal.shade700 : Colors.transparent,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Brand Filter Chips Bar
          SizedBox(
            height: 34,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _brands.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final brand = _brands[index];
                final isSelected = _selectedBrand == brand;
                return ChoiceChip(
                  avatar: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : null,
                  label: Text(
                    brand,
                    style: TextStyle(
                      color: isSelected ? Colors.black : chipUnselectedText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 11.5,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade300,
                  backgroundColor: chipUnselectedBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.teal.shade300 : Colors.transparent,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onSelected: (_) {
                    setState(() {
                      _selectedBrand = brand;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Garments Grid
          Expanded(
            child: catalog.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Unable to load the catalog.',
                      style: TextStyle(color: textSecondary),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(remoteGarmentsProvider),
                      child: const Text('Retry', style: TextStyle(color: Colors.teal)),
                    ),
                  ],
                ),
              ),
              data: (catalogState) {
                final filtered = catalogState.garments.where((g) {
                  final matchesCat = _matchesCategory(g, _selectedCategory);
                  final matchesBrand = _selectedBrand == 'All' ||
                      (g.brand ?? '').toLowerCase() == _selectedBrand.toLowerCase();
                  final matchesSearch = _searchQuery.isEmpty ||
                      g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (g.brand ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (g.silhouette ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (g.fabricMaterial ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesCat && matchesBrand && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/empty_state.png',
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.search_off, size: 60, color: textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No dresses found',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try choosing another category, brand, or search.',
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.49,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final garment = filtered[index];
                    return _GarmentCard(
                      garment: garment,
                      cardBgColor: cardBgColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DressDetailsScreen(garment: garment),
                          ),
                        );
                      },
                      onTryOn: () {
                        ref.read(selectedGarmentProvider.notifier).select(garment);
                        context.go('/fitting');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GarmentCard extends StatefulWidget {
  final Garment garment;
  final Color cardBgColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onTryOn;

  const _GarmentCard({
    required this.garment,
    required this.cardBgColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
    required this.onTryOn,
  });

  @override
  State<_GarmentCard> createState() => _GarmentCardState();
}

class _GarmentCardState extends State<_GarmentCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final garment = widget.garment;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.78,
                  child: GarmentImage(garment: garment),
                ),
                // Top Right Heart Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black.withValues(alpha: 0.45),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color: _isFavorite ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Bottom Left Verified Size Chart Pill
                if (garment.verifiedSizeChart)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade700,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 11, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Verified size chart',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Garment Content Info
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (garment.brand != null)
                    Text(
                      garment.brand!,
                      style: TextStyle(
                        color: widget.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  const SizedBox(height: 1),
                  Text(
                    garment.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        garment.displayPrice,
                        style: TextStyle(
                          color: widget.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        garment.sizeRangeLabel,
                        style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Individual "Try on" Button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: widget.onTryOn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade400,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Try on',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
