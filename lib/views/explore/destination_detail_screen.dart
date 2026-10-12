import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
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
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isAr ? destination.nameAr : destination.nameEn,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          Colors.black.withValues(alpha: 0.70),
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
                  Text(
                    isAr ? destination.governorateAr : destination.governorateEn,
                    style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? destination.descriptionAr : destination.descriptionEn,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    isAr ? 'أهم الأماكن السياحية في هذه الوجهة' : 'Top Attractions in ${destination.nameEn}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                  ),
                  const SizedBox(height: 12),

                  ...destAttractions.map((a) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: SafeNetworkImage(
                          imageUrl: a.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(isAr ? a.nameAr : a.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(provider.formatPrice(a.priceEgp, a.priceUsd)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttractionDetailScreen(attraction: a),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
