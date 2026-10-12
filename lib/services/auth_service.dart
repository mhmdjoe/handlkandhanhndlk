import '../models/models.dart';

class AuthService {
  static Future<UserProfile> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    return UserProfile(
      email: email,
      name: email.split('@').first.capitalize(),
      preferredLanguage: 'en',
      preferredCurrency: 'EGP',
    );
  }

  static Future<UserProfile> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserProfile(
      email: email,
      name: name,
      preferredLanguage: 'en',
      preferredCurrency: 'EGP',
    );
  }

  static UserProfile createGuestUser() {
    return UserProfile(
      email: 'guest@hndlk.eg',
      name: 'Guest Explorer',
      preferredLanguage: 'en',
      preferredCurrency: 'EGP',
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
