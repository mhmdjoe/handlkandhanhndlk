import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../services/itinerary_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/glassmorphic_container.dart';
import '../navigation_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _step = 0; // 0: Welcome & Lang, 1: Quiz
  String _selectedStyle = 'History & Culture';
  String _selectedBudget = 'Moderate';
  int _selectedDaysCount = 3; // Default 3 free days

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getBackgroundForStyle() {
    switch (_selectedStyle) {
      case 'Beach & Diving':
        return 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=1000&auto=format&fit=crop';
      case 'Desert & Safari':
        return 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=1000&auto=format&fit=crop';
      case 'Luxury & Nile':
        return 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?q=80&w=1000&auto=format&fit=crop';
      case 'History & Culture':
      default:
        return 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?q=80&w=1000&auto=format&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final loc = AppLocalizations.of(context);
    final isAr = appProvider.isArabic;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F141A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Responsive Full-Screen Egyptian Destination Photo (100% Clear View)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: SafeNetworkImage(
                  key: ValueKey(_getBackgroundForStyle()),
                  imageUrl: _getBackgroundForStyle(),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),

          // Clean Subtle Dark Vignette Overlay (Zero Purple Tint for Maximum Clarity)
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.40),
                  Colors.black.withValues(alpha: 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main Animated Content Body
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
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
                                // Top Header Bar with Official Logo & Language Switcher
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/logo.png',
                                          height: 52,
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.high,
                                          errorBuilder: (_, _, _) => const Icon(Icons.auto_awesome_rounded, color: AppColors.papyrusGold, size: 28),
                                        ),
                                      ],
                                    ),
                                    GlassContainer(
                                      blurSigma: 10,
                                      padding: EdgeInsets.zero,
                                      borderRadius: BorderRadius.circular(20),
                                      tintColor: Colors.white.withValues(alpha: 0.12),
                                      child: TextButton.icon(
                                        onPressed: () {
                                          final next = appProvider.isArabic
                                              ? const Locale('en')
                                              : const Locale('ar');
                                          appProvider.setLocale(next);
                                        },
                                        icon: const Icon(Icons.language_rounded, color: Colors.white, size: 18),
                                        label: Text(
                                          appProvider.isArabic ? 'English' : 'العربية',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Animated Step Transition
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: _step == 0
                                      ? _buildWelcomeStep0(loc, appProvider)
                                      : _buildQuizStep1(loc, appProvider, isAr),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep0(AppLocalizations loc, AppProvider appProvider) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Card with Official Transparent Logo
        GlassContainer(
          blurSigma: 15,
          tintColor: Colors.black.withValues(alpha: 0.35),
          borderColor: AppColors.papyrusGold.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 72,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.papyrusGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.papyrusGold, width: 1.5),
                  ),
                  child: const Icon(Icons.explore_rounded, size: 48, color: AppColors.papyrusGold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.translate('onboardingWelcome'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
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
                  height: 1.4,
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
          icon: Icons.search_rounded,
          color: AppColors.primaryPurple,
        ),
        const SizedBox(height: 12),
        _buildPromiseCard(
          title: loc.translate('hnhndlkTitle'),
          subtitle: loc.translate('hnhndlkSubtitle'),
          icon: Icons.auto_awesome_rounded,
          color: AppColors.primaryOrange,
        ),
        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _step = 1;
              _animController.reset();
              _animController.forward();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.primaryOrange.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            loc.translate('getStarted'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStep1(AppLocalizations loc, AppProvider appProvider, bool isAr) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.translate('quizTitle'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.lightPurple, // Purple Title #EDE5FF
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.translate('quizSubtitle'),
          style: const TextStyle(fontSize: 14, color: AppColors.desertSand),
        ),
        const SizedBox(height: 20),

        // Free Trip Days Question Heading in Purple (#EDE5FF)
        Text(
          isAr ? 'كم عدد الأيام المتاحة لرحلتك؟' : 'How many free days for your trip?',
          style: const TextStyle(fontSize: 16, color: AppColors.lightPurple, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [2, 3, 5, 7, 10].map((days) {
            final labelText = '$days ${isAr ? 'أيام' : 'Days'}';
            return _buildCustomChip(
              label: labelText,
              isSelected: _selectedDaysCount == days,
              onTap: () => setState(() => _selectedDaysCount = days),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Style Selector Question Heading in Purple (#EDE5FF)
        Text(
          loc.translate('travelStyle'),
          style: const TextStyle(fontSize: 16, color: AppColors.lightPurple, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
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

        // Budget Selector Question Heading in Purple (#EDE5FF)
        Text(
          loc.translate('budgetTier'),
          style: const TextStyle(fontSize: 16, color: AppColors.lightPurple, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: ['Budget', 'Moderate', 'Luxury'].map((b) {
            return _buildCustomChip(
              label: b,
              isSelected: _selectedBudget == b,
              onTap: () => setState(() => _selectedBudget = b),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Action Button in Primary Purple (#4300C8)
        ElevatedButton(
          onPressed: () => _showTravelersSelectionModal(context, appProvider, loc),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple, // Deep Purple #4300C8
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.primaryPurple.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }

  void _showTravelersSelectionModal(BuildContext context, AppProvider appProvider, AppLocalizations loc) {
    int tempTravelers = 2; // Default 2 travelers
    final isAr = appProvider.isArabic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  Row(
                    children: [
                      const Icon(Icons.people_alt_rounded, color: AppColors.primaryPurple, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isAr ? 'كم عدد المسافرين في هذه الرحلة؟' : 'How many travelers are joining?',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryPurple),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'اختر عدد الأشخاص لحساب التكاليف وتجهيز التذاكر بإنسب سعر.' : 'Choose the number of travelers to calculate total entry fees and arrangements.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Traveler Count Selection Chips in Vibrant Orange (#FF5008)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      1, 2, 3, 4, 5, 6
                    ].map((count) {
                      final isSel = tempTravelers == count;
                      final label = count == 1
                          ? (isAr ? '1 مسافر منفرد' : '1 Solo')
                          : count == 2
                              ? (isAr ? '2 مسافران (زوجين)' : '2 Pair / Couple')
                              : '$count ${isAr ? 'مسافرين' : 'Travelers'}';

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSel,
                        selectedColor: AppColors.primaryOrange, // Vibrant Orange #FF5008
                        backgroundColor: AppColors.desertSand,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.charcoal,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        onSelected: (_) => setModalState(() => tempTravelers = count),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close modal
                      _generateTripWithParams(appProvider, loc, tempTravelers);
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(isAr ? 'تأكيد وإنشاء الرحلة المنهندلة' : 'Confirm & Generate Handled Trip'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _generateTripWithParams(AppProvider appProvider, AppLocalizations loc, int travelerCount) {
    final profile = appProvider.userProfile.copyWith(
      travelStyle: _selectedStyle,
      budgetTier: _selectedBudget,
    );
    appProvider.setUserProfile(profile);

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
      title: 'Handelak $_selectedStyle Journey',
      destinationId: destinationId,
      attractionIds: attractionIds,
      startDate: DateTime.now().add(const Duration(days: 7)),
      daysCount: _selectedDaysCount, // Use selected free days
      travelerCount: travelerCount,   // Use selected travelers count from popup menu!
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

  // Answer Options Chips in Vibrant Logo Orange (#FF5008)
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
          color: isSelected ? AppColors.primaryOrange : Colors.black.withValues(alpha: 0.30), // Vibrant Orange #FF5008
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.white.withValues(alpha: 0.35),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
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
    return GlassContainer(
      blurSigma: 12,
      tintColor: Colors.black.withValues(alpha: 0.35),
      borderColor: color.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 24,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
