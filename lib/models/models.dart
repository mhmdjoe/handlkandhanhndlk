enum CategoryType {
  archaeology,
  museum,
  beach,
  diving,
  safari,
  culinary,
  religious,
  market,
  oasis,
  nature,
  nileCruise,
  family,
}

extension CategoryTypeExtension on CategoryType {
  String get nameEn {
    switch (this) {
      case CategoryType.archaeology: return 'Archaeological Site';
      case CategoryType.museum: return 'Museum & Culture';
      case CategoryType.beach: return 'Beach & Resort';
      case CategoryType.diving: return 'Diving & Snorkeling';
      case CategoryType.safari: return 'Desert Safari & Camping';
      case CategoryType.culinary: return 'Local Food & Dining';
      case CategoryType.religious: return 'Religious & Spiritual';
      case CategoryType.market: return 'Traditional Souk & Shopping';
      case CategoryType.oasis: return 'Oasis & Natural Reserve';
      case CategoryType.nature: return 'Nature & Hiking';
      case CategoryType.nileCruise: return 'Nile Cruise & Boating';
      case CategoryType.family: return 'Family & Entertainment';
    }
  }

  String get nameAr {
    switch (this) {
      case CategoryType.archaeology: return 'موقع أثري';
      case CategoryType.museum: return 'متحف وثقافة';
      case CategoryType.beach: return 'شاطئ ومنتجع';
      case CategoryType.diving: return 'غوص وسنوركلنج';
      case CategoryType.safari: return 'سفاري وصحراء';
      case CategoryType.culinary: return 'مأكولات شعبية';
      case CategoryType.religious: return 'معالم دينية';
      case CategoryType.market: return 'أسواق شعبية وتسوق';
      case CategoryType.oasis: return 'واحات ومحميات';
      case CategoryType.nature: return 'طبيعة ومغامرات';
      case CategoryType.nileCruise: return 'رحلات نيلية';
      case CategoryType.family: return 'ترفيه وعائلات';
    }
  }
}

class Destination {
  final String id;
  final String nameEn;
  final String nameAr;
  final String governorateEn;
  final String governorateAr;
  final String descriptionEn;
  final String descriptionAr;
  final String imageUrl;
  final double lat;
  final double lng;
  final bool isPopular;
  final List<String> highlights;

  const Destination({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.governorateEn,
    required this.governorateAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    this.isPopular = false,
    required this.highlights,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'governorateEn': governorateEn,
    'governorateAr': governorateAr,
    'descriptionEn': descriptionEn,
    'descriptionAr': descriptionAr,
    'imageUrl': imageUrl,
    'lat': lat,
    'lng': lng,
    'isPopular': isPopular,
    'highlights': highlights,
  };

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    id: json['id'],
    nameEn: json['nameEn'],
    nameAr: json['nameAr'],
    governorateEn: json['governorateEn'],
    governorateAr: json['governorateAr'],
    descriptionEn: json['descriptionEn'],
    descriptionAr: json['descriptionAr'],
    imageUrl: json['imageUrl'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    isPopular: json['isPopular'] ?? false,
    highlights: List<String>.from(json['highlights'] ?? []),
  );
}

class Attraction {
  final String id;
  final String nameEn;
  final String nameAr;
  final String destinationId;
  final String governorateEn;
  final String governorateAr;
  final CategoryType category;
  final String descriptionEn;
  final String descriptionAr;
  final double priceEgp;
  final double priceUsd;
  final String openingTime; // e.g., "08:00"
  final String closingTime; // e.g., "17:00"
  final int estimatedDurationMinutes;
  final bool isOfficialVerified;
  final String verifiedSource;
  final String verificationDate;
  final double lat;
  final double lng;
  final String imageUrl;
  final bool isFamilyFriendly;
  final bool isAccessible;
  final String tipsEn;
  final String tipsAr;

