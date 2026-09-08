import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/garment_state.dart';
import '../../models/garment.dart';
import '../../widgets/garment_image.dart';
import 'dress_details_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _selectedBrand = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _brands = ['All', 'Aurelia', 'Vero Moda', 'ZARA', 'H&M'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(remoteGarmentsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search dresses, styles...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : const Row(
                children: [
                  Text(
                    'Twinly',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Catalog',
                    style: TextStyle(
                      color: Colors.white38,
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
              color: Colors.white,
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
            onPressed: () => ref.invalidate(remoteGarmentsProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Brand Filter Chips Bar
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade400,
                  backgroundColor: const Color(0xFF1C1C20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? Colors.teal.shade400 : Colors.white10,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  onSelected: (_) {
                    setState(() {
                      _selectedBrand = brand;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

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
                    const Text(
                      'Unable to load the catalog.',
                      style: TextStyle(color: Colors.white70),
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
                  final matchesBrand = _selectedBrand == 'All' ||
                      (g.brand ?? '').toLowerCase() == _selectedBrand.toLowerCase();
                  final matchesSearch = _searchQuery.isEmpty ||
                      g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (g.brand ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (g.silhouette ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesBrand && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/empty_state.png',
                          width: 130,
                          height: 130,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.search_off, size: 60, color: Colors.white24),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No dresses found',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try searching for another brand or style.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.49,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final garment = filtered[index];
                    return _GarmentCard(
                      garment: garment,
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
  final VoidCallback onTap;
  final VoidCallback onTryOn;

  const _GarmentCard({
    required this.garment,
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
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
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
                      backgroundColor: Colors.black54,
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
                            color: Colors.black.withValues(alpha: 0.4),
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
                      style: const TextStyle(
                        color: Colors.white70,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        garment.displayPrice,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        garment.sizeRangeLabel,
                        style: const TextStyle(
                          color: Colors.white54,
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
