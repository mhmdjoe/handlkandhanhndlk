import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/glassmorphic_container.dart';
import '../explore/attraction_detail_screen.dart';
import '../explore/destination_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onExploreTap;
  final VoidCallback onPlannerTap;

  const HomeScreen({
    super.key,
    required this.onExploreTap,
    required this.onPlannerTap,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = appProvider.isArabic;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar Hero Header with Apple HIG Material Glassmorphism Overlay
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.nileTeal,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const SafeNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=1000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.nileTeal.withValues(alpha: 0.9),
                          AppColors.nileTeal.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('appName'),
                          style: const TextStyle(
                            color: AppColors.papyrusGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.translate('tagline'),
                          style: const TextStyle(
                            color: AppColors.desertSand,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: () {
                  appProvider.setLocale(
                    isAr ? const Locale('en') : const Locale('ar'),
                  );
                },
              ),
            ],
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dual Core Promise Glassmorphic Banner Cards
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onExploreTap,
                          child: GlassContainer(
                            blurSigma: 12,
                            tintColor: AppColors.nileTeal.withValues(alpha: 0.88),
                            borderColor: AppColors.papyrusGold.withValues(alpha: 0.35),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.search_outlined, color: AppColors.papyrusGold, size: 28),
                                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.translate('hndlkTitle'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr ? 'هنوريك كل مكان' : 'Discover Places',
                                  style: const TextStyle(color: AppColors.desertSand, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: onPlannerTap,
                          child: GlassContainer(
                            blurSigma: 12,
                            tintColor: AppColors.terracotta.withValues(alpha: 0.92),
                            borderColor: Colors.white.withValues(alpha: 0.35),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.translate('hnhndlkTitle'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr ? 'هنخططلك الرحلة' : 'Smart AI Planner',
                                  style: const TextStyle(color: AppColors.desertSand, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Top Destinations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          loc.translate('topDestinations'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: onExploreTap,
                        child: Text(loc.translate('viewAll')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: TourismDatabase.destinations.length,
                      itemBuilder: (context, index) {
                        final dest = TourismDatabase.destinations[index];
                        return _buildDestinationCard(context, dest, isAr);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories Section
                  Text(
                    loc.translate('exploreCategory'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryType.values.take(6).map((cat) {
                      return ChoiceChip(
                        label: Text(isAr ? cat.nameAr : cat.nameEn),
                        selected: appProvider.selectedCategory == cat,
                        onSelected: (sel) {
                          appProvider.setCategoryFilter(sel ? cat : null);
                          onExploreTap();
                        },
                        selectedColor: AppColors.nileTeal,
                        labelStyle: TextStyle(
                          color: appProvider.selectedCategory == cat ? Colors.white : AppColors.charcoal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Must-Try Experiences
                  Text(
                    loc.translate('popularExperiences'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                  ),
                  const SizedBox(height: 12),

                  ...TourismDatabase.attractions.take(3).map((attraction) {
                    return _buildAttractionCard(context, attraction, appProvider, loc, isAr);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, Destination dest, bool isAr) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DestinationDetailScreen(destination: dest),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'dest_${dest.id}',
                child: SafeNetworkImage(
                  imageUrl: dest.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? dest.nameAr : dest.nameEn,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isAr ? dest.governorateAr : dest.governorateEn,
                      style: const TextStyle(color: AppColors.papyrusGold, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttractionCard(BuildContext context, Attraction a, AppProvider provider, AppLocalizations loc, bool isAr) {
    final isFav = provider.isFavorite(a.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttractionDetailScreen(attraction: a),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'attraction_${a.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SafeNetworkImage(
                    imageUrl: a.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isAr ? a.nameAr : a.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => provider.toggleFavorite(a.id),
                        ),
                      ],
                    ),
                    Text(
                      isAr ? a.category.nameAr : a.category.nameEn,
                      style: const TextStyle(color: AppColors.terracotta, fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.verifiedGreen, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            loc.translate('verifiedSource'),
                            style: const TextStyle(color: AppColors.verifiedGreen, fontSize: 11, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.formatPrice(a.priceEgp, a.priceUsd),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.nileTeal, fontSize: 14),
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
  }
}