  const Attraction({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.destinationId,
    required this.governorateEn,
    required this.governorateAr,
    required this.category,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.priceEgp,
    required this.priceUsd,
    required this.openingTime,
    required this.closingTime,
    required this.estimatedDurationMinutes,
    this.isOfficialVerified = true,
    required this.verifiedSource,
    required this.verificationDate,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    this.isFamilyFriendly = true,
    this.isAccessible = true,
    required this.tipsEn,
    required this.tipsAr,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameAr': nameAr,
    'destinationId': destinationId,
    'governorateEn': governorateEn,
    'governorateAr': governorateAr,
    'category': category.index,
    'descriptionEn': descriptionEn,
    'descriptionAr': descriptionAr,
    'priceEgp': priceEgp,
    'priceUsd': priceUsd,
    'openingTime': openingTime,
    'closingTime': closingTime,
    'estimatedDurationMinutes': estimatedDurationMinutes,
    'isOfficialVerified': isOfficialVerified,
    'verifiedSource': verifiedSource,
    'verificationDate': verificationDate,
    'lat': lat,
    'lng': lng,
    'imageUrl': imageUrl,
    'isFamilyFriendly': isFamilyFriendly,
    'isAccessible': isAccessible,
    'tipsEn': tipsEn,
    'tipsAr': tipsAr,
  };

  factory Attraction.fromJson(Map<String, dynamic> json) => Attraction(
    id: json['id'],
    nameEn: json['nameEn'],
    nameAr: json['nameAr'],
    destinationId: json['destinationId'],
    governorateEn: json['governorateEn'],
    governorateAr: json['governorateAr'],
    category: CategoryType.values[json['category'] ?? 0],
    descriptionEn: json['descriptionEn'],
    descriptionAr: json['descriptionAr'],
    priceEgp: (json['priceEgp'] as num).toDouble(),
    priceUsd: (json['priceUsd'] as num).toDouble(),
    openingTime: json['openingTime'],
    closingTime: json['closingTime'],
    estimatedDurationMinutes: json['estimatedDurationMinutes'],
    isOfficialVerified: json['isOfficialVerified'] ?? true,
    verifiedSource: json['verifiedSource'],
    verificationDate: json['verificationDate'],
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    imageUrl: json['imageUrl'],
    isFamilyFriendly: json['isFamilyFriendly'] ?? true,
    isAccessible: json['isAccessible'] ?? true,
    tipsEn: json['tipsEn'] ?? '',
    tipsAr: json['tipsAr'] ?? '',
  );
}

class Hotel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String cityEn;
  final String cityAr;
  final int starRating;
  final double pricePerNightEgp;
  final double pricePerNightUsd;
  final List<String> amenities;
  final String imageUrl;
  final double lat;
  final double lng;
  final double guestRating;

  const Hotel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.cityEn,
    required this.cityAr,
    required this.starRating,
    required this.pricePerNightEgp,
    required this.pricePerNightUsd,
    required this.amenities,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.guestRating,
  });
}

class TransportOption {
  final String id;
  final String mode; // e.g. "Private Driver", "Uber / Taxi", "Metro / Train", "Nile Ferry", "Domestic Flight"
  final String titleEn;
  final String titleAr;
  final int estimatedDurationMinutes;
  final double priceEgp;
  final double priceUsd;
  final String notesEn;
  final String notesAr;

  const TransportOption({
    required this.id,
    required this.mode,
    required this.titleEn,
    required this.titleAr,
    required this.estimatedDurationMinutes,
    required this.priceEgp,
    required this.priceUsd,
    required this.notesEn,
    required this.notesAr,
  });
}

class ItineraryItem {
  final String id;
  final String attractionId;
  final int dayNumber;
  final String startTime; // "09:00"
  final String endTime;   // "11:30"
  final String notes;
  final TransportOption? transportToNext;

