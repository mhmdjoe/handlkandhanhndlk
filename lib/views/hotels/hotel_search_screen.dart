import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  String _selectedCity = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    final filteredHotels = _selectedCity == 'All'
        ? TourismDatabase.hotels
        : TourismDatabase.hotels.where((h) => h.cityEn.contains(_selectedCity)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('hotelsTitle'))),
      body: Column(
        children: [
          // City Filter Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ChoiceChip(
                  label: Text(loc.translate('allGovernorates')),
                  selected: _selectedCity == 'All',
                  onSelected: (_) => setState(() => _selectedCity = 'All'),
                ),
                ...['Cairo', 'Alexandria', 'Aswan', 'Siwa'].map((city) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(city),
                      selected: _selectedCity == city,
                      onSelected: (_) => setState(() => _selectedCity = city),
                    ),
                  );
                }),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
              itemCount: filteredHotels.length,
              itemBuilder: (context, index) {
                final hotel = filteredHotels[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafeNetworkImage(
                        imageUrl: hotel.imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isAr ? hotel.nameAr : hotel.nameEn,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: AppColors.starYellow, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${hotel.guestRating}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              isAr ? hotel.cityAr : hotel.cityEn,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 12),

                            // Amenities
                            Wrap(
                              spacing: 6,
                              children: hotel.amenities.map((a) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.desertSand,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(a, style: const TextStyle(fontSize: 11)),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.formatPrice(hotel.pricePerNightEgp, hotel.pricePerNightUsd),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
                                    ),
                                    Text(
                                      loc.translate('perNight'),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isAr ? 'تم فتح خيارات حجز الفندق عبر الشريك المعتمد!' : 'Redirecting to hotel partner reservation...'),
                                        backgroundColor: AppColors.nileTeal,
                                      ),
                                    );
                                  },
                                  child: Text(loc.translate('bookNow')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
