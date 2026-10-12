import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../planner/itinerary_detail_screen.dart';
import '../planner/trip_wizard_screen.dart';
import '../map/interactive_map_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  String _selectedStatusFilter = 'All'; // 'All', 'Active Journey', 'Confirmed'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;
    final allTrips = provider.userTrips;

    final filteredTrips = _selectedStatusFilter == 'All'
        ? allTrips
        : allTrips.where((t) => t.status == _selectedStatusFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('myTripsTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.nileTeal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TripWizardScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter Chips
          if (allTrips.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  ChoiceChip(
                    label: Text(isAr ? 'جميع الرحلات (${allTrips.length})' : 'All Trips (${allTrips.length})'),
                    selected: _selectedStatusFilter == 'All',
                    onSelected: (_) => setState(() => _selectedStatusFilter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(isAr ? 'رحلات قائمة' : 'Active Journeys'),
                    selected: _selectedStatusFilter == 'Active Journey',
                    onSelected: (_) => setState(() => _selectedStatusFilter = 'Active Journey'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(loc.translate('statusConfirmed')),
                    selected: _selectedStatusFilter == 'Confirmed',
                    onSelected: (_) => setState(() => _selectedStatusFilter = 'Confirmed'),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredTrips.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.card_travel, size: 72, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('noTripsYet'),
                            style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TripWizardScreen()),
                              );
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(loc.translate('startPlanning')),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 110),
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      final destination = TourismDatabase.destinations.firstWhere(
                        (d) => d.id == trip.destinationId,
                        orElse: () => TourismDatabase.destinations.first,
                      );

                      // Group trip items by day
                      final maxDay = trip.items.fold<int>(1, (max, item) => item.dayNumber > max ? item.dayNumber : max);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Whole Trip Banner Image
                            Stack(
                              children: [
                                SafeNetworkImage(
                                  imageUrl: destination.imageUrl,
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  height: 130,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          trip.title,
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.papyrusGold,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isAr ? 'رحلة قائمة' : 'Active Journey',
                                          style: const TextStyle(color: AppColors.nileTeal, fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Whole Trip Details Body
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Metrics Bar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _metricCell(
                                        icon: Icons.map_outlined,
                                        label: isAr ? 'الوجهة' : 'Destination',
                                        value: isAr ? destination.nameAr : destination.nameEn,
                                      ),
                                      _metricCell(
                                        icon: Icons.calendar_today_rounded,
                                        label: isAr ? 'مدة الرحلة' : 'Duration',
                                        value: '$maxDay ${isAr ? 'أيام' : 'Days'}',
                                      ),
                                      _metricCell(
                                        icon: Icons.people_outline_rounded,
                                        label: isAr ? 'المسافرون' : 'Travelers',
                                        value: '${trip.travelerCount}',
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),

                                  // Whole Trip Itinerary Summary Preview
                                  Text(
                                    isAr ? 'ملخص جدول الرحلة الخاص بك' : 'Whole Trip Itinerary Summary',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.nileTeal),
                                  ),
                                  const SizedBox(height: 8),

                                  ...List.generate(maxDay > 3 ? 3 : maxDay, (dIdx) {
                                    final dayNum = dIdx + 1;
                                    final dayItems = trip.items.where((i) => i.dayNumber == dayNum).toList();
                                    final names = dayItems.map((i) {
                                      final a = TourismDatabase.attractions.firstWhere(
                                        (att) => att.id == i.attractionId,
                                        orElse: () => TourismDatabase.attractions.first,
                                      );
                                      return isAr ? a.nameAr : a.nameEn;
                                    }).join(' • ');

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.desertSand,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Day $dayNum',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.nileTeal),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              names.isEmpty ? (isAr ? 'يوم حر للاستجمام' : 'Free leisure day') : names,
                                              style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  if (maxDay > 3)
                                    Text(
                                      isAr ? '+ ${maxDay - 3} أيام إضافية في الرحلة' : '+ ${maxDay - 3} more days in whole trip...',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                                    ),

                                  const Divider(height: 24),

                                  // Action Bar: Whole Trip View & Map
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.translate('estimatedCost'),
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                          Text(
                                            provider.formatPrice(trip.totalCostEgp, trip.totalCostUsd),
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.terracotta),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),

                                      IconButton(
                                        icon: const Icon(Icons.map_outlined, color: AppColors.nileTeal),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const InteractiveMapScreen()),
                                          );
                                        },
                                      ),

                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ItineraryDetailScreen(trip: trip),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                        label: Text(isAr ? 'عرض الرحلة بالكامل' : 'View Whole Trip'),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.nileTeal),
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

  Widget _metricCell({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.nileTeal),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
