import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appProvider = Provider.of<AppProvider>(context);

    final screens = [
      HomeScreen(
        onExploreTap: () => setState(() => _currentIndex = 1),
        onPlannerTap: () => setState(() => _currentIndex = 2),
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
      extendBody: true, // Content flows seamlessly under the glassmorphic bar
      body: Directionality(
        textDirection: appProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: IndexedStack(
          index: _currentIndex,
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
                  color: AppColors.nileTeal.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.nileTeal.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = _currentIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _currentIndex = index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 16 : 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (item.isSpecial
                                    ? AppColors.terracotta
                                    : AppColors.papyrusGold.withValues(alpha: 0.22))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: isSelected && !item.isSpecial
                                ? Border.all(color: AppColors.papyrusGold.withValues(alpha: 0.6))
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected
                                      ? (item.isSpecial ? Colors.white : AppColors.papyrusGold)
                                      : Colors.white70,
                                  size: item.isSpecial ? 24 : 22,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isSelected ? 1.0 : 0.0,
                                  child: Text(
                                    loc.translate(item.labelKey),
                                    style: TextStyle(
                                      color: isSelected
                                          ? (item.isSpecial ? Colors.white : AppColors.papyrusGold)
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
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
