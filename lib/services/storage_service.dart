import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _keyProfile = 'user_profile_data';
  static const String _keyFavorites = 'saved_favorites_list';
  static const String _keyTrips = 'user_trips_list';
  static const String _keyLocale = 'app_locale_code';
  static const String _keyCurrency = 'app_currency_code';

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyProfile);
    if (str != null) {
      try {
        return UserProfile.fromJson(jsonDecode(str));
      } catch (_) {}
    }
    return null;
  }

  static Future<void> saveFavorites(List<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, favoriteIds);
  }

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  static Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final list = trips.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_keyTrips, list);
  }

  static Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyTrips);
    if (list != null) {
      return list.map((item) {
        try {
          return Trip.fromJson(jsonDecode(item));
        } catch (_) {
          return null;
        }
      }).whereType<Trip>().toList();
    }
    return [];
  }

  static Future<void> saveSettings(String localeCode, String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, localeCode);
    await prefs.setString(_keyCurrency, currencyCode);
  }

  static Future<Map<String, String>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'locale': prefs.getString(_keyLocale) ?? 'en',
      'currency': prefs.getString(_keyCurrency) ?? 'EGP',
    };
  }
}
