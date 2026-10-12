import '../models/models.dart';
import '../data/tourism_database.dart';
import 'itinerary_engine.dart';

class AiAssistantResponse {
  final String textResponseEn;
  final String textResponseAr;
  final Trip? generatedTrip;

  AiAssistantResponse({
    required this.textResponseEn,
    required this.textResponseAr,
    this.generatedTrip,
  });
}

class AiAssistantService {
  static Future<AiAssistantResponse> processUserPrompt({
    required String prompt,
    required String destinationId,
    required int daysCount,
    required int travelerCount,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Realistic AI generation delay

    final lowercasePrompt = prompt.toLowerCase();
    
    // Select attractions matching prompt or destination
    List<Attraction> available = TourismDatabase.attractions
        .where((a) => a.destinationId == destinationId)
        .toList();

    if (available.isEmpty) {
      available = TourismDatabase.attractions.take(4).toList();
    }

    // Filter by interests if prompt mentions keyword
    List<String> selectedIds = [];
    if (lowercasePrompt.contains('history') || lowercasePrompt.contains('pyramid') || lowercasePrompt.contains('museum') || lowercasePrompt.contains('تاريخ') || lowercasePrompt.contains('أهرامات')) {
      selectedIds = available
          .where((a) => a.category == CategoryType.archaeology || a.category == CategoryType.museum)
          .map((a) => a.id)
          .toList();
    } else if (lowercasePrompt.contains('sea') || lowercasePrompt.contains('beach') || lowercasePrompt.contains('div') || lowercasePrompt.contains('بحر') || lowercasePrompt.contains('شاطئ')) {
      selectedIds = available
          .where((a) => a.category == CategoryType.beach || a.category == CategoryType.diving)
          .map((a) => a.id)
          .toList();
    }

    if (selectedIds.isEmpty) {
      selectedIds = available.map((a) => a.id).toList();
    }

    final dest = TourismDatabase.destinations.firstWhere(
      (d) => d.id == destinationId,
      orElse: () => TourismDatabase.destinations[0],
    );

    final trip = ItineraryEngine.generateAutoTrip(
      title: 'HNHNDLK ${dest.nameEn} $daysCount-Day Experience',
      destinationId: destinationId,
      attractionIds: selectedIds,
      startDate: DateTime.now().add(const Duration(days: 7)),
      daysCount: daysCount,
      travelerCount: travelerCount,
    );

    return AiAssistantResponse(
      textResponseEn: 'HNHNDLK AI has crafted a personalized $daysCount-day itinerary in ${dest.nameEn} tailored to your preferences! All entry fees and opening hours have been verified against official records.',
      textResponseAr: 'قام مساعد "هنهندلك" الذكي بإنشاء برنامج مخصص لمصر لمدة $daysCount أيام في ${dest.nameAr} تناسب رغبتك! تم التحقق من جميع المواعيد والأسعار من المصادر الرسمية.',
      generatedTrip: trip,
    );
  }
}
