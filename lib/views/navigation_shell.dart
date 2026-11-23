import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
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
  bool _isHidden = false;

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
        _isHidden = false;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: AppCurves.springSnappy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (!_isHidden) {
                setState(() => _isHidden = true);
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (_isHidden) {
                setState(() => _isHidden = false);
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
                  _isHidden = false;
                });
              }
            },
            children: screens,
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 320),
        curve: AppCurves.springSnappy,
        offset: _isHidden ? const Offset(0, 1.5) : Offset.zero,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 0),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.glassNavbarGradient,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double barWidth = constraints.maxWidth;
                        final double tabWidth = barWidth / navItems.length;
                        const double pillWidth = 52.0;

                        final double slotIndex = (isAr ? (navItems.length - 1 - _currentIndex) : _currentIndex).toDouble();
                        final double slotCenter = (slotIndex + 0.5) * tabWidth;
                        final double targetLeft = slotCenter - pillWidth / 2;

                        return Stack(
                          children: [
                            // 1. Sliding Active Orange Circle Icon Bubble (Icons Only)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 260),
                              curve: AppCurves.springSnappy,
                              left: targetLeft,
                              top: 8,
                              width: pillWidth,
                              height: 52,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.sunsetOrangeGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryOrange.withValues(alpha: 0.55),
                                      blurRadius: 14,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    navItems[_currentIndex].activeIcon,
                                    color: Colors.white,
                                    size: 24,
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
                                    pressedScale: 0.88,
                                    onTap: () => _onTabChanged(index),
                                    child: Center(
                                      child: isSelected
                                          ? const SizedBox.shrink()
                                          : Icon(
                                              item.icon,
                                              color: AppColors.darkGray,
                                              size: 23,
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
