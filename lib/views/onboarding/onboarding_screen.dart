import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../data/tourism_database.dart';
import '../../models/models.dart';
import '../../services/itinerary_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_motion.dart';
import '../../widgets/apple_touchable.dart';
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
  late ScrollController _scrollController;

  bool _showHeaderLogo = false;
  int _step = 0;
  String _selectedStyle = 'History & Culture';
  String _selectedBudget = 'Moderate';
  int _selectedDaysCount = 3;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 80 && !_showHeaderLogo) {
        setState(() => _showHeaderLogo = true);
      } else if (_scrollController.offset <= 80 && _showHeaderLogo) {
        setState(() => _showHeaderLogo = false);
      }
    });

    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: AppCurves.fadeEntrance,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: AppCurves.springSnappy,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          // Full-Screen Egyptian Destination Photo
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: AppDurations.medium,
              switchInCurve: AppCurves.appleEase,
              switchOutCurve: AppCurves.appleEase,
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

          // Clean Subtle Dark Vignette Overlay
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
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header Bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      'assets/images/handelak_mark.png',
                                      height: 48,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (_, _, _) => const Icon(Icons.auto_awesome_rounded, color: AppColors.papyrusGold, size: 28),
                                    ),
                                    GlassContainer(
                                      blurSigma: 10,
                                      padding: EdgeInsets.zero,
                                      borderRadius: BorderRadius.circular(20),
                                      tintColor: Colors.white.withValues(alpha: 0.12),
                                      child: AppleTouchable(
                                        onTap: () {
                                          final next = appProvider.isArabic
                                              ? const Locale('en')
                                              : const Locale('ar');
                                          appProvider.setLocale(next);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.language_rounded, color: Colors.white, size: 18),
                                              const SizedBox(width: 6),
                                              Text(
                                                appProvider.isArabic ? 'English' : 'العربية',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Animated Step Transition
                                AnimatedSwitcher(
                                  duration: AppDurations.medium,
                                  switchInCurve: AppCurves.springSnappy,
                                  switchOutCurve: AppCurves.appleEase,
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
        GlassContainer(
          blurSigma: 15,
          tintColor: Colors.black.withValues(alpha: 0.35),
          borderColor: AppColors.papyrusGold.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Image.asset(
                'assets/images/handelak_logo.png',
                height: 100,
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
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('tagline'),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightPurple,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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

        AppleTouchable(
          onTap: () {
            setState(() {
              _step = 1;
              _animController.reset();
              _animController.forward();
            });
          },
          child: ElevatedButton(
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
            color: AppColors.lightPurple,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc.translate('quizSubtitle'),
          style: const TextStyle(fontSize: 14, color: AppColors.desertSand),
        ),
        const SizedBox(height: 20),

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

        AppleTouchable(
          onTap: () => _showTravelersSelectionModal(context, appProvider, loc),
          child: ElevatedButton(
            onPressed: () => _showTravelersSelectionModal(context, appProvider, loc),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
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
        ),
        const SizedBox(height: 8),
        AppleTouchable(
          onTap: () {
            Navigator.pushReplacement(
              context,
              AppCupertinoPageRoute(page: const NavigationShell()),
            );
          },
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                AppCupertinoPageRoute(page: const NavigationShell()),
              );
            },
            child: Text(
              loc.translate('skipQuiz'),
              style: const TextStyle(color: AppColors.lightPurple, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _showTravelersSelectionModal(BuildContext context, AppProvider appProvider, AppLocalizations loc) {
    int tempTravelers = 2;
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryPurple, letterSpacing: -0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'اختر عدد الأشخاص لحساب التكاليف وتجهيز التذاكر بإنسب سعر.' : 'Choose the number of travelers to calculate total entry fees and arrangements.',
                    style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [1, 2, 3, 4, 5, 6].map((count) {
                      final isSel = tempTravelers == count;
                      final label = count == 1
                          ? (isAr ? '1 مسافر منفرد' : '1 Solo')
                          : count == 2
                              ? (isAr ? '2 مسافران (زوجين)' : '2 Pair / Couple')
                              : '$count ${isAr ? 'مسافرين' : 'Travelers'}';

                      return AppleTouchable(
                        pressedScale: 0.92,
                        onTap: () => setModalState(() => tempTravelers = count),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSel,
                          onSelected: null,
                          selectedColor: AppColors.primaryOrange,
                          backgroundColor: AppColors.lightPurple,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.darkGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  AppleTouchable(
                    onTap: () {
                      Navigator.pop(context);
                      _generateTripWithParams(appProvider, loc, tempTravelers);
                    },
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _generateTripWithParams(appProvider, loc, tempTravelers);
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: Text(isAr ? 'تأكيد وإنشاء الرحلة المنهندلة' : 'Confirm & Generate Handled Trip'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.primaryPurple,
                      ),
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
      daysCount: _selectedDaysCount,
      travelerCount: travelerCount,
    );

    appProvider.addTrip(trip);

    Navigator.pushReplacement(
      context,
      AppCupertinoPageRoute(
        page: const NavigationShell(initialIndex: 3),
      ),
    );
  }

  Widget _buildCustomChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AppleTouchable(
      pressedScale: 0.92,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.ultraFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.black.withValues(alpha: 0.30),
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
                color: Colors.white,
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
