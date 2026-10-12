import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../explore/attraction_detail_screen.dart';

class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  Attraction? _selectedAttraction;

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

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('mapView'))),
      body: Stack(
        children: [
          // Simulated Interactive Visual Map Canvas with LayoutBuilder for responsive projection
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: const Color(0xFFE5E9EC),
                child: Stack(
                  children: [
                    // Map Background Graphic
                    const SafeNetworkImage(
                      imageUrl: 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=1000&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Container(color: AppColors.nileTeal.withValues(alpha: 0.65)),

                    // Pins Overlay
                    ...TourismDatabase.attractions.map((a) {
                      final isSel = _selectedAttraction?.id == a.id;
                      final leftPos = ((a.lng - 25) / 10 * constraints.maxWidth).clamp(20.0, constraints.maxWidth - 50.0);
                      final topPos = ((32 - a.lat) / 8 * constraints.maxHeight).clamp(20.0, constraints.maxHeight - 160.0);

                      return Positioned(
                        left: leftPos,
                        top: topPos,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAttraction = a),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(isSel ? 10 : 6),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.terracotta : AppColors.nileTeal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
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

          // Bottom Preview Card for selected attraction
          if (_selectedAttraction != null)
            Positioned(
              bottom: 95, // Above floating bottom nav bar
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SafeNetworkImage(
                        imageUrl: _selectedAttraction!.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isAr ? _selectedAttraction!.nameAr : _selectedAttraction!.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isAr ? _selectedAttraction!.governorateAr : _selectedAttraction!.governorateEn,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.formatPrice(_selectedAttraction!.priceEgp, _selectedAttraction!.priceUsd),
                              style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: AppColors.nileTeal),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttractionDetailScreen(attraction: _selectedAttraction!),
                            ),
                          );
                        },
                      ),
                    ],
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
      case CategoryType.archaeology: return Icons.account_balance;
      case CategoryType.museum: return Icons.museum;
      case CategoryType.beach: return Icons.beach_access;
      case CategoryType.diving: return Icons.scuba_diving;
      case CategoryType.safari: return Icons.landscape;
      case CategoryType.market: return Icons.shopping_bag;
      case CategoryType.oasis: return Icons.pool;
      default: return Icons.place;
    }
  }
}
