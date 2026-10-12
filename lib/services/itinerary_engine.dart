import '../models/models.dart';
import '../data/tourism_database.dart';

class ScheduleConflict {
  final String itemId;
  final String attractionName;
  final String warningEn;
  final String warningAr;

  ScheduleConflict({
    required this.itemId,
    required this.attractionName,
    required this.warningEn,
    required this.warningAr,
  });
}

class ItineraryEngine {
  /// Builds a realistic day-by-day itinerary for a given destination & attractions
  static Trip generateAutoTrip({
    required String title,
    required String destinationId,
    required List<String> attractionIds,
    required DateTime startDate,
    required int daysCount,
    required int travelerCount,
  }) {
    final selectedAttractions = TourismDatabase.attractions
        .where((a) => attractionIds.contains(a.id))
        .toList();

    List<ItineraryItem> items = [];
    double totalEgp = 0;
    double totalUsd = 0;

    int itemsPerDay = (selectedAttractions.length / daysCount).ceil();
    if (itemsPerDay < 1) itemsPerDay = 1;

    int attractionIndex = 0;

    for (int day = 1; day <= daysCount; day++) {
      int currentHour = 8; // Start day at 8:00 AM

      for (int i = 0; i < itemsPerDay && attractionIndex < selectedAttractions.length; i++) {
        final attraction = selectedAttractions[attractionIndex];
        attractionIndex++;

        String startStr = '${currentHour.toString().padLeft(2, '0')}:00';
        int durationHours = (attraction.estimatedDurationMinutes / 60).ceil();
        int endHour = currentHour + durationHours;
        String endStr = '${endHour.toString().padLeft(2, '0')}:00';

        // Select suitable transport
        TransportOption transport = TourismDatabase.defaultTransportOptions[0]; // Private driver default

        items.add(
          ItineraryItem(
            id: 'item_${day}_${i}_${attraction.id}',
            attractionId: attraction.id,
            dayNumber: day,
            startTime: startStr,
            endTime: endStr,
            notes: 'Visit ${attraction.nameEn} with verified source: ${attraction.verifiedSource}',
            transportToNext: transport,
          ),
        );

        totalEgp += (attraction.priceEgp * travelerCount) + transport.priceEgp;
        totalUsd += (attraction.priceUsd * travelerCount) + transport.priceUsd;

        currentHour = endHour + 1; // 1 hour buffer/travel break
      }
    }

    return Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      destinationId: destinationId,
      startDate: startDate,
      endDate: startDate.add(Duration(days: daysCount)),
      items: items,
      totalCostEgp: totalEgp,
      totalCostUsd: totalUsd,
      status: 'Draft',
      travelerCount: travelerCount,
    );
  }

  /// Checks for any schedule conflicts (e.g., visiting after attraction closing time)
  static List<ScheduleConflict> checkScheduleConflicts(Trip trip) {
    List<ScheduleConflict> conflicts = [];

    for (var item in trip.items) {
      final attraction = TourismDatabase.attractions.firstWhere(
        (a) => a.id == item.attractionId,
        orElse: () => TourismDatabase.attractions[0],
      );

      final itemEndHour = int.tryParse(item.endTime.split(':')[0]) ?? 18;
      final closingHour = int.tryParse(attraction.closingTime.split(':')[0]) ?? 17;

      if (itemEndHour > closingHour) {
        conflicts.add(
          ScheduleConflict(
            itemId: item.id,
            attractionName: attraction.nameEn,
            warningEn: 'Attraction closes at ${attraction.closingTime}. Scheduled end (${item.endTime}) exceeds opening hours!',
            warningAr: 'المكان يغلق الساعة ${attraction.closingTime}. التوقيت المجدول (${item.endTime}) يتجاوز مواعيد العمل!',
          ),
        );
      }
    }

    return conflicts;
  }
}
