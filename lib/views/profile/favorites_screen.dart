import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../explore/attraction_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    final favAttractions = TourismDatabase.attractions
        .where((a) => provider.isFavorite(a.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('favorites'))),
      body: favAttractions.isEmpty
          ? Center(
              child: Text(
                isAr ? 'لم تقم بحفظ أي أماكن في المفضلة بعد' : 'No saved favorites yet.',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
              itemCount: favAttractions.length,
              itemBuilder: (context, index) {
                final a = favAttractions[index];
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
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => provider.toggleFavorite(a.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AttractionDetailScreen(attraction: a)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
