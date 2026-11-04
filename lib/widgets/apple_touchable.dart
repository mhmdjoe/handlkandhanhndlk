import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_motion.dart';

/// Apple-Style Tactile Micro-Interaction Wrapper Component
///
/// Features:
/// - Smooth spring scale-down on touch press (default 0.96x).
/// - Instant haptic tactile feedback (HapticFeedback.lightImpact()).
/// - Subtle press opacity transition (default 0.88).
/// - Natural spring elasticity on touch release.
class AppleTouchable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double pressedOpacity;
  final bool enableHaptics;
  final BorderRadius? borderRadius;

  const AppleTouchable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.pressedOpacity = 0.88,
    this.enableHaptics = true,
    this.borderRadius,
  });

  @override
  State<AppleTouchable> createState() => _AppleTouchableState();
}

class _AppleTouchableState extends State<AppleTouchable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.ultraFast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.springSnappy,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.appleEase,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (widget.onTap == null && widget.onLongPress == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveChild = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );

    if (widget.onTap == null && widget.onLongPress == null) {
      return widget.child;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress != null
            ? () {
                if (widget.enableHaptics) {
                  HapticFeedback.mediumImpact();
                }
                widget.onLongPress?.call();
              }
            : null,
        child: widget.borderRadius != null
            ? ClipRRect(
                borderRadius: widget.borderRadius!,
                child: effectiveChild,
              )
            : effectiveChild,
      ),
    );
  }
}
