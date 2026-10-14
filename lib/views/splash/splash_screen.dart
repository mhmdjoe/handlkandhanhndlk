import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../theme/app_theme.dart';

/// Class for color mapping in HandelakSplash
class HandelakColors {
  static const Color purple = AppColors.primaryPurple;
  static const Color orange = AppColors.primaryOrange;
}

/// Total length of the intro timeline (milliseconds):
///  0-1200  logo bounces into the screen
/// 1800-4200 logo zooms in smoothly until welcome screen shows
/// 3600-4500 welcome screen reveals
const double _kTotalMs = 4500;

/// Plays once. [welcome] sits underneath and is revealed at the end.
class HandelakSplash extends StatefulWidget {
  const HandelakSplash({super.key, required this.welcome, this.onFinished});

  final Widget welcome;
  final VoidCallback? onFinished;

  @override
  State<HandelakSplash> createState() => _HandelakSplashState();
}

class _HandelakSplashState extends State<HandelakSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _kTotalMs.round()),
  );
  ui.Image? _mark;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinished?.call();
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load('assets/images/handelak_mark.png');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() => _mark = frame.image);
      _c.forward();
    } catch (_) {}
  }

  @override
  void dispose() {
    _c.dispose();
    _mark?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final w = _seg(_c.value * _kTotalMs, 3200, 4200, Curves.easeOut);
              return IgnorePointer(
                ignoring: w < 1,
                child: Opacity(
                  opacity: w,
                  child: Transform.translate(
                    offset: Offset(0, (1 - w) * 18),
                    child: child,
                  ),
                ),
              );
            },
            child: widget.welcome,
          ),
          if (_mark != null)
            IgnorePointer(
              child: CustomPaint(
                painter: _SplashPainter(controller: _c, mark: _mark!),
              ),
            ),
        ],
      ),
    );
  }
}

/// 0..1 progress of [ms] between [a] and [b], shaped by [curve].
double _seg(double ms, double a, double b, [Curve curve = Curves.linear]) =>
    curve.transform(((ms - a) / (b - a)).clamp(0.0, 1.0));

class _SplashPainter extends CustomPainter {
  _SplashPainter({required this.controller, required this.mark})
      : super(repaint: controller);

  final AnimationController controller;
  final ui.Image mark; // 720 x 849 px

  static const _zoomCurve = Cubic(.65, 0, .95, .45);
  static const _zoomOrigin = Offset(420, 270);

  @override
  void paint(Canvas canvas, Size size) {
    final ms = controller.value * _kTotalMs;

    // Bounce spring entry animation (0ms - 1200ms)
    final bounce = _seg(ms, 0, 1200, Curves.elasticOut);
    
    // Zoom expansion animation (1800ms - 4200ms)
    final zoom = _seg(ms, 1800, 4200, _zoomCurve);
    final markOpacity = 1 - ((ms - 3600) / 600).clamp(0.0, 1.0);

    // Fit the 720 x 849 mark on screen, slightly above centre.
    final scale = math.min(size.width * 0.775 / 720, size.height * 0.42 / 849);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 - 30);
    canvas.scale(scale);
    canvas.translate(-360, -424.5);

    if (markOpacity > 0 && bounce > 0) {
      canvas.save();
      canvas.translate(_zoomOrigin.dx, _zoomOrigin.dy);
      
      // Combine elastic bounce entry + smooth zoom expansion
      final currentScale = bounce + (25 * zoom);
      canvas.scale(currentScale);
      canvas.translate(-_zoomOrigin.dx, -_zoomOrigin.dy);

      canvas.drawImage(
        mark,
        Offset.zero,
        Paint()
          ..color = Colors.white.withAlpha((markOpacity * 255).round())
          ..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SplashPainter old) => old.mark != mark;
}
