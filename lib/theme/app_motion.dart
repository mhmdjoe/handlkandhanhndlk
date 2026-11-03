import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Centralized Apple Motion & Animation Specification for Handelak
class AppCurves {
  /// Standard Apple Smooth Ease Curve
  static const Curve appleEase = Cubic(0.25, 0.1, 0.25, 1.0);

  /// iOS Snappy Spring Response Curve
  static const Curve springSnappy = Cubic(0.2, 0.8, 0.2, 1.0);

  /// iOS Subtle Bouncy Spring Curve
  static const Curve springBouncy = Cubic(0.34, 1.56, 0.64, 1.0);

  /// iOS Modal Bottom Sheet Spring Curve
  static const Curve sheetSpring = Cubic(0.175, 0.885, 0.32, 1.08);

  /// iOS Page Navigation Transition Curve
  static const Curve pageTransition = Cubic(0.32, 0.72, 0.0, 1.0);

  /// Smooth Fade Entrance Curve
  static const Curve fadeEntrance = Cubic(0.0, 0.0, 0.2, 1.0);
}

class AppDurations {
  /// Ultra-fast micro-feedback (haptic sync, color shift)
  static const Duration ultraFast = Duration(milliseconds: 140);

  /// Fast interaction (button press scale, icon toggle)
  static const Duration fast = Duration(milliseconds: 220);

  /// Medium transition (tab switch, modal presentation, card expansion)
  static const Duration medium = Duration(milliseconds: 340);

  /// Page navigation transition duration
  static const Duration page = Duration(milliseconds: 420);

  /// Staggered entrance animation delay unit
  static const Duration staggerOffset = Duration(milliseconds: 60);
}

/// Custom iOS-Style Page Transition Route with Slide & Fade
class AppCupertinoPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AppCupertinoPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppDurations.page,
          reverseTransitionDuration: AppDurations.page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Primary Slide in from Right + Subtle Fade
            final slideIn = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppCurves.pageTransition,
              ),
            );

            final fadeIn = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            );

            // Secondary Parallax Push Back on Previous Screen
            final secondarySlide = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.25, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: AppCurves.pageTransition,
              ),
            );

            return SlideTransition(
              position: secondarySlide,
              child: SlideTransition(
                position: slideIn,
                child: FadeTransition(
                  opacity: fadeIn,
                  child: child,
                ),
              ),
            );
          },
        );
}

/// Staggered Entrance Animation Container for List Items & Cards
class StaggeredEntranceItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayOffset;

  const StaggeredEntranceItem({
    super.key,
    required this.child,
    required this.index,
    this.delayOffset = AppDurations.staggerOffset,
  });

  @override
  State<StaggeredEntranceItem> createState() => _StaggeredEntranceItemState();
}

class _StaggeredEntranceItemState extends State<StaggeredEntranceItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.fadeEntrance,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.springSnappy,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.springSnappy,
    ));

    final delay = widget.delayOffset * widget.index;
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
