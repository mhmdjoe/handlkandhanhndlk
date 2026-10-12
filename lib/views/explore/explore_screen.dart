import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, appProvider, loc, isAr),
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
                prefixIcon: const Icon(Icons.search, color: AppColors.nileTeal),
                suffixIcon: appProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => appProvider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),

          // Horizontal Governorates Filter Chips with Crisp White Selected Text
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: Text(
                    loc.translate('allGovernorates'),
                    style: TextStyle(
                      color: appProvider.selectedDestinationId == 'all' ? Colors.white : AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  selected: appProvider.selectedDestinationId == 'all',
                  selectedColor: AppColors.nileTeal,
                  backgroundColor: AppColors.desertSand,
                  checkmarkColor: Colors.white,
                  onSelected: (sel) => appProvider.setDestinationFilter('all'),
                ),
                ...TourismDatabase.destinations.map((d) {
                  final isSel = appProvider.selectedDestinationId == d.id;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(
                        isAr ? d.nameAr : d.nameEn,
                        style: TextStyle(
                          color: isSel ? Colors.white : AppColors.charcoal,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.nileTeal,
                      backgroundColor: AppColors.desertSand,
                      checkmarkColor: Colors.white,
                      onSelected: (sel) => appProvider.setDestinationFilter(d.id),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (appProvider.selectedCategory != null ||
                    appProvider.selectedDestinationId != 'all' ||
                    appProvider.filterFamilyOnly ||
                    appProvider.filterAccessibleOnly)
                  TextButton(
                    onPressed: () => appProvider.resetFilters(),
                    child: const Text('Reset Filters'),
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
                        const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          isAr ? 'لم نجد أماكن تطابق البحث' : 'No places found matching your filters.',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final a = filtered[index];
                      final isFav = appProvider.isFavorite(a.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AttractionDetailScreen(attraction: a),
                              ),
                            );
                          },
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
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? Colors.red : AppColors.textMuted,
                                        ),
                                        onPressed: () => appProvider.toggleFavorite(a.id),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.nileTeal.withValues(alpha: 0.9),
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
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle, color: AppColors.terracotta, size: 28),
                                          onPressed: () => AddToTripModal.show(context, a),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAr ? a.descriptionAr : a.descriptionEn,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Text('${a.openingTime} - ${a.closingTime}', style: const TextStyle(fontSize: 12)),
                                        const Spacer(),
                                        Text(
                                          appProvider.formatPrice(a.priceEgp, a.priceUsd),
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('filterTitle'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text(loc.translate('familySuitability')),
                    value: provider.filterFamilyOnly,
                    onChanged: (val) {
                      provider.setFamilyFilter(val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: Text(loc.translate('accessibility')),
                    value: provider.filterAccessibleOnly,
                    onChanged: (val) {
                      provider.setAccessibleFilter(val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Center(child: Text('Apply Filters')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