  ItineraryItem({
    required this.id,
    required this.attractionId,
    required this.dayNumber,
    required this.startTime,
    required this.endTime,
    this.notes = '',
    this.transportToNext,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'attractionId': attractionId,
    'dayNumber': dayNumber,
    'startTime': startTime,
    'endTime': endTime,
    'notes': notes,
  };

  factory ItineraryItem.fromJson(Map<String, dynamic> json) => ItineraryItem(
    id: json['id'],
    attractionId: json['attractionId'],
    dayNumber: json['dayNumber'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    notes: json['notes'] ?? '',
  );
}

class Trip {
  final String id;
  final String title;
  final String destinationId;
  final DateTime startDate;
  final DateTime endDate;
  final List<ItineraryItem> items;
  final double totalCostEgp;
  final double totalCostUsd;
  final String status; // "Active Journey", "Confirmed", "Planned"
  final int travelerCount;
  final String? selectedHotelId;
  final String hotelBudgetTier; // "Budget", "Moderate", "Luxury", "Eco Lodge"

  Trip({
    required this.id,
    required this.title,
    required this.destinationId,
    required this.startDate,
    required this.endDate,
    required this.items,
    required this.totalCostEgp,
    required this.totalCostUsd,
    this.status = 'Active Journey',
    this.travelerCount = 1,
    this.selectedHotelId,
    this.hotelBudgetTier = 'Moderate',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'destinationId': destinationId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'totalCostEgp': totalCostEgp,
    'totalCostUsd': totalCostUsd,
    'status': status,
    'travelerCount': travelerCount,
    'selectedHotelId': selectedHotelId,
    'hotelBudgetTier': hotelBudgetTier,
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'],
    title: json['title'],
    destinationId: json['destinationId'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    items: (json['items'] as List).map((i) => ItineraryItem.fromJson(i)).toList(),
    totalCostEgp: (json['totalCostEgp'] as num).toDouble(),
    totalCostUsd: (json['totalCostUsd'] as num).toDouble(),
    status: json['status'] ?? 'Active Journey',
    travelerCount: json['travelerCount'] ?? 1,
    selectedHotelId: json['selectedHotelId'],
    hotelBudgetTier: json['hotelBudgetTier'] ?? 'Moderate',
  );
}

class UserProfile {
  final String email;
  final String name;
  final String preferredLanguage; // 'en' or 'ar'
  final String preferredCurrency; // 'EGP', 'USD', 'EUR', 'GBP'
  final String travelStyle;       // 'History & Culture', 'Relaxation & Beach', 'Adventure', 'Luxury'
  final String budgetTier;        // 'Budget', 'Moderate', 'Luxury'
  final List<String> savedAttractionIds;
  final List<String> savedHotelIds;

  UserProfile({
    required this.email,
    required this.name,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'EGP',
    this.travelStyle = 'History & Culture',
    this.budgetTier = 'Moderate',
    this.savedAttractionIds = const [],
    this.savedHotelIds = const [],
  });

  UserProfile copyWith({
    String? email,
    String? name,
    String? preferredLanguage,
    String? preferredCurrency,
    String? travelStyle,
    String? budgetTier,
    List<String>? savedAttractionIds,
    List<String>? savedHotelIds,
  }) {
    return UserProfile(
      email: email ?? this.email,
      name: name ?? this.name,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      travelStyle: travelStyle ?? this.travelStyle,
      budgetTier: budgetTier ?? this.budgetTier,
      savedAttractionIds: savedAttractionIds ?? this.savedAttractionIds,
      savedHotelIds: savedHotelIds ?? this.savedHotelIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'preferredLanguage': preferredLanguage,
    'preferredCurrency': preferredCurrency,
    'travelStyle': travelStyle,
    'budgetTier': budgetTier,
    'savedAttractionIds': savedAttractionIds,
    'savedHotelIds': savedHotelIds,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    email: json['email'] ?? 'guest@hndlk.eg',
    name: json['name'] ?? 'Guest Explorer',
    preferredLanguage: json['preferredLanguage'] ?? 'en',
    preferredCurrency: json['preferredCurrency'] ?? 'EGP',
    travelStyle: json['travelStyle'] ?? 'History & Culture',
    budgetTier: json['budgetTier'] ?? 'Moderate',
    savedAttractionIds: List<String>.from(json['savedAttractionIds'] ?? []),
    savedHotelIds: List<String>.from(json['savedHotelIds'] ?? []),
  );
}
