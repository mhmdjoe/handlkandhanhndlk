import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_motion.dart';
import '../widgets/apple_touchable.dart';
import 'home/home_screen.dart';
import 'explore/explore_screen.dart';
import 'planner/ai_assistant_screen.dart';
import 'trips/my_trips_screen.dart';
import 'profile/profile_screen.dart';

class NavigationShell extends StatefulWidget {
  final int initialIndex;

  const NavigationShell({super.key, this.initialIndex = 0});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;
  late PageController _pageController;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
        _isMinimized = false;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: AppCurves.springSnappy,
      );
    }
  }

  double _calculatePillWidth(String text, bool isRtl, double maxTabSlotWidth, bool isMinimized) {
    if (isMinimized) {
      return 48.0; // Compact circular/pill shape when minimized on scroll down
    }

    const TextStyle style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      letterSpacing: -0.2,
    );

    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    )..layout();

    // Icon (22) + gap (6) + text width + 28px padding
    double neededWidth = 22.0 + 6.0 + painter.width + 28.0;
    return neededWidth.clamp(56.0, maxTabSlotWidth + 14.0);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final isAr = appProvider.isArabic;

    final screens = [
      HomeScreen(
        onExploreTap: () => _onTabChanged(1),
        onPlannerTap: () => _onTabChanged(2),
      ),
      const ExploreScreen(),
      const AiAssistantScreen(),
      const MyTripsScreen(),
      const ProfileScreen(),
    ];

    final navItems = [
      _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        labelKey: 'navHome',
      ),
      _NavItemData(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        labelKey: 'navExplore',
      ),
      _NavItemData(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded,
        labelKey: 'navPlanner',
        isSpecial: true,
      ),
      _NavItemData(
        icon: Icons.card_travel_outlined,
        activeIcon: Icons.card_travel_rounded,
        labelKey: 'navTrips',
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        labelKey: 'navProfile',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (!_isMinimized) {
                setState(() => _isMinimized = true);
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (_isMinimized) {
                setState(() => _isMinimized = false);
              }
            }
            return false;
          },
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              if (_currentIndex != index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                  _isMinimized = false;
                });
              }
            },
            children: screens,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: _isMinimized ? 8 : 12, top: 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: AppCurves.springSnappy,
            height: _isMinimized ? 56 : 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isMinimized ? 28 : 36),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isMinimized ? 0.08 : 0.15),
                  blurRadius: _isMinimized ? 20 : 32,
                  spreadRadius: _isMinimized ? 1 : 2,
                  offset: Offset(0, _isMinimized ? 6 : 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isMinimized ? 28 : 36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.glassNavbarGradient,
                    borderRadius: BorderRadius.circular(_isMinimized ? 28 : 36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double barWidth = constraints.maxWidth;
                      final double tabWidth = barWidth / navItems.length;

                      final String activeLabelText = loc.translate(navItems[_currentIndex].labelKey);
                      final double pillWidth = _calculatePillWidth(activeLabelText, isAr, tabWidth, _isMinimized);

                      final double slotIndex = (isAr ? (navItems.length - 1 - _currentIndex) : _currentIndex).toDouble();
                      final double slotCenter = (slotIndex + 0.5) * tabWidth;

                      final double idealLeft = slotCenter - pillWidth / 2;
                      final double maxAllowedLeft = (barWidth - pillWidth - 6.0).clamp(6.0, barWidth);
                      final double targetLeft = idealLeft.clamp(6.0, maxAllowedLeft);

                      return Stack(
                        children: [
                          // 1. Sliding Active Orange Shape Container (Scroll-Minimized Adaptation)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: AppCurves.springSnappy,
                            left: targetLeft,
                            top: _isMinimized ? 7 : 10,
                            width: pillWidth,
                            height: _isMinimized ? 42 : 52,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppGradients.sunsetOrangeGradient,
                                borderRadius: BorderRadius.circular(_isMinimized ? 21 : 26),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange.withValues(alpha: 0.55),
                                    blurRadius: _isMinimized ? 10 : 16,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      navItems[_currentIndex].activeIcon,
                                      color: Colors.white,
                                      size: _isMinimized ? 20 : 22,
                                    ),
                                    if (!_isMinimized && constraints.maxWidth >= 340) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        activeLabelText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 2. Unselected Tab Icons Touch Layer
                          Row(
                            children: List.generate(navItems.length, (index) {
                              final item = navItems[index];
                              final isSelected = _currentIndex == index;

                              return Expanded(
                                child: AppleTouchable(
                                  enableHaptics: false,
                                  pressedScale: 0.90,
                                  onTap: () => _onTabChanged(index),
                                  child: Center(
                                    child: isSelected
                                        ? const SizedBox.shrink()
                                        : Icon(
                                            item.icon,
                                            color: AppColors.darkGray,
                                            size: _isMinimized ? 20 : 22,
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  final bool isSpecial;

  _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    this.isSpecial = false,
  });
}
