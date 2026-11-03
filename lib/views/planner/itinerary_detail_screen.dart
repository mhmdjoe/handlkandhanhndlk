import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../data/tourism_database.dart';
import '../../providers/app_provider.dart';
import '../../services/itinerary_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
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
  bool _isWholeTripView = true;
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

    final matchingHotels = TourismDatabase.hotels.where((h) {
      if (_selectedHotelBudget == 'Luxury') return h.starRating == 5;
      if (_selectedHotelBudget == 'Budget') return h.starRating <= 3 || h.pricePerNightUsd < 100;
      if (_selectedHotelBudget == 'Eco Lodge') return h.amenities.contains('Eco Lodge') || h.starRating >= 4;
      return h.starRating >= 4;
    }).toList();

    final selectedHotel = _currentTrip.selectedHotelId != null
        ? TourismDatabase.hotels.firstWhere((h) => h.id == _currentTrip.selectedHotelId, orElse: () => matchingHotels.first)
        : (matchingHotels.isNotEmpty ? matchingHotels.first : TourismDatabase.hotels.first);

    final hotelTotalEgp = isNoHotel ? 0.0 : (selectedHotel.pricePerNightEgp * totalDays);
    final hotelTotalUsd = isNoHotel ? 0.0 : (selectedHotel.pricePerNightUsd * totalDays);
    final grandTotalEgp = _currentTrip.totalCostEgp + hotelTotalEgp;
    final grandTotalUsd = _currentTrip.totalCostUsd + hotelTotalUsd;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTrip.title),
        actions: [
          AppleTouchable(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم نسخ رابط الرحلة لمشاركته بالكامل!' : 'Whole trip itinerary copied!'),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.share_outlined, color: AppColors.primaryPurple),
            ),
          ),
          AppleTouchable(
            onTap: () => _showDeleteTripConfirmation(context, provider, isAr),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero Cover Image & Total Budget Booking Banner
          Stack(
            children: [
              SafeNetworkImage(
                imageUrl: _currentTrip.coverImageUrl,
                height: 175,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 175,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 14,
                bottom: 14,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('estimatedCost'),
                              style: const TextStyle(color: AppColors.lightPurple, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.formatPrice(grandTotalEgp, grandTotalUsd),
                              style: const TextStyle(color: AppColors.papyrusGold, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        // Date Picker Trigger Button
                        AppleTouchable(
                          pressedScale: 0.92,
                          onTap: () async {
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
                          child: OutlinedButton.icon(
                            onPressed: null,
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
                        ),
                      ],
                    ),

                    // Confirm & Book Journey Button
                    AppleTouchable(
                      onTap: () => _showBookingConfirmationModal(
                        context,
                        provider,
                        isAr,
                        grandTotalEgp,
                        grandTotalUsd,
                        selectedHotel,
                        totalDays,
                        isNoHotel,
                      ),
                      child: ElevatedButton.icon(
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
                          minimumSize: const Size.fromHeight(42),
                          backgroundColor: AppColors.papyrusGold,
                          foregroundColor: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                  child: AppleTouchable(
                    pressedScale: 0.95,
                    onTap: () => setState(() => _isWholeTripView = true),
                    child: ChoiceChip(
                      label: Center(child: Text(isAr ? 'الرحلة بالكامل ($totalDays أيام)' : 'Whole Trip ($totalDays Days)')),
                      selected: _isWholeTripView,
                      onSelected: null,
                      selectedColor: AppColors.primaryPurple,
                      backgroundColor: AppColors.lightPurple,
                      labelStyle: TextStyle(
                        color: _isWholeTripView ? Colors.white : AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppleTouchable(
                    pressedScale: 0.95,
                    onTap: () => setState(() => _isWholeTripView = false),
                    child: ChoiceChip(
                      label: Center(child: Text(isAr ? 'حسب اليوم' : 'Day-by-Day')),
                      selected: !_isWholeTripView,
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      labelStyle: TextStyle(
                        color: !_isWholeTripView ? Colors.white : AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: totalDays,
                itemBuilder: (context, index) {
                  final dayNum = index + 1;
                  final isSel = _selectedDay == dayNum;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppleTouchable(
                      pressedScale: 0.92,
                      onTap: () => setState(() => _selectedDay = dayNum),
                      child: ChoiceChip(
                        label: Text('${loc.translate('day')} $dayNum'),
                        selected: isSel,
                        onSelected: null,
                        selectedColor: AppColors.primaryOrange,
                        backgroundColor: AppColors.lightPurple,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    int daysCount,
    Destination destination,
    Hotel selectedHotel,
    int totalDays,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 110),
      children: [
        // Hotel Accommodation Selector Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'خيار الإقامة والفندق' : 'Hotel Accommodation',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryPurple),
                    ),
                    DropdownButton<String>(
                      value: _selectedHotelBudget,
                      items: ['Moderate', 'Luxury', 'Budget', 'Eco Lodge', 'No Hotel Needed'].map((tier) {
                        return DropdownMenuItem(
                          value: tier,
                          child: Text(tier, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedHotelBudget = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedHotelBudget != 'No Hotel Needed') ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SafeNetworkImage(
                          imageUrl: selectedHotel.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
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
                              '${selectedHotel.starRating} Stars • ${isAr ? selectedHotel.cityAr : selectedHotel.cityEn}',
                              style: const TextStyle(color: AppColors.mediumGray, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.formatPrice(selectedHotel.pricePerNightEgp, selectedHotel.pricePerNightUsd)} / night',
                              style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // List of Day Blocks
        ...List.generate(daysCount, (dayIndex) {
          final dayNum = dayIndex + 1;
          final dayItems = _currentTrip.items.where((item) => item.dayNumber == dayNum).toList();

          return StaggeredEntranceItem(
            index: dayIndex,
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isAr ? 'اليوم' : 'Day'} $dayNum',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                    ),
                    const Divider(height: 20),

                    if (dayItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          isAr ? 'لا توجد أنشطة مجدولة لهذا اليوم.' : 'No activities scheduled for this day.',
                          style: const TextStyle(color: AppColors.mediumGray, fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      ...dayItems.map((item) {
                        final attraction = TourismDatabase.attractions.firstWhere(
                          (a) => a.id == item.attractionId,
                          orElse: () => TourismDatabase.attractions.first,
                        );

                        return AppleTouchable(
                          pressedScale: 0.97,
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              AppCupertinoPageRoute(
                                page: AttractionDetailScreen(attraction: attraction),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SafeNetworkImage(
                                    imageUrl: attraction.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAr ? attraction.nameAr : attraction.nameEn,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item.startTime} • ${provider.formatPrice(attraction.priceEgp, attraction.priceUsd)}',
                                        style: const TextStyle(color: AppColors.mediumGray, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                AppleTouchable(
                                  pressedScale: 0.85,
                                  onTap: () => _removeItem(item.id, provider),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDayItemsListView(BuildContext context, AppProvider provider, bool isAr, int dayNum) {
    final dayItems = _currentTrip.items.where((item) => item.dayNumber == dayNum).toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 110),
      itemCount: dayItems.length,
      itemBuilder: (context, index) {
        final item = dayItems[index];
        final attraction = TourismDatabase.attractions.firstWhere(
          (a) => a.id == item.attractionId,
          orElse: () => TourismDatabase.attractions.first,
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
                  page: AttractionDetailScreen(attraction: attraction),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SafeNetworkImage(
                        imageUrl: attraction.imageUrl,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? attraction.nameAr : attraction.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.startTime} • ${provider.formatPrice(attraction.priceEgp, attraction.priceUsd)}',
                            style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    AppleTouchable(
                      pressedScale: 0.85,
                      onTap: () => _removeItem(item.id, provider),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _removeItem(String itemId, AppProvider provider) {
    final updatedItems = _currentTrip.items.where((i) => i.id != itemId).toList();
    double totalEgp = 0;
    double totalUsd = 0;
    for (var item in updatedItems) {
      final a = TourismDatabase.attractions.firstWhere((att) => att.id == item.attractionId);
      totalEgp += a.priceEgp;
      totalUsd += a.priceUsd;
    }

    final updatedTrip = Trip(
      id: _currentTrip.id,
      title: _currentTrip.title,
      destinationId: _currentTrip.destinationId,
      startDate: _currentTrip.startDate,
      endDate: _currentTrip.endDate,
      daysCount: _currentTrip.daysCount,
      travelerCount: _currentTrip.travelerCount,
      status: _currentTrip.status,
      hotelBudgetTier: _currentTrip.hotelBudgetTier,
      selectedHotelId: _currentTrip.selectedHotelId,
      items: updatedItems,
      totalCostEgp: totalEgp,
      totalCostUsd: totalUsd,
    );

    provider.updateTrip(updatedTrip);
    setState(() => _currentTrip = updatedTrip);
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
            AppleTouchable(
              onTap: () {
                provider.removeTrip(_currentTrip.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: ElevatedButton(
                onPressed: () {
                  provider.removeTrip(_currentTrip.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text(isAr ? 'حذف الرحلة' : 'Delete Trip'),
              ),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primaryPurple, letterSpacing: -0.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${isAr ? 'كود الحجز' : 'Booking Ref'}: #HNDLK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOrange, fontSize: 13),
              ),
              const Divider(height: 24),
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
              AppleTouchable(
                onTap: () => Navigator.pop(context),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.primaryPurple,
                  ),
                  child: Text(isAr ? 'تم، العودة للرحلة' : 'Done & Return'),
                ),
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
          Text(label, style: const TextStyle(color: AppColors.mediumGray, fontSize: 13)),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 15 : 13,
              color: isBold ? AppColors.primaryOrange : AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
