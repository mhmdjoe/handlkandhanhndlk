import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../services/itinerary_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../explore/attraction_detail_screen.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final Trip trip;

  const ItineraryDetailScreen({super.key, required this.trip});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  late Trip _currentTrip;
  bool _isWholeTripView = true; // Default to showing the Whole Trip
  int _selectedDay = 1;
  late String _selectedHotelBudget;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
    _selectedHotelBudget = _currentTrip.hotelBudgetTier;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;

    final conflicts = ItineraryEngine.checkScheduleConflicts(_currentTrip);
    final totalDays = _currentTrip.daysCount;

    final destination = TourismDatabase.destinations.firstWhere(
      (d) => d.id == _currentTrip.destinationId,
      orElse: () => TourismDatabase.destinations.first,
    );

    // Filter hotels matching budget or destination
    final matchingHotels = TourismDatabase.hotels.where((h) {
      if (_selectedHotelBudget == 'Luxury') return h.starRating == 5;
      if (_selectedHotelBudget == 'Budget') return h.starRating <= 3 || h.pricePerNightUsd < 100;
      if (_selectedHotelBudget == 'Eco Lodge') return h.amenities.contains('Eco Lodge') || h.starRating >= 4;
      return h.starRating >= 4; // Moderate
    }).toList();

    final selectedHotel = _currentTrip.selectedHotelId != null
        ? TourismDatabase.hotels.firstWhere((h) => h.id == _currentTrip.selectedHotelId, orElse: () => matchingHotels.first)
        : (matchingHotels.isNotEmpty ? matchingHotels.first : TourismDatabase.hotels.first);

    // Calculate total cost including hotel stay
    final hotelTotalEgp = selectedHotel.pricePerNightEgp * totalDays;
    final hotelTotalUsd = selectedHotel.pricePerNightUsd * totalDays;
    final grandTotalEgp = _currentTrip.totalCostEgp + hotelTotalEgp;
    final grandTotalUsd = _currentTrip.totalCostUsd + hotelTotalUsd;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTrip.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم نسخ رابط الرحلة لمشاركته بالكامل!' : 'Whole trip itinerary copied!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Budget & Refined Active Status Banner (Without "Draft" text)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.nileTeal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('estimatedCost'),
                      style: const TextStyle(color: AppColors.desertSand, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.formatPrice(grandTotalEgp, grandTotalUsd),
                      style: const TextStyle(color: AppColors.papyrusGold, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.papyrusGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAr ? 'رحلة قائمة' : 'Active Journey',
                    style: const TextStyle(color: AppColors.nileTeal, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Conflicts Warning Banner
          if (conflicts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAr ? conflicts.first.warningAr : conflicts.first.warningEn,
                      style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // View Mode Selector: Whole Trip vs Day-by-Day
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(isAr ? 'الرحلة بالكامل ($totalDays أيام)' : 'Whole Trip ($totalDays Days)')),
                    selected: _isWholeTripView,
                    selectedColor: AppColors.nileTeal,
                    labelStyle: TextStyle(
                      color: _isWholeTripView ? Colors.white : AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _isWholeTripView = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(isAr ? 'حسب اليوم' : 'Day-by-Day')),
                    selected: !_isWholeTripView,
                    selectedColor: AppColors.papyrusGold,
                    labelStyle: TextStyle(
                      color: !_isWholeTripView ? AppColors.nileTeal : AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _isWholeTripView = false),
                  ),
                ),
              ],
            ),
          ),

          // Day Selection Tabs if Day-by-Day view is enabled
          if (!_isWholeTripView)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: totalDays,
                itemBuilder: (context, index) {
                  final dayNum = index + 1;
                  final isSel = _selectedDay == dayNum;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${loc.translate('day')} $dayNum'),
                      selected: isSel,
                      selectedColor: AppColors.papyrusGold,
                      onSelected: (_) => setState(() => _selectedDay = dayNum),
                    ),
                  );
                },
              ),
            ),

          // Content List View
          Expanded(
            child: _isWholeTripView
                ? _buildWholeTripListView(context, provider, isAr, totalDays, destination, selectedHotel, totalDays)
                : _buildDayItemsListView(context, provider, isAr, _selectedDay),
          ),
        ],
      ),
    );
  }

  Widget _buildWholeTripListView(
    BuildContext context,
    AppProvider provider,
    bool isAr,
    int totalDays,
    Destination dest,
    Hotel selectedHotel,
    int tripDays,
  ) {
    final hotelTotalEgp = selectedHotel.pricePerNightEgp * tripDays;
    final hotelTotalUsd = selectedHotel.pricePerNightUsd * tripDays;

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 110),
      children: [
        // Hotel Accommodation & Budget Selector Section
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.papyrusGold.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.nileTeal.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'اختر فندق وإقامة الرحلة' : 'Select Hotel & Accommodation',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.nileTeal),
                  ),
                  const Icon(Icons.hotel_rounded, color: AppColors.terracotta),
                ],
              ),
              const SizedBox(height: 12),

              // Budget Tier Selector Chips
              Text(
                isAr ? 'فئة ميزانية الإقامة:' : 'Hotel Budget Tier:',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: ['Budget', 'Moderate', 'Luxury', 'Eco Lodge'].map((tier) {
                  final isSel = _selectedHotelBudget == tier;
                  return ChoiceChip(
                    label: Text(tier),
                    selected: isSel,
                    selectedColor: AppColors.papyrusGold,
                    labelStyle: TextStyle(
                      color: isSel ? AppColors.nileTeal : AppColors.charcoal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedHotelBudget = tier;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Selected Hotel Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.desertSand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    SafeNetworkImage(
                      imageUrl: selectedHotel.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? selectedHotel.nameAr : selectedHotel.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${selectedHotel.starRating}★ • ${isAr ? selectedHotel.cityAr : selectedHotel.cityEn}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${provider.formatPrice(hotelTotalEgp, hotelTotalUsd)} ($tripDays ${isAr ? 'ليالي' : 'nights'})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.terracotta),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Daily Master Schedule Items
        ...List.generate(totalDays, (dIdx) {
          final dayNum = dIdx + 1;
          final dayItems = _currentTrip.items.where((i) => i.dayNumber == dayNum).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.desertSand,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Text(
                    '${isAr ? 'اليوم' : 'Day'} $dayNum • ${isAr ? dest.nameAr : dest.nameEn}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
                  ),
                ),

                if (dayItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isAr ? 'لا توجد أنشطة مجدولة لهذا اليوم' : 'Free leisure day.',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                else
                  ...dayItems.map((item) {
                    final attraction = TourismDatabase.attractions.firstWhere(
                      (a) => a.id == item.attractionId,
                      orElse: () => TourismDatabase.attractions.first,
                    );

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: SafeNetworkImage(
                        imageUrl: attraction.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        isAr ? attraction.nameAr : attraction.nameEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        '${item.startTime} - ${item.endTime} (${attraction.estimatedDurationMinutes} mins)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      trailing: Text(
                        provider.formatPrice(attraction.priceEgp, attraction.priceUsd),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttractionDetailScreen(attraction: attraction),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDayItemsListView(BuildContext context, AppProvider provider, bool isAr, int dayNum) {
    final dayItems = _currentTrip.items.where((i) => i.dayNumber == dayNum).toList();

    if (dayItems.isEmpty) {
      return Center(
        child: Text(
          isAr ? 'لا توجد أنشطة مجدولة لهذا اليوم' : 'No activities scheduled for Day $dayNum.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 110),
      itemCount: dayItems.length,
      itemBuilder: (context, index) {
        final item = dayItems[index];
        final attraction = TourismDatabase.attractions.firstWhere(
          (a) => a.id == item.attractionId,
          orElse: () => TourismDatabase.attractions.first,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SafeNetworkImage(
                  imageUrl: attraction.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? attraction.nameAr : attraction.nameEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.startTime} - ${item.endTime}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.formatPrice(attraction.priceEgp, attraction.priceUsd),
                        style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    setState(() {
                      _currentTrip.items.removeWhere((i) => i.id == item.id);
                    });
                    provider.updateTrip(_currentTrip);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
