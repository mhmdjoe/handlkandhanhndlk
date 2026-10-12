import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/tourism_database.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  String _currency = 'EGP';
  UserProfile _userProfile = UserProfile(email: 'guest@hndlk.eg', name: 'Guest Explorer');
  
  List<String> _favoriteIds = [];
  List<Trip> _userTrips = [];
  
  // Search & Filter state
  String _selectedDestinationId = 'all';
  CategoryType? _selectedCategory;
  bool _filterFamilyOnly = false;
  bool _filterAccessibleOnly = false;
  String _searchQuery = '';

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get currency => _currency;
  UserProfile get userProfile => _userProfile;
  List<String> get favoriteIds => _favoriteIds;
  List<Trip> get userTrips => _userTrips;
  
  String get selectedDestinationId => _selectedDestinationId;
  CategoryType? get selectedCategory => _selectedCategory;
  bool get filterFamilyOnly => _filterFamilyOnly;
  bool get filterAccessibleOnly => _filterAccessibleOnly;
  String get searchQuery => _searchQuery;

  AppProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    final settings = await StorageService.loadSettings();
    _locale = Locale(settings['locale'] ?? 'en');
    _currency = settings['currency'] ?? 'EGP';

    final loadedProfile = await StorageService.loadProfile();
    if (loadedProfile != null) {
      _userProfile = loadedProfile;
    }

    _favoriteIds = await StorageService.loadFavorites();
    _userTrips = await StorageService.loadTrips();

    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    StorageService.saveSettings(_locale.languageCode, _currency);
    notifyListeners();
  }

  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    StorageService.saveSettings(_locale.languageCode, _currency);
    notifyListeners();
  }

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    StorageService.saveProfile(_userProfile);
    notifyListeners();
  }

  void toggleFavorite(String attractionId) {
    if (_favoriteIds.contains(attractionId)) {
      _favoriteIds.remove(attractionId);
    } else {
      _favoriteIds.add(attractionId);
    }
    StorageService.saveFavorites(_favoriteIds);
    notifyListeners();
  }

  bool isFavorite(String attractionId) {
    return _favoriteIds.contains(attractionId);
  }

  void addTrip(Trip trip) {
    _userTrips.insert(0, trip);
    StorageService.saveTrips(_userTrips);
    notifyListeners();
  }

  void updateTrip(Trip updatedTrip) {
    final index = _userTrips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      _userTrips[index] = updatedTrip;
      StorageService.saveTrips(_userTrips);
      notifyListeners();
    }
  }

  void removeTrip(String tripId) {
    _userTrips.removeWhere((t) => t.id == tripId);
    StorageService.saveTrips(_userTrips);
    notifyListeners();
  }

  void setDestinationFilter(String destId) {
    _selectedDestinationId = destId;
    notifyListeners();
  }

  void setCategoryFilter(CategoryType? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setFamilyFilter(bool val) {
    _filterFamilyOnly = val;
    notifyListeners();
  }

  void setAccessibleFilter(bool val) {
    _filterAccessibleOnly = val;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedDestinationId = 'all';
    _selectedCategory = null;
    _filterFamilyOnly = false;
    _filterAccessibleOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  List<Attraction> get filteredAttractions {
    return TourismDatabase.attractions.where((a) {
      if (_selectedDestinationId != 'all' && a.destinationId != _selectedDestinationId) {
        return false;
      }
      if (_selectedCategory != null && a.category != _selectedCategory) {
        return false;
      }
      if (_filterFamilyOnly && !a.isFamilyFriendly) {
        return false;
      }
      if (_filterAccessibleOnly && !a.isAccessible) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchEn = a.nameEn.toLowerCase().contains(q);
        final matchAr = a.nameAr.contains(q);
        final matchGov = a.governorateEn.toLowerCase().contains(q) || a.governorateAr.contains(q);
        if (!matchEn && !matchAr && !matchGov) return false;
      }
      return true;
    }).toList();
  }

  String formatPrice(double priceEgp, double priceUsd) {
    switch (_currency) {
      case 'USD':
        return '\$${priceUsd.toStringAsFixed(0)}';
      case 'EUR':
        return '€${(priceUsd * 0.92).toStringAsFixed(0)}';
      case 'GBP':
        return '£${(priceUsd * 0.79).toStringAsFixed(0)}';
      case 'EGP':
      default:
        return '${priceEgp.toStringAsFixed(0)} ${isArabic ? 'ج.م' : 'EGP'}';
    }
  }
}
