import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/add_to_trip_modal.dart';
import 'attraction_detail_screen.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAr = provider.isArabic;

    final destAttractions = TourismDatabase.attractions
        .where((a) => a.destinationId == destination.id)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primaryPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isAr ? destination.nameAr : destination.nameEn,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.3),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'dest_${destination.id}',
                    child: SafeNetworkImage(
                      imageUrl: destination.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.80),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredEntranceItem(
                    index: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? destination.governorateAr : destination.governorateEn,
                          style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? destination.descriptionAr : destination.descriptionEn,
                          style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.darkGray),
                        ),
                        const SizedBox(height: 20),

                        // Key Highlights Badges
                        if (destination.highlights.isNotEmpty) ...[
                          Text(
                            isAr ? 'أبرز معالم الوجهة:' : 'Key Highlights:',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryPurple),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: destination.highlights.map((h) {
                              return Chip(
                                label: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkGray)),
                                backgroundColor: AppColors.lightPurple,
                                side: const BorderSide(color: AppColors.borderLight),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),

                  StaggeredEntranceItem(
                    index: 1,
                    child: Text(
                      isAr ? 'أهم الأماكن الموثقة (${destAttractions.length})' : 'Top Verified Places (${destAttractions.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                    ),
                  ),
                  const SizedBox(height: 12),

                  for (int i = 0; i < destAttractions.length; i++)
                    _buildAttractionCardItem(context, provider, destAttractions[i], i, isAr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCardItem(
    BuildContext context,
    AppProvider provider,
    Attraction a,
    int index,
    bool isAr,
  ) {
    final isFav = provider.isFavorite(a.id);

    return StaggeredEntranceItem(
      index: 2 + index,
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
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SafeNetworkImage(
                    imageUrl: a.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? a.nameAr : a.nameEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr ? a.category.nameAr : a.category.nameEn,
                        style: const TextStyle(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.formatPrice(a.priceEgp, a.priceUsd),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    AppleTouchable(
                      pressedScale: 0.85,
                      onTap: () => provider.toggleFavorite(a.id),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : AppColors.mediumGray,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppleTouchable(
                      pressedScale: 0.85,
                      onTap: () => AddToTripModal.show(context, a),
                      child: const Icon(Icons.add_circle_rounded, color: AppColors.primaryOrange, size: 26),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
