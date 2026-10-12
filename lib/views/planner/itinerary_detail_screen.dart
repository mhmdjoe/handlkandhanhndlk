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
  late DateTime _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
    _selectedHotelBudget = _currentTrip.hotelBudgetTier;
    _selectedStartDate = _currentTrip.startDate;
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

    final isNoHotel = _selectedHotelBudget == 'No Hotel Needed';

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

    // Calculate total cost including hotel stay (or 0 if No Hotel Needed)
    final hotelTotalEgp = isNoHotel ? 0.0 : (selectedHotel.pricePerNightEgp * totalDays);
    final hotelTotalUsd = isNoHotel ? 0.0 : (selectedHotel.pricePerNightUsd * totalDays);
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
          // Delete Trip Button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _showDeleteTripConfirmation(context, provider, isAr),
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Budget & Date Booking Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.nileTeal,
            child: Column(
              children: [
                Row(
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

                    // Date Picker Trigger Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _selectedStartDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.papyrusGold),
                      label: Text(
                        '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.papyrusGold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Confirm & Book Journey Button
                ElevatedButton.icon(
                  onPressed: () => _showBookingConfirmationModal(
                    context,
                    provider,
                    isAr,
                    grandTotalEgp,
                    grandTotalUsd,
                    selectedHotel,
                    totalDays,
                    isNoHotel,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(isAr ? 'تأكيد وحجز الرحلة الآن' : 'Book & Reserve Journey Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: AppColors.papyrusGold,
                    foregroundColor: AppColors.nileTeal,
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

  void _showDeleteTripConfirmation(BuildContext context, AppProvider provider, bool isAr) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAr ? 'حذف الرحلة؟' : 'Delete Trip?'),
          content: Text(
            isAr
                ? 'هل أنت تأكد من رغبتك في حذف هذه الرحلة نهائياً من حسابك؟'
                : 'Are you sure you want to permanently delete this trip from your saved journeys?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.removeTrip(_currentTrip.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to MyTripsScreen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text(isAr ? 'حذف الرحلة' : 'Delete Trip'),
            ),
          ],
        );
      },
    );
  }

  void _showBookingConfirmationModal(
    BuildContext context,
    AppProvider provider,
    bool isAr,
    double totalEgp,
    double totalUsd,
    Hotel selectedHotel,
    int tripDays,
    bool isNoHotel,
  ) {
    final endDate = _selectedStartDate.add(Duration(days: tripDays));

    // Update trip status to confirmed
    final updatedTrip = Trip(
      id: _currentTrip.id,
      title: _currentTrip.title,
      destinationId: _currentTrip.destinationId,
      startDate: _selectedStartDate,
      endDate: endDate,
      daysCount: tripDays,
      items: _currentTrip.items,
      totalCostEgp: totalEgp,
      totalCostUsd: totalUsd,
      status: 'Confirmed',
      travelerCount: _currentTrip.travelerCount,
      selectedHotelId: isNoHotel ? null : selectedHotel.id,
      hotelBudgetTier: _selectedHotelBudget,
    );

    provider.updateTrip(updatedTrip);
    setState(() => _currentTrip = updatedTrip);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.verifiedGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),

              Text(
                isAr ? 'تم حجز وتأكيد الرحلة بنجاح!' : 'Journey Successfully Booked!',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.nileTeal),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${isAr ? 'كود الحجز' : 'Booking Ref'}: #HNDLK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta, fontSize: 13),
              ),
              const Divider(height: 24),

              // Booking Details Summary Table
              _receiptRow(isAr ? 'اسم الرحلة' : 'Trip Title', _currentTrip.title),
              _receiptRow(isAr ? 'تاريخ البداية' : 'Start Date', '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}'),
              _receiptRow(isAr ? 'تاريخ النهاية' : 'End Date', '${endDate.day}/${endDate.month}/${endDate.year}'),
              _receiptRow(isAr ? 'عدد المسافرين' : 'Travelers', '${_currentTrip.travelerCount}'),
              _receiptRow(
                isAr ? 'الإقامة' : 'Accommodation',
                isNoHotel
                    ? (isAr ? 'إقامة شخصية خاصة (بدون فندق)' : 'Personal Stay (No Hotel)')
                    : (isAr ? selectedHotel.nameAr : selectedHotel.nameEn),
              ),
              _receiptRow(isAr ? 'التكلفة الكلية' : 'Total Amount', provider.formatPrice(totalEgp, totalUsd), isBold: true),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.nileTeal,
                ),
                child: Text(isAr ? 'تم، العودة للرحلة' : 'Done & Return'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _receiptRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 15 : 13,
              color: isBold ? AppColors.terracotta : AppColors.charcoal,
            ),
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
    final isNoHotel = _selectedHotelBudget == 'No Hotel Needed';
    final hotelTotalEgp = isNoHotel ? 0.0 : selectedHotel.pricePerNightEgp * tripDays;
    final hotelTotalUsd = isNoHotel ? 0.0 : selectedHotel.pricePerNightUsd * tripDays;

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

              // Budget Tier Selector Chips (Including No Hotel Needed!)
              Text(
                isAr ? 'فئة خيار الإقامة:' : 'Accommodation Option:',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['No Hotel Needed', 'Budget', 'Moderate', 'Luxury', 'Eco Lodge'].map((tier) {
                  final isSel = _selectedHotelBudget == tier;
                  final labelText = tier == 'No Hotel Needed'
                      ? (isAr ? 'إقامة شخصية (بدون فندق)' : 'No Hotel Needed')
                      : tier;

                  return ChoiceChip(
                    label: Text(labelText),
                    selected: isSel,
                    selectedColor: tier == 'No Hotel Needed' ? AppColors.terracotta : AppColors.papyrusGold,
                    labelStyle: TextStyle(
                      color: isSel ? (tier == 'No Hotel Needed' ? Colors.white : AppColors.nileTeal) : AppColors.charcoal,
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

              // Selected Hotel Banner OR No Hotel Banner
              if (isNoHotel)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.desertSand,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.terracotta,
                        radius: 20,
                        child: Icon(Icons.home_outlined, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'إقامة شخصية خاصة' : 'Personal Accommodation',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              isAr ? 'لن يتم إضافة أية تكاليف حجز فندق للرحلة' : 'No hotel reservation fees added to total trip cost',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
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
