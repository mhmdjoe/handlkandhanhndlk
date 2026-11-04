import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../data/tourism_database.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_motion.dart';
import 'apple_touchable.dart';
import 'network_image_with_fallback.dart';
import '../views/planner/itinerary_detail_screen.dart';

class AddToTripModal extends StatefulWidget {
  final Attraction attraction;

  const AddToTripModal({super.key, required this.attraction});

  static void show(BuildContext context, Attraction attraction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToTripModal(attraction: attraction),
    );
  }

  @override
  State<AddToTripModal> createState() => _AddToTripModalState();
}

class _AddToTripModalState extends State<AddToTripModal> {
  String? _selectedTripId;
  int _selectedDay = 1;
  String _selectedTimeSlot = '09:00';
  bool _isAdded = false;
  Trip? _addedTrip;

  final _newTripTitleController = TextEditingController();
  int _newTripDays = 3;
  final int _newTripTravelers = 2;

  final List<String> _timeSlots = ['09:00', '11:30', '14:00', '16:30', '19:00'];

  @override
  void initState() {
    super.initState();
    _newTripTitleController.text = 'Trip to ${widget.attraction.governorateEn}';
  }

  @override
  void dispose() {
    _newTripTitleController.dispose();
    super.dispose();
  }

  String _getAttractionName(String id, bool isAr) {
    final attraction = TourismDatabase.attractions.firstWhere(
      (a) => a.id == id,
      orElse: () => widget.attraction,
    );
    return isAr ? attraction.nameAr : attraction.nameEn;
  }

  ItineraryItem? _findConflictingItem(Trip? targetTrip) {
    if (targetTrip == null || targetTrip.items.isEmpty) return null;

    int newStartHour = int.tryParse(_selectedTimeSlot.split(':')[0]) ?? 9;

    for (var item in targetTrip.items) {
      if (item.dayNumber == _selectedDay) {
        int itemStartHour = int.tryParse(item.startTime.split(':')[0]) ?? 9;
        int itemEndHour = int.tryParse(item.endTime.split(':')[0]) ?? (itemStartHour + 2);

        if (newStartHour >= itemStartHour && newStartHour < itemEndHour) {
          return item;
        }
      }
    }
    return null;
  }

  void _onConfirmAdd(AppProvider provider, Attraction a, List<Trip> userTrips) {
    Trip updatedTrip;

    int startHour = int.tryParse(_selectedTimeSlot.split(':')[0]) ?? 9;
    int durationHours = (a.estimatedDurationMinutes / 60).clamp(1, 3).toInt();
    int endHour = startHour + durationHours;
    String endTimeStr = '${endHour.toString().padLeft(2, '0')}:00';

    final newItem = ItineraryItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      attractionId: a.id,
      dayNumber: _selectedDay,
      startTime: _selectedTimeSlot,
      endTime: endTimeStr,
      notes: 'Manually added by user from Explore',
    );

    if (_selectedTripId == 'new') {
      final dest = TourismDatabase.destinations.firstWhere(
        (d) => d.id == a.destinationId,
        orElse: () => TourismDatabase.destinations.first,
      );

      final newTrip = Trip(
        id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
        title: _newTripTitleController.text.trim().isNotEmpty
            ? _newTripTitleController.text.trim()
            : 'Handelak ${dest.nameEn} Journey',
        destinationId: a.destinationId,
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(Duration(days: _newTripDays + 3)),
        daysCount: _newTripDays,
        items: [newItem], // ONLY the manually selected place
        totalCostEgp: a.priceEgp * _newTripTravelers,
        totalCostUsd: a.priceUsd * _newTripTravelers,
        travelerCount: _newTripTravelers,
        status: 'Active Journey',
      );

      provider.addTrip(newTrip);
      updatedTrip = newTrip;
    } else {
      final existingTrip = userTrips.firstWhere((t) => t.id == _selectedTripId);
      final updatedItems = List<ItineraryItem>.from(existingTrip.items)..add(newItem);

      double totalEgp = 0;
      double totalUsd = 0;
      for (var item in updatedItems) {
        final itemAttraction = TourismDatabase.attractions.firstWhere(
          (att) => att.id == item.attractionId,
          orElse: () => a,
        );
        totalEgp += itemAttraction.priceEgp * existingTrip.travelerCount;
        totalUsd += itemAttraction.priceUsd * existingTrip.travelerCount;
      }

      updatedTrip = Trip(
        id: existingTrip.id,
        title: existingTrip.title,
        destinationId: existingTrip.destinationId,
        startDate: existingTrip.startDate,
        endDate: existingTrip.endDate,
        daysCount: existingTrip.daysCount,
        travelerCount: existingTrip.travelerCount,
        status: existingTrip.status,
        hotelBudgetTier: existingTrip.hotelBudgetTier,
        selectedHotelId: existingTrip.selectedHotelId,
        items: updatedItems,
        totalCostEgp: totalEgp,
        totalCostUsd: totalUsd,
      );
      provider.updateTrip(updatedTrip);
    }

