import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? tintColor;
  final double blurSigma;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.tintColor,
    this.blurSigma = 15.0,
    this.borderColor,
    this.borderWidth = 1.2,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tintColor ?? Colors.white.withValues(alpha: 0.15);
    final effectiveBorder = borderColor ?? Colors.white.withValues(alpha: 0.25);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveTint,
              borderRadius: borderRadius,
              border: Border.all(
                color: effectiveBorder,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
