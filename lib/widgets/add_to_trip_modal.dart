import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../data/tourism_database.dart';
import '../providers/app_provider.dart';
import '../services/itinerary_engine.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
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
  String? _selectedTripId; // 'new' or trip.id
  int _selectedDay = 1;
  String _selectedTimeSlot = '09:00';
  bool _isAdded = false;
  Trip? _addedTrip;

  // New trip fields if user chooses 'Create New Trip'
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = provider.isArabic;
    final a = widget.attraction;
    final userTrips = provider.userTrips;

    // Default selection logic
    _selectedTripId ??= userTrips.isNotEmpty ? userTrips.first.id : 'new';

    final targetTrip = userTrips.firstWhere(
      (t) => t.id == _selectedTripId,
      orElse: () => Trip(
        id: 'new',
        title: _newTripTitleController.text,
        destinationId: a.destinationId,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: _newTripDays)),
        daysCount: _newTripDays,
        items: [],
        totalCostEgp: 0,
        totalCostUsd: 0,
      ),
    );

    final maxDaysForSelectedTrip = _selectedTripId == 'new' ? _newTripDays : targetTrip.daysCount;

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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Attraction Header Card
          Row(
            children: [
              SafeNetworkImage(
                imageUrl: a.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? a.nameAr : a.nameEn,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isAr ? a.governorateAr : a.governorateEn} • ${isAr ? a.category.nameAr : a.category.nameEn}',
                      style: const TextStyle(color: AppColors.terracotta, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.formatPrice(a.priceEgp, a.priceUsd),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.nileTeal, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          if (!_isAdded) ...[
            // 1. Select Target Trip Dropdown
            Text(
              isAr ? 'اختر الرحلة المراد الإضافة إليها' : 'Select Target Trip',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedTripId,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.card_travel_rounded, color: AppColors.nileTeal),
              ),
              items: [
                if (userTrips.isNotEmpty)
                  ...userTrips.map((t) {
                    return DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        '${t.title} (${t.daysCount} ${isAr ? 'أيام' : 'Days'})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                DropdownMenuItem(
                  value: 'new',
                  child: Text(
                    isAr ? '+ إنشاء رحلة جديدة وتحديدها' : '+ Create New Trip',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta),
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedTripId = val;
                    _selectedDay = 1;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // If 'Create New Trip' is selected, show New Trip Inputs
            if (_selectedTripId == 'new') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.desertSand,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.papyrusGold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'بيانات الرحلة الجديدة' : 'New Trip Details',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.nileTeal),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _newTripTitleController,
                      decoration: InputDecoration(
                        labelText: isAr ? 'اسم الرحلة' : 'Trip Name',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'عدد الأيام' : 'Days',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: [2, 3, 5, 7].map((d) {
                                  final isSel = _newTripDays == d;
                                  return ChoiceChip(
                                    label: Text('$d'),
                                    selected: isSel,
                                    selectedColor: AppColors.nileTeal,
                                    labelStyle: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.charcoal),
                                    onSelected: (_) => setState(() => _newTripDays = d),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Select Trip Day
            Text(
              isAr ? 'اختر اليوم في الرحلة' : 'Select Trip Day',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: maxDaysForSelectedTrip,
                itemBuilder: (context, idx) {
                  final dayNum = idx + 1;
                  final isSel = _selectedDay == dayNum;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${loc.translate('day')} $dayNum'),
                      selected: isSel,
                      selectedColor: AppColors.papyrusGold,
                      labelStyle: TextStyle(
                        color: isSel ? AppColors.nileTeal : AppColors.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selectedDay = dayNum),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. Select Time Window
            Text(
              isAr ? 'اختر توقيت الزيارة' : 'Select Time Window',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.nileTeal),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _timeSlots.length,
                itemBuilder: (context, idx) {
                  final slot = _timeSlots[idx];
                  final isSel = _selectedTimeSlot == slot;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(slot),
                      selected: isSel,
                      selectedColor: AppColors.nileTeal,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            ElevatedButton.icon(
              onPressed: () => _executeAddToTrip(provider, isAr),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text(isAr ? 'تأكيد الإضافة للرحلة' : 'Confirm & Add to Trip'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.nileTeal,
              ),
            ),
          ] else ...[
            // Success Feedback & Jump into Trip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verifiedGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.verifiedGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.verifiedGreen, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'تمت إضافة المكان للرحلة المحددة بنجاح!' : 'Added directly to your selected trip!',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.verifiedGreen, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr ? 'الرحلة: ${_addedTrip?.title} • اليوم $_selectedDay في الساعة $_selectedTimeSlot' : '${_addedTrip?.title} • Day $_selectedDay at $_selectedTimeSlot',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isAr ? 'متابعة الاستكشاف' : 'Continue Exploring'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      if (_addedTrip != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItineraryDetailScreen(trip: _addedTrip!),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(isAr ? 'افتح الرحلة' : 'Open Trip'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.terracotta),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _executeAddToTrip(AppProvider provider, bool isAr) {
    final a = widget.attraction;
    Trip targetTrip;

    if (_selectedTripId == 'new' || provider.userTrips.isEmpty) {
      final tripTitle = _newTripTitleController.text.trim().isEmpty
          ? 'Trip to ${a.governorateEn}'
          : _newTripTitleController.text.trim();

      targetTrip = ItineraryEngine.generateAutoTrip(
        title: tripTitle,
        destinationId: a.destinationId,
        attractionIds: [a.id],
        startDate: DateTime.now().add(const Duration(days: 7)),
        daysCount: _newTripDays,
        travelerCount: _newTripTravelers,
      );
      provider.addTrip(targetTrip);
    } else {
      final active = provider.userTrips.firstWhere((t) => t.id == _selectedTripId);
      final startHour = int.tryParse(_selectedTimeSlot.split(':')[0]) ?? 9;
      final durationHours = (a.estimatedDurationMinutes / 60).ceil();
      final endHour = startHour + durationHours;
      final endTimeStr = '${endHour.toString().padLeft(2, '0')}:00';

      final newItem = ItineraryItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        attractionId: a.id,
        dayNumber: _selectedDay,
        startTime: _selectedTimeSlot,
        endTime: endTimeStr,
        notes: 'Added from exploration popup',
        transportToNext: TourismDatabase.defaultTransportOptions[0],
      );

      targetTrip = Trip(
        id: active.id,
        title: active.title,
        destinationId: active.destinationId,
        startDate: active.startDate,
        endDate: active.endDate,
        daysCount: active.daysCount,
        items: [...active.items, newItem],
        totalCostEgp: active.totalCostEgp + a.priceEgp,
        totalCostUsd: active.totalCostUsd + a.priceUsd,
        status: active.status,
        travelerCount: active.travelerCount,
      );

      provider.updateTrip(targetTrip);
    }

    setState(() {
      _isAdded = true;
      _addedTrip = targetTrip;
    });
  }
}