    setState(() {
      _isAdded = true;
      _addedTrip = updatedTrip;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;
    final a = widget.attraction;
    final userTrips = provider.userTrips;

    _selectedTripId ??= userTrips.isNotEmpty ? userTrips.first.id : 'new';

    final targetTrip = _selectedTripId == 'new'
        ? null
        : userTrips.firstWhere((t) => t.id == _selectedTripId, orElse: () => userTrips.first);

    final maxDaysForSelectedTrip = _selectedTripId == 'new' ? _newTripDays : (targetTrip?.daysCount ?? 3);
    final conflictingItem = _findConflictingItem(targetTrip);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header with attraction thumbnail
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SafeNetworkImage(
                  imageUrl: a.imageUrl,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('addToTrip'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: -0.3),
                    ),
                    Text(
                      isAr ? a.nameAr : a.nameEn,
                      style: const TextStyle(fontSize: 14, color: AppColors.darkGray, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isAdded && _addedTrip != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verifiedGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.verifiedGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.verifiedGreen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAr ? 'تمت إضافة المكان إلى جدول الرحلة بنجاح!' : 'Attraction added to your trip successfully!',
                      style: const TextStyle(color: AppColors.verifiedGreen, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppleTouchable(
                    onTap: () => Navigator.pop(context),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isAr ? 'إغلاق' : 'Close'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppleTouchable(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        AppCupertinoPageRoute(
                          page: ItineraryDetailScreen(trip: _addedTrip!),
                        ),
                      );
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          AppCupertinoPageRoute(
                            page: ItineraryDetailScreen(trip: _addedTrip!),
                          ),
                        );
                      },
                      child: Text(isAr ? 'عرض الجدول' : 'View Itinerary'),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Trip Selection
            Text(
              isAr ? 'اختر الرحلة:' : 'Select Trip:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkGray),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 44,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  ...userTrips.map((t) {
                    final isSel = _selectedTripId == t.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppleTouchable(
                        pressedScale: 0.92,
                        onTap: () => setState(() => _selectedTripId = t.id),
                        child: ChoiceChip(
                          label: Text(t.title),
                          selected: isSel,
                          onSelected: null,
                          selectedColor: AppColors.primaryOrange,
                          backgroundColor: AppColors.lightPurple,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.darkGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                  AppleTouchable(
                    pressedScale: 0.92,
                    onTap: () => setState(() => _selectedTripId = 'new'),
                    child: ChoiceChip(
                      label: Text(isAr ? '+ رحلة جديدة يدوية' : '+ New Blank Trip'),
                      selected: _selectedTripId == 'new',
                      onSelected: null,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: AppColors.lightPurple,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedTripId == 'new' ? Colors.white : AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // If new trip is chosen, show input fields
            if (_selectedTripId == 'new') ...[
              TextField(
                controller: _newTripTitleController,
                decoration: InputDecoration(
                  labelText: isAr ? 'عنوان الرحلة الجديدة' : 'New Trip Title',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(isAr ? 'عدد الأيام:' : 'Days Count:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _newTripDays,
                    items: [1, 2, 3, 4, 5, 7, 10].map((d) {
                      return DropdownMenuItem(value: d, child: Text('$d ${loc.translate('days')}'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _newTripDays = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Day Selector
            Row(
              children: [
                Text(
                  isAr ? 'اليوم في الرحلة:' : 'Day in Trip:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkGray),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _selectedDay > maxDaysForSelectedTrip ? 1 : _selectedDay,
                  items: List.generate(maxDaysForSelectedTrip, (i) => i + 1).map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text('${loc.translate('day')} $day'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDay = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Slot Selector
            Text(
              isAr ? 'موعد الزيارة المقترح:' : 'Suggested Visit Time:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkGray),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: _timeSlots.map((slot) {
                final isSel = _selectedTimeSlot == slot;
                return AppleTouchable(
                  pressedScale: 0.92,
                  onTap: () => setState(() => _selectedTimeSlot = slot),
                  child: ChoiceChip(
                    label: Text(slot),
                    selected: isSel,
                    onSelected: null,
                    selectedColor: AppColors.primaryOrange,
                    backgroundColor: AppColors.lightPurple,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.darkGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),

            // Time Conflict Warning Banner
            if (conflictingItem != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.alertAmber, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.alertAmber, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'تعارض في الموعد المجدول!' : 'Time Slot Conflict Warning!',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.alertAmber, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAr
                                ? 'يوجد مكان آخر (${_getAttractionName(conflictingItem.attractionId, isAr)}) مجدول بالفعل في اليوم $_selectedDay الساعة $_selectedTimeSlot.'
                                : '${_getAttractionName(conflictingItem.attractionId, isAr)} is already scheduled on Day $_selectedDay at $_selectedTimeSlot.',
                            style: const TextStyle(color: AppColors.darkGray, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Confirm Button
            AppleTouchable(
              onTap: () => _onConfirmAdd(provider, a, userTrips),
              child: ElevatedButton(
                onPressed: () => _onConfirmAdd(provider, a, userTrips),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: conflictingItem != null ? AppColors.alertAmber : AppColors.primaryPurple,
                ),
                child: Text(
                  conflictingItem != null
                      ? (isAr ? 'إضافة رغم التعارض الزمني' : 'Add Anyway (Resolve Conflict)')
                      : loc.translate('confirmAdd'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
