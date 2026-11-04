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
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // App Bar Hero Header with Apple Glassmorphism Overlay
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryPurple,
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
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.35),
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
                        Image.asset(
                          'assets/images/handelak_logo.png',
                          height: 60,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          loc.translate('tagline'),
                          style: const TextStyle(
                            color: AppColors.lightPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AppleTouchable(
                onTap: () {
                  appProvider.setLocale(
                    isAr ? const Locale('en') : const Locale('ar'),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.language, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Dual Promise Action Cards (Discover Egypt & Smart AI Planner)
                  StaggeredEntranceItem(
                    index: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: AppleTouchable(
                            onTap: onExploreTap,
                            pressedScale: 0.95,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.20),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    loc.translate('hndlkTitle'),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr ? 'هنوريك كل مكان في مصر' : 'Discover All Places',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500),
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
                          child: AppleTouchable(
                            onTap: onPlannerTap,
                            pressedScale: 0.95,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange.withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.20),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    loc.translate('hnhndlkTitle'),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr ? 'هنخطط ونظبطلك الرحلة' : 'Smart AI Planner',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500),
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
                  ),
                  const SizedBox(height: 24),

                  // Top Destinations Section
                  StaggeredEntranceItem(
                    index: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            loc.translate('topDestinations'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
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
                  ),
                  const SizedBox(height: 8),

                  StaggeredEntranceItem(
                    index: 2,
                    child: SizedBox(
                      height: 195,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: TourismDatabase.destinations.length,
                        itemBuilder: (context, index) {
                          final dest = TourismDatabase.destinations[index];
                          return _buildDestinationCard(context, dest, isAr);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories Section
                  StaggeredEntranceItem(
                    index: 3,
                    child: Text(
                      loc.translate('exploreCategory'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                    ),
                  ),
                  const SizedBox(height: 12),

                  StaggeredEntranceItem(
                    index: 4,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CategoryType.values.take(6).map((cat) {
                        final isSel = appProvider.selectedCategory == cat;
                        return AppleTouchable(
                          pressedScale: 0.92,
                          onTap: () {
                            appProvider.setCategoryFilter(isSel ? null : cat);
                            onExploreTap();
                          },
                          child: ChoiceChip(
                            label: Text(isAr ? cat.nameAr : cat.nameEn),
                            selected: isSel,
                            onSelected: null, // Tap handled by AppleTouchable
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
                  ),
                  const SizedBox(height: 24),

                  // Must-Try Experiences
                  StaggeredEntranceItem(
                    index: 5,
                    child: Text(
                      loc.translate('popularExperiences'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(TourismDatabase.attractions.take(6).length, (index) {
                    final attraction = TourismDatabase.attractions[index];
                    return StaggeredEntranceItem(
                      index: 6 + index,
                      child: _buildAttractionCard(context, attraction, appProvider, loc, isAr),
                    );
                  }),
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

  Widget _buildDestinationCard(BuildContext context, Destination dest, bool isAr) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      child: AppleTouchable(
        pressedScale: 0.95,
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            AppCupertinoPageRoute(
              page: DestinationDetailScreen(destination: dest),
            ),
          );
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                    colors: [Colors.black.withValues(alpha: 0.82), Colors.transparent],
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
                      style: const TextStyle(color: AppColors.papyrusGold, fontSize: 11, fontWeight: FontWeight.w600),
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

    return AppleTouchable(
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
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'attraction_${a.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppleTouchable(
                          pressedScale: 0.85,
                          onTap: () => provider.toggleFavorite(a.id),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : AppColors.mediumGray,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isAr ? a.category.nameAr : a.category.nameEn,
                      style: const TextStyle(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.w600),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange, fontSize: 15),
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
