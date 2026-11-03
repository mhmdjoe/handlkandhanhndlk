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

  @override
  void initState() {
    super.initState();
    _selectedAttraction = TourismDatabase.attractions.first;
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
      ),
      body: Stack(
        children: [
          // Simulated Interactive Map Canvas with LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: const Color(0xFFE5E9EC),
                child: Stack(
                  children: [
                    const SafeNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=1000&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Container(color: AppColors.primaryPurple.withValues(alpha: 0.65)),

                    // Pins Overlay for displayed attractions
                    ...displayedAttractions.map((a) {
                      final isSel = _selectedAttraction?.id == a.id;
                      final leftPos = ((a.lng - 25) / 11 * constraints.maxWidth).clamp(20.0, constraints.maxWidth - 50.0);
                      final topPos = ((32 - a.lat) / 10 * constraints.maxHeight).clamp(60.0, constraints.maxHeight - 180.0);

                      return Positioned(
                        left: leftPos,
                        top: topPos,
                        child: AppleTouchable(
                          pressedScale: 0.85,
                          onTap: () => setState(() => _selectedAttraction = a),
                          child: AnimatedContainer(
                            duration: AppDurations.fast,
                            curve: AppCurves.springSnappy,
                            padding: EdgeInsets.all(isSel ? 10 : 6),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primaryOrange : AppColors.primaryPurple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: isSel ? AppColors.primaryOrange.withValues(alpha: 0.5) : Colors.black26,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(a.category),
                              color: Colors.white,
                              size: isSel ? 22 : 16,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Top Category Filter Chips Bar
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
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
                        isAr ? 'الكل (${TourismDatabase.attractions.length})' : 'All (${TourismDatabase.attractions.length})',
                        style: TextStyle(
                          color: _selectedCategoryFilter == null ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      selected: _selectedCategoryFilter == null,
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: Colors.white.withValues(alpha: 0.90),
                      checkmarkColor: Colors.white,
                    ),
                  ),
                  ...CategoryType.values.map((cat) {
                    final isSel = _selectedCategoryFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
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
                          backgroundColor: Colors.white.withValues(alpha: 0.90),
                          checkmarkColor: Colors.white,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Preview Card for Selected Attraction
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
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SafeNetworkImage(
                            imageUrl: _selectedAttraction!.imageUrl,
                            width: 75,
                            height: 75,
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
                            child: Icon(Icons.add_circle_rounded, color: AppColors.primaryOrange, size: 30),
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
