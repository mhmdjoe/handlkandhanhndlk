import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/add_to_trip_modal.dart';
import 'attraction_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = appProvider.isArabic;
    final filtered = appProvider.filteredAttractions;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('exploreEgypt')),
        actions: [
          AppleTouchable(
            onTap: () => _showFilterSheet(context, appProvider, loc, isAr),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Icon(Icons.filter_list_rounded, color: AppColors.primaryPurple, size: 24),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Quick Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => appProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: loc.translate('searchHint'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryPurple),
                suffixIcon: appProvider.searchQuery.isNotEmpty
                    ? AppleTouchable(
                        onTap: () => appProvider.setSearchQuery(''),
                        child: const Icon(Icons.clear_rounded, color: AppColors.mediumGray),
                      )
                    : null,
              ),
            ),
          ),

          // Horizontal Governorates Filter Chips
          SizedBox(
            height: 48,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                AppleTouchable(
                  pressedScale: 0.92,
                  onTap: () => appProvider.setDestinationFilter('all'),
                  child: ChoiceChip(
                    label: Text(
                      loc.translate('allGovernorates'),
                      style: TextStyle(
                        color: appProvider.selectedDestinationId == 'all' ? Colors.white : AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    selected: appProvider.selectedDestinationId == 'all',
                    onSelected: null,
                    selectedColor: AppColors.primaryOrange,
                    backgroundColor: AppColors.lightPurple,
                    checkmarkColor: Colors.white,
                  ),
                ),
                ...TourismDatabase.destinations.map((d) {
                  final isSel = appProvider.selectedDestinationId == d.id;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AppleTouchable(
                      pressedScale: 0.92,
                      onTap: () => appProvider.setDestinationFilter(d.id),
                      child: ChoiceChip(
                        label: Text(
                          isAr ? d.nameAr : d.nameEn,
                          style: TextStyle(
                            color: isSel ? Colors.white : AppColors.darkGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSel,
                        onSelected: null,
                        selectedColor: AppColors.primaryOrange,
                        backgroundColor: AppColors.lightPurple,
                        checkmarkColor: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Count & Clear Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${filtered.length} ${loc.translate('resultsFound')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mediumGray),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (appProvider.selectedCategory != null ||
                    appProvider.selectedDestinationId != 'all' ||
                    appProvider.filterFamilyOnly ||
                    appProvider.filterAccessibleOnly)
                  AppleTouchable(
                    onTap: () => appProvider.resetFilters(),
                    child: const Text('Reset Filters', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Attraction List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: AppColors.mediumGray),
                        const SizedBox(height: 12),
                        Text(
                          isAr ? 'لم نجد أماكن تطابق البحث' : 'No places found matching your filters.',
                          style: const TextStyle(color: AppColors.mediumGray, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final a = filtered[index];
                      final isFav = appProvider.isFavorite(a.id);

                      return StaggeredEntranceItem(
                        index: index,
                        child: AppleTouchable(
                          pressedScale: 0.97,
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              AppCupertinoPageRoute(
                                page: AttractionDetailScreen(attraction: a),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Hero(
                                      tag: 'attraction_${a.id}',
                                      child: SafeNetworkImage(
                                        imageUrl: a.imageUrl,
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: AppleTouchable(
                                        pressedScale: 0.85,
                                        onTap: () => appProvider.toggleFavorite(a.id),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: isFav ? Colors.red : AppColors.mediumGray,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryOrange.withValues(alpha: 0.95),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isAr ? a.category.nameAr : a.category.nameEn,
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              isAr ? a.nameAr : a.nameEn,
                                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkGray, letterSpacing: -0.2),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          AppleTouchable(
                                            pressedScale: 0.85,
                                            onTap: () => AddToTripModal.show(context, a),
                                            child: const Icon(Icons.add_circle_rounded, color: AppColors.primaryOrange, size: 28),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isAr ? a.descriptionAr : a.descriptionEn,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.mediumGray),
                                          const SizedBox(width: 4),
                                          Text('${a.openingTime} - ${a.closingTime}', style: const TextStyle(fontSize: 12, color: AppColors.darkGray, fontWeight: FontWeight.w500)),
                                          const Spacer(),
                                          Text(
                                            appProvider.formatPrice(a.priceEgp, a.priceUsd),
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AppProvider provider, AppLocalizations loc, bool isAr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('filterTitle'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector Chips
                  Text(
                    loc.translate('exploreCategory'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryType.values.map((cat) {
                      final isSel = provider.selectedCategory == cat;
                      return AppleTouchable(
                        pressedScale: 0.92,
                        onTap: () {
                          provider.setCategoryFilter(isSel ? null : cat);
                          setState(() {});
                        },
                        child: ChoiceChip(
                          label: Text(isAr ? cat.nameAr : cat.nameEn),
                          selected: isSel,
                          onSelected: null,
                          selectedColor: AppColors.primaryOrange,
                          backgroundColor: AppColors.lightPurple,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.darkGray,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text(loc.translate('familySuitability'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    value: provider.filterFamilyOnly,
                    activeThumbColor: AppColors.primaryOrange,
                    onChanged: (val) {
                      provider.setFamilyFilter(val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: Text(loc.translate('accessibility'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    value: provider.filterAccessibleOnly,
                    activeThumbColor: AppColors.primaryOrange,
                    onChanged: (val) {
                      provider.setAccessibleFilter(val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  AppleTouchable(
                    onTap: () => Navigator.pop(context),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primaryPurple,
                      ),
                      child: const Center(child: Text('Apply Filters')),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
