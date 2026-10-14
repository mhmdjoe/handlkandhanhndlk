import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
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
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
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
                          Colors.black.withValues(alpha: 0.60),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.60),
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
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white),
                onPressed: () => provider.toggleFavorite(attraction.id),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.verifiedGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    isAr ? attraction.nameAr : attraction.nameEn,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isAr ? attraction.governorateAr : attraction.governorateEn} • ${isAr ? attraction.category.nameAr : attraction.category.nameEn}',
                    style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Key Info Cards Grid
                  Row(
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
                          icon: Icons.access_time,
                          label: loc.translate('openingHours'),
                          value: '${attraction.openingTime} - ${attraction.closingTime}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                          icon: Icons.family_restroom,
                          label: loc.translate('familySuitability'),
                          value: attraction.isFamilyFriendly ? (isAr ? 'نعم' : 'Yes') : (isAr ? 'لا' : 'No'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    isAr ? 'عن المكان' : 'About Attraction',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? attraction.descriptionAr : attraction.descriptionEn,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 24),

                  // Practical Tips
                  if (attraction.tipsEn.isNotEmpty) ...[
                    Text(
                      isAr ? 'نصائح مهمة للزيارة' : 'Visiting Tips',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.desertSand,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.papyrusGold),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isAr ? attraction.tipsAr : attraction.tipsEn,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Verified Source Reference
                  Text(
                    isAr ? 'مصدر توثيق البيانات' : 'Data Verification Source',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attraction.verifiedSource} (${attraction.verificationDate})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),

                  // Action Button: Add to Trip Popup Modal
                  ElevatedButton.icon(
                    onPressed: () => AddToTripModal.show(context, attraction),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(loc.translate('addToTrip')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AppColors.nileTeal,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: isPrice ? AppColors.primaryOrange : AppColors.primaryPurple, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mediumGray)),
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
