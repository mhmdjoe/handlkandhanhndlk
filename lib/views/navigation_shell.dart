import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_motion.dart';
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

  // Real-time cursor tracking state
  bool _isDragging = false;
  double _dragX = 0.0;
  int _lastHapticIndex = -1;

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
        _isDragging = false;
      });
      _pageController.animateToPage(
        index,
        duration: AppDurations.medium,
        curve: AppCurves.springSnappy,
      );
    }
  }

  void _onDragStart(double localX, double totalWidth, bool isRtl) {
    setState(() {
      _isDragging = true;
      _dragX = localX;
    });
    _checkHapticFeedback(localX, totalWidth, isRtl);
  }

  void _onDragUpdate(double localX, double totalWidth, bool isRtl) {
    setState(() {
      _dragX = localX;
    });
    _checkHapticFeedback(localX, totalWidth, isRtl);
  }

  void _onDragEnd(double totalWidth, bool isRtl) {
    if (totalWidth <= 0) return;
    const numTabs = 5;
    final tabWidth = totalWidth / numTabs;
    int rawIndex = ((_dragX - tabWidth / 2) / tabWidth).round().clamp(0, numTabs - 1);
    int targetIndex = isRtl ? (numTabs - 1 - rawIndex) : rawIndex;

    setState(() {
      _isDragging = false;
      _currentIndex = targetIndex;
    });

    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      targetIndex,
      duration: AppDurations.medium,
      curve: AppCurves.springSnappy,
    );
  }

  void _checkHapticFeedback(double localX, double totalWidth, bool isRtl) {
    if (totalWidth <= 0) return;
    const numTabs = 5;
    final tabWidth = totalWidth / numTabs;
    int rawIndex = (localX / tabWidth).floor().clamp(0, numTabs - 1);
    int hoverIndex = isRtl ? (numTabs - 1 - rawIndex) : rawIndex;

    if (_lastHapticIndex != hoverIndex) {
      _lastHapticIndex = hoverIndex;
      HapticFeedback.selectionClick();
    }
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
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            if (_currentIndex != index) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentIndex = index;
                _isDragging = false;
              });
            }
          },
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 0),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth = constraints.maxWidth / navItems.length;

                      final double targetLeft = _isDragging
                          ? (_dragX - tabWidth / 2).clamp(0.0, constraints.maxWidth - tabWidth) + 4
                          : (isAr ? (navItems.length - 1 - _currentIndex) * tabWidth : _currentIndex * tabWidth) + 4;

                      return Stack(
                        children: [
                          // 1. Real-Time Cursor Tracking Orange Active Pill Shape
                          AnimatedPositioned(
                            duration: _isDragging ? Duration.zero : AppDurations.medium,
                            curve: _isDragging ? Curves.linear : AppCurves.springSnappy,
                            left: targetLeft,
                            top: 8,
                            width: tabWidth - 8,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange.withValues(alpha: 0.50),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 2. Interactive Real-Time Cursor Drag & Tap Layer
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) => _onDragStart(details.localPosition.dx, constraints.maxWidth, isAr),
                            onPanUpdate: (details) => _onDragUpdate(details.localPosition.dx, constraints.maxWidth, isAr),
                            onPanEnd: (details) => _onDragEnd(constraints.maxWidth, isAr),
                            onPanCancel: () => setState(() => _isDragging = false),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Row(
                                children: [
                                  for (int i = 0; i < navItems.length; i++)
                                    _buildNavItemTile(navItems[i], i == _currentIndex, loc),
                                ],
                              ),
                            ),
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

  Widget _buildNavItemTile(_NavItemData item, bool isSelected, AppLocalizations loc) {
    return Expanded(
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: AppDurations.fast,
          curve: AppCurves.springBouncy,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 22,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                AnimatedOpacity(
                  duration: AppDurations.fast,
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Text(
                    loc.translate(item.labelKey),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ],
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
