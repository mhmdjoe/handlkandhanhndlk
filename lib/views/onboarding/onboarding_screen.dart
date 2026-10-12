import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../services/itinerary_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../navigation_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0; // 0: Welcome & Lang, 1: Quiz
  String _selectedStyle = 'History & Culture';
  String _selectedBudget = 'Moderate';

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.nileTeal,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.nileTeal, Color(0xFF031220)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar with Language Switcher
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'HNDLK W HNHNDLK',
                              style: TextStyle(
                                color: AppColors.papyrusGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final next = appProvider.isArabic
                                    ? const Locale('en')
                                    : const Locale('ar');
                                appProvider.setLocale(next);
                              },
                              icon: const Icon(Icons.language, color: Colors.white, size: 18),
                              label: Text(
                                appProvider.isArabic ? 'English' : 'العربية',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_step == 0) ...[
                          // Brand Promise & Welcome
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.papyrusGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.papyrusGold.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.explore_rounded, size: 56, color: AppColors.papyrusGold),
                                const SizedBox(height: 16),
                                Text(
                                  loc.translate('onboardingWelcome'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc.translate('tagline'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.desertSand,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dual Promise Cards
                          _buildPromiseCard(
                            title: loc.translate('hndlkTitle'),
                            subtitle: loc.translate('hndlkSubtitle'),
                            icon: Icons.search_outlined,
                            color: AppColors.seaTurquoise,
                          ),
                          const SizedBox(height: 12),
                          _buildPromiseCard(
                            title: loc.translate('hnhndlkTitle'),
                            subtitle: loc.translate('hnhndlkSubtitle'),
                            icon: Icons.auto_awesome_rounded,
                            color: AppColors.terracotta,
                          ),
                          const Spacer(),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () => setState(() => _step = 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.papyrusGold,
                              foregroundColor: AppColors.nileTeal,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              loc.translate('getStarted'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ] else ...[
                          // Preference Quiz
                          Text(
                            loc.translate('quizTitle'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate('quizSubtitle'),
                            style: const TextStyle(fontSize: 14, color: AppColors.desertSand),
                          ),
                          const SizedBox(height: 24),

                          // Style Selector
                          Text(
                            loc.translate('travelStyle'),
                            style: const TextStyle(fontSize: 16, color: AppColors.papyrusGold, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              'History & Culture',
                              'Beach & Diving',
                              'Desert & Safari',
                              'Luxury & Nile',
                            ].map((style) {
                              return _buildCustomChip(
                                label: style,
                                isSelected: _selectedStyle == style,
                                onTap: () => setState(() => _selectedStyle = style),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Budget Selector
                          Text(
                            loc.translate('budgetTier'),
                            style: const TextStyle(fontSize: 16, color: AppColors.papyrusGold, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Budget', 'Moderate', 'Luxury'].map((b) {
                              return _buildCustomChip(
                                label: b,
                                isSelected: _selectedBudget == b,
                                onTap: () => setState(() => _selectedBudget = b),
                              );
                            }).toList(),
                          ),
                          const Spacer(),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () => _handleCreateCustomizedTrip(appProvider, loc),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.papyrusGold,
                              foregroundColor: AppColors.nileTeal,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              loc.translate('startPlanning'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const NavigationShell()),
                              );
                            },
                            child: Text(
                              loc.translate('skipQuiz'),
                              style: const TextStyle(color: AppColors.desertSand),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleCreateCustomizedTrip(AppProvider appProvider, AppLocalizations loc) {
    final profile = appProvider.userProfile.copyWith(
      travelStyle: _selectedStyle,
      budgetTier: _selectedBudget,
    );
    appProvider.setUserProfile(profile);

    // Map user's chosen style to target destination & attractions
    String destinationId = 'cairo';
    List<String> attractionIds = [];

    if (_selectedStyle.contains('Beach') || _selectedStyle.contains('Diving')) {
      destinationId = 'hurghada';
      attractionIds = TourismDatabase.attractions
          .where((a) => a.destinationId == 'hurghada' || a.category == CategoryType.diving)
          .map((a) => a.id)
          .toList();
    } else if (_selectedStyle.contains('Desert') || _selectedStyle.contains('Safari')) {
      destinationId = 'siwa';
      attractionIds = TourismDatabase.attractions
          .where((a) => a.destinationId == 'siwa' || a.category == CategoryType.oasis)
          .map((a) => a.id)
          .toList();
    } else if (_selectedStyle.contains('Luxury') || _selectedStyle.contains('Nile')) {
      destinationId = 'luxor';
      attractionIds = TourismDatabase.attractions
          .where((a) => a.destinationId == 'luxor' || a.destinationId == 'aswan')
          .map((a) => a.id)
          .toList();
    } else {
      destinationId = 'cairo';
      attractionIds = TourismDatabase.attractions
          .where((a) => a.destinationId == 'cairo')
          .map((a) => a.id)
          .toList();
    }

    final trip = ItineraryEngine.generateAutoTrip(
      title: 'HNHNDLK $_selectedStyle Journey',
      destinationId: destinationId,
      attractionIds: attractionIds,
      startDate: DateTime.now().add(const Duration(days: 7)),
      daysCount: 3,
      travelerCount: 2,
    );

    appProvider.addTrip(trip);

    // Navigate to My Trips tab directly with the generated trip
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NavigationShell(initialIndex: 3),
      ),
    );
  }

  Widget _buildCustomChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.papyrusGold.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.papyrusGold : Colors.white.withValues(alpha: 0.35),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle_rounded, color: AppColors.papyrusGold, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, // Crisp white text always
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            radius: 24,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
