import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/add_to_trip_modal.dart';
import '../explore/attraction_detail_screen.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  Attraction? _selectedAttraction;
  CategoryType? _selectedCategoryFilter;

  // Real Map Center Coordinates (Default centered on Egypt)
  double _centerLat = 26.8206;
  double _centerLng = 30.8025;
  double _zoomLevel = 6.0; // Zoom level 5..14

  // Pan Offset
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _selectedAttraction = TourismDatabase.attractions.first;
  }

  void _centerOnDestination(Destination d) {
    setState(() {
      _centerLat = d.lat;
      _centerLng = d.lng;
      _zoomLevel = 10.0;
      _panOffset = Offset.zero;
      final match = TourismDatabase.attractions.firstWhere(
        (a) => a.destinationId == d.id,
        orElse: () => TourismDatabase.attractions.first,
      );
      _selectedAttraction = match;
    });
  }

  void _resetToFullEgyptView() {
    setState(() {
      _centerLat = 26.8206;
      _centerLng = 30.8025;
      _zoomLevel = 6.0;
      _panOffset = Offset.zero;
    });
  }

  // Convert (Lat, Lng) to Screen Coordinates relative to Center
  Offset _latLngToScreen(double lat, double lng, Size mapSize) {
    final scale = math.pow(2.0, _zoomLevel);

    // Mercator projection formula
    final x = (lng + 180.0) / 360.0 * 256.0 * scale;
    final sinLat = math.sin(lat * math.pi / 180.0);
    final y = (0.5 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi)) * 256.0 * scale;

    final centerX = (_centerLng + 180.0) / 360.0 * 256.0 * scale;
    final centerSinLat = math.sin(_centerLat * math.pi / 180.0);
    final centerY = (0.5 - math.log((1.0 + centerSinLat) / (1.0 - centerSinLat)) / (4.0 * math.pi)) * 256.0 * scale;

    final screenX = (mapSize.width / 2) + (x - centerX) + _panOffset.dx;
    final screenY = (mapSize.height / 2) + (y - centerY) + _panOffset.dy;

    return Offset(screenX, screenY);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    final displayedAttractions = _selectedCategoryFilter == null
        ? TourismDatabase.attractions
        : TourismDatabase.attractions.where((a) => a.category == _selectedCategoryFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('mapView')),
        actions: [
          AppleTouchable(
            onTap: _resetToFullEgyptView,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.my_location_rounded, color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Real OpenStreetMap Tile Grid Canvas
          LayoutBuilder(
            builder: (context, constraints) {
              final mapSize = Size(constraints.maxWidth, constraints.maxHeight);

              return GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _panOffset += details.delta;
                  });
                },
                child: Container(
                  color: const Color(0xFFE8ECEF),
                  child: Stack(
                    children: [
                      // Render Map Tiles
                      _buildTileGrid(mapSize),

                      // Interactive Place Pins Layer
                      ...displayedAttractions.map((a) {
                        final screenPos = _latLngToScreen(a.lat, a.lng, mapSize);

                        // Don't render pins if scrolled off screen
                        if (screenPos.dx < -40 ||
                            screenPos.dx > mapSize.width + 40 ||
                            screenPos.dy < -40 ||
                            screenPos.dy > mapSize.height + 40) {
                          return const SizedBox.shrink();
                        }

                        final isSel = _selectedAttraction?.id == a.id;

                        return Positioned(
                          left: screenPos.dx - (isSel ? 24 : 18),
                          top: screenPos.dy - (isSel ? 48 : 36),
                          child: AppleTouchable(
                            pressedScale: 0.85,
                            onTap: () => setState(() => _selectedAttraction = a),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: AppDurations.fast,
                                  curve: AppCurves.springSnappy,
                                  padding: EdgeInsets.all(isSel ? 8 : 6),
                                  decoration: BoxDecoration(
                                    color: isSel ? AppColors.primaryOrange : AppColors.primaryPurple,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSel
                                            ? AppColors.primaryOrange.withValues(alpha: 0.55)
                                            : Colors.black.withValues(alpha: 0.35),
                                        blurRadius: isSel ? 12 : 6,
                                        spreadRadius: isSel ? 2 : 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(a.category),
                                    color: Colors.white,
                                    size: isSel ? 22 : 16,
                                  ),
                                ),
                                Container(
                                  width: 3,
                                  height: 8,
                                  color: isSel ? AppColors.primaryOrange : AppColors.primaryPurple,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),

          // Top Header Filters: Destinations & Categories
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Destination Quick Switcher Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: TourismDatabase.destinations.map((d) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppleTouchable(
                          pressedScale: 0.92,
                          onTap: () => _centerOnDestination(d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_city_rounded, size: 14, color: AppColors.primaryPurple),
                                const SizedBox(width: 4),
                                Text(
                                  isAr ? d.nameAr : d.nameEn,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Category Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      AppleTouchable(
                        pressedScale: 0.92,
                        onTap: () => setState(() => _selectedCategoryFilter = null),
                        child: ChoiceChip(
                          label: Text(
                            isAr ? 'الكل' : 'All',
                            style: TextStyle(
                              color: _selectedCategoryFilter == null ? Colors.white : AppColors.darkGray,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          selected: _selectedCategoryFilter == null,
                          onSelected: null,
                          selectedColor: AppColors.primaryOrange,
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                          checkmarkColor: Colors.white,
                        ),
                      ),
                      ...CategoryType.values.map((cat) {
                        final isSel = _selectedCategoryFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: AppleTouchable(
                            pressedScale: 0.92,
                            onTap: () => setState(() => _selectedCategoryFilter = isSel ? null : cat),
                            child: ChoiceChip(
                              label: Text(
                                isAr ? cat.nameAr : cat.nameEn,
                                style: TextStyle(
                                  color: isSel ? Colors.white : AppColors.darkGray,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSel,
                              onSelected: null,
                              selectedColor: AppColors.primaryOrange,
                              backgroundColor: Colors.white.withValues(alpha: 0.92),
                              checkmarkColor: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Zoom Controls Floating Action Bar
          Positioned(
            top: 110,
            right: 16,
            child: Column(
              children: [
                AppleTouchable(
                  pressedScale: 0.85,
                  onTap: () => setState(() => _zoomLevel = (_zoomLevel + 1.0).clamp(5.0, 14.0)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.primaryPurple, size: 22),
                  ),
                ),
                const SizedBox(height: 8),
                AppleTouchable(
                  pressedScale: 0.85,
                  onTap: () => setState(() => _zoomLevel = (_zoomLevel - 1.0).clamp(5.0, 14.0)),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.remove_rounded, color: AppColors.primaryPurple, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Real Attraction Card Preview
          if (_selectedAttraction != null)
            Positioned(
              bottom: 95,
              left: 16,
              right: 16,
              child: AppleTouchable(
                pressedScale: 0.97,
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    AppCupertinoPageRoute(
                      page: AttractionDetailScreen(attraction: _selectedAttraction!),
                    ),
                  );
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SafeNetworkImage(
                            imageUrl: _selectedAttraction!.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isAr ? _selectedAttraction!.nameAr : _selectedAttraction!.nameEn,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${isAr ? _selectedAttraction!.governorateAr : _selectedAttraction!.governorateEn} • ${isAr ? _selectedAttraction!.category.nameAr : _selectedAttraction!.category.nameEn}',
                                style: const TextStyle(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.formatPrice(_selectedAttraction!.priceEgp, _selectedAttraction!.priceUsd),
                                style: const TextStyle(color: AppColors.darkGray, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        AppleTouchable(
                          pressedScale: 0.85,
                          onTap: () => AddToTripModal.show(context, _selectedAttraction!),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.add_circle_rounded, color: AppColors.primaryOrange, size: 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTileGrid(Size mapSize) {
    int zoom = _zoomLevel.floor().clamp(5, 14);
    double scale = math.pow(2.0, zoom).toDouble();

    double centerX = (_centerLng + 180.0) / 360.0 * 256.0 * scale;
    double centerSinLat = math.sin(_centerLat * math.pi / 180.0);
    double centerY = (0.5 - math.log((1.0 + centerSinLat) / (1.0 - centerSinLat)) / (4.0 * math.pi)) * 256.0 * scale;

    int centerTileX = (centerX / 256.0).floor();
    int centerTileY = (centerY / 256.0).floor();

    List<Widget> tiles = [];

    // Render a 4x4 tile grid centered around map location
    for (int dx = -2; dx <= 2; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        int tileX = centerTileX + dx;
        int tileY = centerTileY + dy;

        double tileLeft = (mapSize.width / 2) + (tileX * 256.0 - centerX) + _panOffset.dx;
        double tileTop = (mapSize.height / 2) + (tileY * 256.0 - centerY) + _panOffset.dy;

        // OpenStreetMap raster tiles
        final tileUrl = 'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';

        tiles.add(
          Positioned(
            left: tileLeft,
            top: tileTop,
            width: 256,
            height: 256,
            child: SafeNetworkImage(
              imageUrl: tileUrl,
              width: 256,
              height: 256,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return Stack(children: tiles);
  }

  IconData _getCategoryIcon(CategoryType cat) {
    switch (cat) {
      case CategoryType.archaeology: return Icons.account_balance_rounded;
      case CategoryType.museum: return Icons.museum_rounded;
      case CategoryType.beach: return Icons.beach_access_rounded;
      case CategoryType.diving: return Icons.scuba_diving_rounded;
      case CategoryType.safari: return Icons.landscape_rounded;
      case CategoryType.market: return Icons.shopping_bag_rounded;
      case CategoryType.oasis: return Icons.pool_rounded;
      case CategoryType.religious: return Icons.church_rounded;
      case CategoryType.nature: return Icons.nature_people_rounded;
      case CategoryType.family: return Icons.family_restroom_rounded;
      default: return Icons.place_rounded;
    }
  }
}
