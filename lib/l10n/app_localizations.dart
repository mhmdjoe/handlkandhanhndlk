import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  bool get isArabic => locale.languageCode == 'ar';

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appName': 'HNDLK W HNHNDLK',
      'appSubtitle': 'Discover Egypt. We Plan The Journey.',
      'tagline': 'You choose the experience. We help plan the journey.',
      'hndlkTitle': 'HNDLK (Discover)',
      'hndlkSubtitle': 'We show you every incredible experience in Egypt.',
      'hnhndlkTitle': 'HNHNDLK (AI Planner)',
      'hnhndlkSubtitle': 'We organize, schedule & arrange everything for you.',
      
      // Nav
      'navHome': 'Home',
      'navExplore': 'Explore',
      'navPlanner': 'AI Planner',
      'navTrips': 'My Trips',
      'navProfile': 'Profile',
      
      // Onboarding
      'onboardingWelcome': 'Welcome to Egypt',
      'onboardingDesc': 'Your all-in-one smart travel platform for discovering ancient wonders, coastal paradises, and local culture.',
      'selectLanguage': 'Choose Language / اختر اللغة',
      'getStarted': 'Get Started',
      'skipQuiz': 'Skip to Exploration',
      'quizTitle': 'Personalize Your Egyptian Trip',
      'quizSubtitle': 'Tell us your preferences so HNHNDLK can craft your ideal journey.',
      'travelStyle': 'Travel Style',
      'budgetTier': 'Budget Tier',
      'interests': 'Interests',
      
      // Home
      'searchHint': 'Search Pyramids, Luxor, Dahab, GEM...',
      'topDestinations': 'Top Destinations in Egypt',
      'popularExperiences': 'Must-Try Experiences',
      'seasonalPicks': 'Seasonal Picks for You',
      'viewAll': 'View All',
      'startPlanning': 'Try Your First Handled Trip',
      'exploreCategory': 'Explore Categories',
      'activeTrip': 'Active Trip',
      
      // Explore & Filters
      'exploreEgypt': 'Explore Egypt (HNDLK)',
      'filterTitle': 'Filter Attractions',
      'governorate': 'Governorate / City',
      'allGovernorates': 'All Egypt',
      'category': 'Category',
      'allCategories': 'All Categories',
      'priceRange': 'Price Range',
      'familySuitability': 'Family Friendly',
      'accessibility': 'Accessible',
      'mapView': 'Map View',
      'listView': 'List View',
      'resultsFound': 'results found',
      'verifiedSource': 'Official Source Verified',
      'unverifiedSource': 'Provisionally Researched',
      'entranceFee': 'Entrance Fee',
      'openingHours': 'Opening Hours',
      'duration': 'Est. Visit Duration',
      'addToTrip': 'Add to Trip',
      'saveFavorite': 'Save to Favorites',
      
      // Itinerary & Planner
      'aiPlannerTitle': 'HNHNDLK AI Travel Assistant',
      'aiPlannerHint': 'Describe your dream trip (e.g., "3 days in Cairo with history & local food under \$150")...',
      'generateItinerary': 'Generate Smart Itinerary',
      'dailySchedule': 'Daily Schedule',
      'day': 'Day',
      'estimatedCost': 'Est. Total Cost',
      'transportMethod': 'Transport',
      'travelTime': 'Travel Time',
      'conflictWarning': 'Schedule Alert: Attraction might be closed at this time!',
      'confirmTrip': 'Save to My Trips',
      'editItinerary': 'Edit Timeline',
      'reorderNote': 'Drag items to reorder your daily itinerary',
      
      // Hotels & Transport
      'hotelsTitle': 'Recommended Hotels',
      'checkIn': 'Check-in',
      'checkOut': 'Check-out',
      'rooms': 'Rooms & Guests',
      'perNight': '/ night',
      'bookNow': 'Book / Reserve',
      'transportPlanner': 'Transportation Options',
      'origin': 'Starting Point',
      'destination': 'Destination',
      'calcRoute': 'Calculate Route & Fare',
      
      // Trips & Dashboard
      'myTripsTitle': 'My Saved Trips',
      'noTripsYet': 'No trips planned yet. Let HNHNDLK organize one for you!',
      'upcomingTrips': 'Upcoming Trips',
      'pastTrips': 'Past Trips',
      'statusDraft': 'Draft',
      'statusPending': 'Pending',
      'statusConfirmed': 'Confirmed',
      
      // Profile & Admin
      'userProfile': 'User Profile',
      'favorites': 'Saved Places & Favorites',
      'settings': 'Settings',
      'currency': 'Currency',
      'adminDashboard': 'Admin Dashboard',
      'tourismDataStatus': 'Dataset Health & Sources',
      'verifiedItems': 'Verified Records',
      'guestUser': 'Guest Explorer',
      'loginRegister': 'Login or Register',
    },
    'ar': {
      'appName': 'هندلك وهنهندلك',
      'appSubtitle': 'استكشف مصر. وسيب التخطيط علينا.',
      'tagline': 'أنت اختار التجربة، وإحنا نهندلك الرحلة.',
      'hndlkTitle': 'هندلك (استكشف)',
      'hndlkSubtitle': 'هنوريك كل مكان وتجربة ساحرة تقدر تزورها في مصر.',
      'hnhndlkTitle': 'هنهندلك (المخطط الذكي)',
      'hnhndlkSubtitle': 'هنخطط ونظبطلك جدول رحلتك ومواعيدك بالكامل لاتقلق.',
      
      // Nav
      'navHome': 'الرئيسية',
      'navExplore': 'استكشف',
      'navPlanner': 'المساعد الذكي',
      'navTrips': 'رحلاتي',
      'navProfile': 'حسابي',
      
      // Onboarding
      'onboardingWelcome': 'مرحباً بك في مصر',
      'onboardingDesc': 'منصتك الذكية والشاملة لاكتشاف المعالم التاريخية، والشواطئ، والثقافة المصرية الأصيلة.',
      'selectLanguage': 'اختر اللغة / Choose Language',
      'getStarted': 'ابدأ الآن',
      'skipQuiz': 'الانتقال للاستكشاف',
      'quizTitle': 'خصص تفضيلات رحلتك',
      'quizSubtitle': 'أخبرنا بتفضيلاتك حتى يتمكن "هنهندلك" من تصميم رحلتك المثالية.',
      'travelStyle': 'أسلوب السفر',
      'budgetTier': 'الميزانية',
      'interests': 'الاهتمامات',
      
      // Home
      'searchHint': 'ابحث عن الأهرامات، الأقصر، دهب، المتحف الكبير...',
      'topDestinations': 'أبرز الوجهات في مصر',
      'popularExperiences': 'تجارب لا تُفوت',
      'seasonalPicks': 'ترشيحات الموسم لك',
      'viewAll': 'عرض الكل',
      'startPlanning': 'جرب رحلتك المنهندلة الأولى',
      'exploreCategory': 'استكشف حسب التصنيف',
      'activeTrip': 'الرحلة الحالية',
      
      // Explore & Filters
      'exploreEgypt': 'استكشف مصر (هندلك)',
      'filterTitle': 'تصفية الأماكن',
      'governorate': 'المحافظة / المدينة',
      'allGovernorates': 'كل المحافظات',
      'category': 'التصنيف',
      'allCategories': 'كل التصنيفات',
      'priceRange': 'نطاق الأسعار',
      'familySuitability': 'مناسب للعائلات',
      'accessibility': 'مناسب لكبار السن وذوي الهمم',
      'mapView': 'عرض الخريطة',
      'listView': 'عرض القائمة',
      'resultsFound': 'نتيجة موجودة',
      'verifiedSource': 'موثق من مصدر رسمي',
      'unverifiedSource': 'بيانات قيد التحقق',
      'entranceFee': 'سعر التذكرة',
      'openingHours': 'مواعيد العمل',
      'duration': 'الوقت المتوقع للزيارة',
      'addToTrip': 'إضافة إلى الرحلة',
      'saveFavorite': 'حفظ في المفضلة',
      
      // Itinerary & Planner
      'aiPlannerTitle': 'المساعد الذكي (هنهندلك)',
      'aiPlannerHint': 'اشرح رحلتك المثالية (مثال: "٣ أيام في القاهرة مع تركيز على الآثار والأكل الشعبي بميزانية متوسطة")...',
      'generateItinerary': 'إنشاء جدول الرحلة الذكي',
      'dailySchedule': 'الجدول اليومي',
      'day': 'اليوم',
      'estimatedCost': 'التكلفة الإجمالية التقديرية',
      'transportMethod': 'وسيلة التنقل',
      'travelTime': 'زمن التنقل',
      'conflictWarning': 'تنبيه: المكان قد يكون مغلقاً في هذا التوقيت!',
      'confirmTrip': 'حفظ في رحلاتي',
      'editItinerary': 'تعديل الجدول الزمني',
      'reorderNote': 'اسحب الأنشطة لإعادة ترتيب جدولك اليومي',
      
      // Hotels & Transport
      'hotelsTitle': 'الفنادق والإقامات المقترحة',
      'checkIn': 'تاريخ الوصول',
      'checkOut': 'تاريخ المغادرة',
      'rooms': 'الغرف والضيوف',
      'perNight': '/ ليلة',
      'bookNow': 'احجز / حجز مبدئي',
      'transportPlanner': 'خيارات وسائل المواصلات',
      'origin': 'نقطة الانطلاق',
      'destination': 'الوجهة',
      'calcRoute': 'حساب المسار والتكلفة',
      
      // Trips & Dashboard
      'myTripsTitle': 'رحلاتي المحفوظة',
      'noTripsYet': 'لا توجد رحلات حتى الآن. دع "هنهندلك" ينظم لك أول رحلة!',
      'upcomingTrips': 'الرحلات القادمة',
      'pastTrips': 'الرحلات السابقة',
      'statusDraft': 'مسودة',
      'statusPending': 'قيد التأكيد',
      'statusConfirmed': 'مؤكدة',
      
      // Profile & Admin
      'userProfile': 'الملف الشخصي',
      'favorites': 'الأماكن المحفوظة والمفضلة',
      'settings': 'الإعدادات',
      'currency': 'العملة',
      'adminDashboard': 'لوحة التحكم الإدارية',
      'tourismDataStatus': 'سلامة ومصادر قاعدة البيانات',
      'verifiedItems': 'سجلات موثقة',
      'guestUser': 'زائر مستكشف',
      'loginRegister': 'تسجيل الدخول أو إنشاء حساب',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
