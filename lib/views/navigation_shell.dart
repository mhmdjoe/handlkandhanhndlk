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

  // Real-time hover & drag state for ultra-responsive feedback
  int? _hoverIndex;
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
        _hoverIndex = null;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: AppCurves.springSnappy,
      );
    }
  }

  void _handlePointerHover(double localX, double totalWidth, bool isRtl) {
    if (totalWidth <= 0) return;
    const numTabs = 5;
    final tabWidth = totalWidth / numTabs;
    int rawIndex = (localX / tabWidth).floor().clamp(0, numTabs - 1);
    int targetIndex = isRtl ? (numTabs - 1 - rawIndex) : rawIndex;

    if (_hoverIndex != targetIndex) {
      setState(() {
        _hoverIndex = targetIndex;
      });
      if (_lastHapticIndex != targetIndex) {
        _lastHapticIndex = targetIndex;
        HapticFeedback.selectionClick();
      }
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
                _hoverIndex = null;
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
                      const double barPadding = 12.0; // Inset padding away from edges
                      final double availableWidth = constraints.maxWidth - (barPadding * 2);
                      final double tabWidth = availableWidth / navItems.length;
                      final double pillWidth = (tabWidth - 10.0).clamp(48.0, 92.0);
                      final activeDisplayIndex = _hoverIndex ?? _currentIndex;

                      final double targetLeft = barPadding + (isAr
                          ? (navItems.length - 1 - activeDisplayIndex) * tabWidth
                          : activeDisplayIndex * tabWidth) + (tabWidth - pillWidth) / 2;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: barPadding),
                        child: Stack(
                          children: [
                            // 1. Sliding Orange Active Pill Shape (Minimized & Inset from Edges)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 180),
                              curve: AppCurves.springSnappy,
                              left: targetLeft - barPadding,
                              top: 15,
                              width: pillWidth,
                              height: 42,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(21),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryOrange.withValues(alpha: 0.45),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 2. Interactive Real-Time Mouse Hover & Touch Gestures Layer
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onHover: (event) => _handlePointerHover(event.localPosition.dx, constraints.maxWidth, isAr),
                              onExit: (_) => setState(() => _hoverIndex = null),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (details) {
                                  const numTabs = 5;
                                  final width = constraints.maxWidth;
                                  final w = width / numTabs;
                                  int rawIndex = (details.localPosition.dx / w).floor().clamp(0, numTabs - 1);
                                  int targetIndex = isAr ? (numTabs - 1 - rawIndex) : rawIndex;
                                  _onTabChanged(targetIndex);
                                },
                                onPanUpdate: (details) => _handlePointerHover(details.localPosition.dx, constraints.maxWidth, isAr),
                                onPanEnd: (_) {
                                  if (_hoverIndex != null) {
                                    _onTabChanged(_hoverIndex!);
                                  }
                                },
                                child: Row(
                                  children: [
                                    for (int i = 0; i < navItems.length; i++)
                                      _buildNavItemTile(
                                        navItems[i],
                                        activeDisplayIndex == i,
                                        _currentIndex == i,
                                        loc,
                                        constraints.maxWidth < 340,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildNavItemTile(_NavItemData item, bool isHighlighted, bool isSelected, AppLocalizations loc, bool isCompactMobile) {
    return Expanded(
      child: Center(
        child: AnimatedScale(
          scale: isHighlighted ? 1.08 : 1.0,
          duration: AppDurations.fast,
          curve: AppCurves.springBouncy,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHighlighted ? item.activeIcon : item.icon,
                color: isHighlighted ? Colors.white : Colors.white70,
                size: 22,
              ),
              if (isHighlighted && !isCompactMobile) ...[
                const SizedBox(width: 6),
                AnimatedOpacity(
                  duration: AppDurations.fast,
                  opacity: isHighlighted ? 1.0 : 0.0,
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
