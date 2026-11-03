import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
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
  String _selectedStatusFilter = 'All';

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
          AppleTouchable(
            onTap: () {
              Navigator.push(
                context,
                AppCupertinoPageRoute(page: const TripWizardScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryOrange, size: 28),
            ),
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
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedStatusFilter = 'All'),
                    child: ChoiceChip(
                      label: Text(
                        isAr ? 'جميع الرحلات (${allTrips.length})' : 'All Trips (${allTrips.length})',
                        style: TextStyle(
                          color: _selectedStatusFilter == 'All' ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: _selectedStatusFilter == 'All',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedStatusFilter = 'Active Journey'),
                    child: ChoiceChip(
                      label: Text(
                        isAr ? 'رحلات قائمة' : 'Active Journeys',
                        style: TextStyle(
                          color: _selectedStatusFilter == 'Active Journey' ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: _selectedStatusFilter == 'Active Journey',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedStatusFilter = 'Confirmed'),
                    child: ChoiceChip(
                      label: Text(
                        loc.translate('statusConfirmed'),
                        style: TextStyle(
                          color: _selectedStatusFilter == 'Confirmed' ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: _selectedStatusFilter == 'Confirmed',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                    ),
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
                          const Icon(Icons.card_travel_rounded, size: 64, color: AppColors.mediumGray),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('noTrips'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate('noTripsSub'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          AppleTouchable(
                            onTap: () {
                              Navigator.push(
                                context,
                                AppCupertinoPageRoute(page: const TripWizardScreen()),
                              );
                            },
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  AppCupertinoPageRoute(page: const TripWizardScreen()),
                                );
                              },
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: Text(loc.translate('createFirstTrip')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 110),
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      final dest = TourismDatabase.destinations.firstWhere(
                        (d) => d.id == trip.destinationId,
                        orElse: () => TourismDatabase.destinations.first,
                      );

                      return StaggeredEntranceItem(
                        index: index,
                        child: AppleTouchable(
                          pressedScale: 0.97,
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              AppCupertinoPageRoute(
                                page: ItineraryDetailScreen(trip: trip),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    SafeNetworkImage(
                                      imageUrl: trip.coverImageUrl,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withValues(alpha: 0.70), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: trip.status == 'Active Journey'
                                              ? AppColors.primaryOrange
                                              : AppColors.primaryPurple,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          trip.status,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 12,
                                      left: 12,
                                      right: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trip.title,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: -0.2),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${isAr ? dest.nameAr : dest.nameEn} • ${trip.daysCount} ${loc.translate('days')}',
                                            style: const TextStyle(color: AppColors.papyrusGold, fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.event_outlined, size: 16, color: AppColors.mediumGray),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.darkGray, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          AppleTouchable(
                                            pressedScale: 0.85,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                AppCupertinoPageRoute(
                                                  page: const InteractiveMapScreen(),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(6),
                                              child: Icon(Icons.map_outlined, color: AppColors.primaryPurple, size: 22),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            provider.formatPrice(trip.totalCostEgp, trip.totalCostUsd),
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
