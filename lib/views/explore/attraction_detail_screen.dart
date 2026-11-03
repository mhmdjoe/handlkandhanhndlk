import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/add_to_trip_modal.dart';

class AttractionDetailScreen extends StatelessWidget {
  final Attraction attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;
    final isFav = provider.isFavorite(attraction.id);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // Hero Image Header with Apple Translucent Backdrop
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryPurple,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'attraction_${attraction.id}',
                    child: SafeNetworkImage(
                      imageUrl: attraction.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.70),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AppleTouchable(
                pressedScale: 0.85,
                onTap: () => provider.toggleFavorite(attraction.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Official Verification Badge
                  StaggeredEntranceItem(
                    index: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.verifiedGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.verifiedGreen.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: AppColors.verifiedGreen, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            loc.translate('verifiedSource'),
                            style: const TextStyle(color: AppColors.verifiedGreen, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title & Meta
                  StaggeredEntranceItem(
                    index: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? attraction.nameAr : attraction.nameEn,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isAr ? attraction.governorateAr : attraction.governorateEn} • ${isAr ? attraction.category.nameAr : attraction.category.nameEn}',
                          style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Info Cards Grid
                  StaggeredEntranceItem(
                    index: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: Icons.confirmation_number_outlined,
                            label: loc.translate('entranceFee'),
                            value: provider.formatPrice(attraction.priceEgp, attraction.priceUsd),
                            isPrice: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.access_time_rounded,
                            label: loc.translate('openingHours'),
                            value: '${attraction.openingTime} - ${attraction.closingTime}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  StaggeredEntranceItem(
                    index: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: Icons.timer_outlined,
                            label: loc.translate('duration'),
                            value: '${attraction.estimatedDurationMinutes} mins',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.family_restroom_rounded,
                            label: loc.translate('familySuitability'),
                            value: attraction.isFamilyFriendly ? (isAr ? 'نعم' : 'Yes') : (isAr ? 'لا' : 'No'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  StaggeredEntranceItem(
                    index: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'عن المكان' : 'About Attraction',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? attraction.descriptionAr : attraction.descriptionEn,
                          style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.darkGray),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Practical Tips
                  if (attraction.tipsEn.isNotEmpty) ...[
                    StaggeredEntranceItem(
                      index: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'نصائح مهمة للزيارة' : 'Visiting Tips',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.lightPurple,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.papyrusGold),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isAr ? attraction.tipsAr : attraction.tipsEn,
                                    style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Verified Source Reference
                  StaggeredEntranceItem(
                    index: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مصدر توثيق البيانات' : 'Data Verification Source',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.mediumGray),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${attraction.verifiedSource} (${attraction.verificationDate})',
                          style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button: Add to Trip Popup Modal
                  StaggeredEntranceItem(
                    index: 7,
                    child: AppleTouchable(
                      onTap: () => AddToTripModal.show(context, attraction),
                      child: ElevatedButton.icon(
                        onPressed: () => AddToTripModal.show(context, attraction),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: Text(loc.translate('addToTrip')),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String label, required String value, bool isPrice = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: isPrice ? AppColors.primaryOrange : AppColors.primaryPurple, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mediumGray, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isPrice ? AppColors.primaryOrange : AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
