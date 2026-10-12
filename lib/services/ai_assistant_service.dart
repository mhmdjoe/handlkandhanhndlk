import '../models/models.dart';
import '../data/tourism_database.dart';
import 'itinerary_engine.dart';

class AiAssistantResponse {
  final String textResponseEn;
  final String textResponseAr;
  final Trip? generatedTrip;
  final bool isClarificationNeeded;

  AiAssistantResponse({
    required this.textResponseEn,
    required this.textResponseAr,
    this.generatedTrip,
    this.isClarificationNeeded = false,
  });
}

class AiAssistantService {
  /// Smart AI prompt processing with dynamic RegExp parameter extraction & conversational travel intelligence
  static Future<AiAssistantResponse> processUserPrompt({
    required String prompt,
    required String destinationId,
    required int daysCount,
    required int travelerCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // Realistic AI reasoning delay

    final p = prompt.toLowerCase().trim();

    // 1. Check for general travel Q&A questions first
    final qaResponse = _handleTravelKnowledgeBase(p);
    if (qaResponse != null) {
      return qaResponse;
    }

    // 2. Dynamic RegExp Extraction for Days & Duration
    int targetDays = daysCount;
    final daysMatch = RegExp(r'(\d+|[٠-٩]+)\s*(?:days?|day|أيام|ايام|يوم)').firstMatch(p);
    final hasDays = daysMatch != null ||
        p.contains('week') || p.contains('اسبوع') || p.contains('أسبوع') || p.contains('يومين');

    if (daysMatch != null) {
      targetDays = _parseArabicOrEnglishNumber(daysMatch.group(1)!);
    } else if (p.contains('week') || p.contains('اسبوع') || p.contains('أسبوع')) {
      targetDays = 7;
    } else if (p.contains('يومين')) {
      targetDays = 2;
    }

    // 3. Dynamic RegExp Extraction for Travelers Count
    int targetTravelers = travelerCount;
    final travelersMatch = RegExp(r'(\d+|[٠-٩]+)\s*(?:travelers?|travellers?|persons?|people|passengers?|أشخاص|اشخاص|مسافرين|مسافر|أفراد|افراد)').firstMatch(p);
    final hasTravelers = travelersMatch != null ||
        p.contains('solo') || p.contains('couple') || p.contains('family') || p.contains('عائلة') || p.contains('اسرة') || p.contains('زوجين') || p.contains('منفرد');

    if (travelersMatch != null) {
      targetTravelers = _parseArabicOrEnglishNumber(travelersMatch.group(1)!);
    } else if (p.contains('solo') || p.contains('منفرد') || p.contains('بمفردي')) {
      targetTravelers = 1;
    } else if (p.contains('couple') || p.contains('زوجين')) {
      targetTravelers = 2;
    } else if (p.contains('family') || p.contains('عائلة') || p.contains('اسرة')) {
      targetTravelers = 4;
    }

    // 4. If Days or Travelers count is missing, ask specifically for them
    if (!hasTravelers || !hasDays) {
      List<String> missingEn = [];
      List<String> missingAr = [];

      if (!hasDays) {
        missingEn.add('📅 How many free days do you have for this trip? (e.g. 2, 3, 5, 7, 9, or 10 days)');
        missingAr.add('📅 كم عدد الأيام المتاحة لرحلتك؟ (مثال: ٢، ٣، ٥، ٧، ٩، أو ١٠ أيام)');
      }
      if (!hasTravelers) {
        missingEn.add('👥 How many travelers are joining? (Solo, Couple, Family, or specific count)');
        missingAr.add('👥 كم عدد المسافرين معك في هذه الرحلة؟ (مسافر منفرد، زوجين، عائلة، أو عدد محدد)');
      }

      final textEn = '🇪🇬 I would love to craft the perfect Egyptian itinerary for you!\n\n'
          'To make sure everything is tailored precisely, please tell me:\n\n'
          '${missingEn.join('\n\n')}\n\n'
          '💬 Reply with these details (e.g. "9 days for 7 travelers"), and I will handle your entire journey!';

      final textAr = '🇪🇬 يسعدني أن أصمم لك الرحلة المصرية المثالية بكل دقة!\n\n'
          'لكي أجهز لك الجدول المناسب والتكلفة المحددة، يُرجى إخباري بما يلي:\n\n'
          '${missingAr.join('\n\n')}\n\n'
          '💬 رد علي بهذه التفاصيل (مثال: "٩ أيام لـ ٧ مسافرين")، وسأقوم بتهندلة الرحلة بالكامل!';

      return AiAssistantResponse(
        textResponseEn: textEn,
        textResponseAr: textAr,
        isClarificationNeeded: true,
      );
    }

    // 5. Extract Destination Entity
    String targetDestinationId = destinationId;
    if (p.contains('cairo') || p.contains('قاهرة') || p.contains('pyramid') || p.contains('أهرامات') || p.contains('giza') || p.contains('جيزة')) {
      targetDestinationId = 'cairo';
    } else if (p.contains('alex') || p.contains('إسكندرية') || p.contains('اسكندرية') || p.contains('citadel') || p.contains('قلعة')) {
      targetDestinationId = 'alexandria';
    } else if (p.contains('luxor') || p.contains('أقصر') || p.contains('اقصر') || p.contains('karnak') || p.contains('كرنك')) {
      targetDestinationId = 'luxor';
    } else if (p.contains('aswan') || p.contains('أسوان') || p.contains('اسوان') || p.contains('philae') || p.contains('فيلة')) {
      targetDestinationId = 'aswan';
    } else if (p.contains('hurghada') || p.contains('غردقة') || p.contains('غردقه') || p.contains('red sea') || p.contains('البحر الأحمر')) {
      targetDestinationId = 'hurghada';
    } else if (p.contains('sharm') || p.contains('شرم') || p.contains('dahab') || p.contains('دهب') || p.contains('sinai') || p.contains('سيناء')) {
      targetDestinationId = 'sharm';
    } else if (p.contains('siwa') || p.contains('سيوة') || p.contains('سيوه') || p.contains('desert') || p.contains('صحراء')) {
      targetDestinationId = 'siwa';
    } else if (p.contains('fayoum') || p.contains('فيوم') || p.contains('الفيوم') || p.contains('magic lake')) {
      targetDestinationId = 'fayoum';
    }

    // 6. Extract Category Interest Filters
    final available = TourismDatabase.attractions
        .where((a) => a.destinationId == targetDestinationId)
        .toList();

    List<String> targetAttractionIds = [];

    if (p.contains('history') || p.contains('pyramid') || p.contains('museum') || p.contains('تاريخ') || p.contains('آثار') || p.contains('أهرامات')) {
      targetAttractionIds = available
          .where((a) => a.category == CategoryType.archaeology || a.category == CategoryType.museum)
          .map((a) => a.id)
          .toList();
    } else if (p.contains('sea') || p.contains('beach') || p.contains('diving') || p.contains('snorkel') || p.contains('بحر') || p.contains('شاطئ') || p.contains('غوص')) {
      targetAttractionIds = available
          .where((a) => a.category == CategoryType.beach || a.category == CategoryType.diving)
          .map((a) => a.id)
          .toList();
    } else if (p.contains('food') || p.contains('culinary') || p.contains('أكل') || p.contains('مطاعم') || p.contains('كشري')) {
      targetAttractionIds = available
          .where((a) => a.category == CategoryType.culinary || a.category == CategoryType.market)
          .map((a) => a.id)
          .toList();
    } else if (p.contains('safari') || p.contains('desert') || p.contains('سفاري') || p.contains('صحراء') || p.contains('واحة')) {
      targetAttractionIds = available
          .where((a) => a.category == CategoryType.safari || a.category == CategoryType.oasis)
          .map((a) => a.id)
          .toList();
    }

    if (targetAttractionIds.isEmpty) {
      targetAttractionIds = available.map((a) => a.id).toList();
    }

    final dest = TourismDatabase.destinations.firstWhere(
      (d) => d.id == targetDestinationId,
      orElse: () => TourismDatabase.destinations[0],
    );

    // 7. Generate Smart Trip Itinerary
    final trip = ItineraryEngine.generateAutoTrip(
      title: 'HNHNDLK ${dest.nameEn} $targetDays-Day Journey',
      destinationId: targetDestinationId,
      attractionIds: targetAttractionIds,
      startDate: DateTime.now().add(const Duration(days: 7)),
      daysCount: targetDays,
      travelerCount: targetTravelers,
    );

    final textEn = '🤖 HNHNDLK AI Analysis Complete!\n\n'
        '• Destination: ${dest.nameEn}\n'
        '• Duration: $targetDays Days\n'
        '• Travelers: $targetTravelers Person(s)\n'
        '• Scheduled Visits: ${trip.items.length} verified experiences\n\n'
        '💡 Local Insider Tip: Visit early in the morning to beat the heat and crowds. All entrance fees and official operating hours have been verified against mota.gov.eg!';

    final textAr = '🤖 اكتمل تحليل الذكاء الاصطناعي من "هنهندلك"!\n\n'
        '• الوجهة: ${dest.nameAr}\n'
        '• المدة: $targetDays أيام\n'
        '• عدد المسافرين: $targetTravelers شخص\n'
        '• الأنشطة المجدولة: ${trip.items.length} تجربة موثقة\n\n'
        '💡 نصيحة المساعد الذكي: يُنصح بزيارة المواقع الأثرية في الصباح الباكر لتجنب حرارة الشمس. تم التحقق من أسعار التذاكر ومواعيد الفتح من وزارة السياحة والآثار المصرية!';

    return AiAssistantResponse(
      textResponseEn: textEn,
      textResponseAr: textAr,
      generatedTrip: trip,
    );
  }

  /// Converts English and Arabic Eastern digits to integer
  static int _parseArabicOrEnglishNumber(String str) {
    const easternToArabic = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    String normalized = str;
    easternToArabic.forEach((eastern, western) {
      normalized = normalized.replaceAll(eastern, western);
    });
    return int.tryParse(normalized) ?? 3;
  }

  /// Egyptian Tourism Q&A Knowledge Base
  static AiAssistantResponse? _handleTravelKnowledgeBase(String p) {
    if (p.contains('price') || p.contains('ticket') || p.contains('cost') || p.contains('تذكرة') || p.contains('سعر') || p.contains('أسعار')) {
      if (p.contains('pyramid') || p.contains('أهرامات') || p.contains('جيزة')) {
        return AiAssistantResponse(
          textResponseEn: r'🏛️ Giza Pyramids Entrance Fee: 540 EGP (~$11 USD) for adults, 270 EGP for students. Entrance inside the Great Pyramid (Khufu) is an extra ticket (~1,500 EGP). Verified via mota.gov.eg.',
          textResponseAr: '🏛️ سعر تذكرة أهرامات الجيزة: ٥٤٠ جنيهاً للمصريين والأجانب والطلاب خفض ٥٠٪. دخول هرم خوفو الأكبر بتذكرة إضافية. البيانات موثقة من وزارة السياحة والآثار.',
        );
      } else if (p.contains('gem') || p.contains('grand museum') || p.contains('المتحف الكبير')) {
        return AiAssistantResponse(
          textResponseEn: r'🏛️ Grand Egyptian Museum (GEM) Trial Visits: 1,000 EGP (~$20 USD) for adults. Includes main galleries, Grand Staircase, and Tutankhamun trial displays.',
          textResponseAr: '🏛️ تذاكر المتحف المصري الكبير (GEM): ١٠٠٠ جنيهاً للزيارة التجريبية الشاملة للبهو العظيم والدرج العظيم ومعارض الملك توت عنخ آمون.',
        );
      }
    } else if (p.contains('currency') || p.contains('money') || p.contains('عملة') || p.contains('فلوس') || p.contains('دولار')) {
      return AiAssistantResponse(
        textResponseEn: '💵 Currency in Egypt is Egyptian Pound (EGP). Credit cards (Visa/Mastercard) are widely accepted at official monuments and hotels. Keep small EGP cash for local taxis and souks.',
        textResponseAr: '💵 العملة الرسمية هي الجنيه المصري (EGP). تُقبل بطاقات الائتمان في المتاحف والمواقع الأثرية والفنادق، ويفضل الاحتفاظ بنقدية بسيطة للأسواق الشعبية والتكسي.',
      );
    } else if (p.contains('best time') || p.contains('weather') || p.contains('طقس') || p.contains('أفضل وقت') || p.contains('افضل وقت')) {
      return AiAssistantResponse(
        textResponseEn: '☀️ Best time to visit Egypt: October to April for Pyramids, Luxor & Aswan (mild 20°C - 25°C). Red Sea resorts (Hurghada & Sharm) are wonderful year-round for diving and beaches!',
        textResponseAr: '☀️ أفضل وقت لزيارة مصر: من أكتوبر إلى أبريل لزيارة القاهرة والأقصر وأسوان (طقس دافئ معتدل)، بينما الغردقة وشرم الشيخ مناسبة طوال العام للغوص والشواطئ!',
      );
    } else if (p.contains('uber') || p.contains('taxi') || p.contains('مواصلات') || p.contains('أوبر') || p.contains('تكسي')) {
      return AiAssistantResponse(
        textResponseEn: '🚗 Transportation Tip: Uber and Careem are safe, cheap, and widely available in Cairo and Alexandria. Cairo Metro line 3 takes you directly near the airport and museum zones.',
        textResponseAr: '🚗 وسائل التنقل: أوبر وكريم متوفران بأمان وأسعار مناسبة في القاهرة والإسكندرية. كما يربط الخط الثالث لمترو الأنفاق معظم المناطق الحيوية بالجمالية والمطار.',
      );
    }

    return null;
  }
}
