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

/// Total length of the intro. Timeline (milliseconds):
///   500-4000  draws the logo mark
///  4000-4600  arrowhead appears
///  5000-6800  logo zooms in until the welcome screen shows
///  6400-7600  welcome screen fades in
const double _kTotalMs = 8000;

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
              final w = _seg(_c.value * _kTotalMs, 6400, 7600, Curves.easeOut);
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

  // Centre line the drawing follows, in the mark's own 720 x 849 coordinates.
  static Path _buildPath() {
    final p = Path()
      ..moveTo(25, 500)
      ..cubicTo(41, 499, 84, 501, 120, 495)
      ..cubicTo(156, 489, 202, 475, 240, 462)
      ..cubicTo(278, 449, 315, 433, 350, 415)
      ..cubicTo(385, 397, 421, 379, 450, 355)
      ..cubicTo(479, 331, 504, 301, 525, 272)
      ..cubicTo(546, 243, 567, 209, 578, 180)
      ..cubicTo(589, 151, 598, 120, 592, 100)
      ..cubicTo(586, 80, 565, 61, 545, 58)
      ..cubicTo(525, 55, 500, 61, 470, 80)
      ..cubicTo(440, 99, 398, 136, 365, 170)
      ..cubicTo(332, 204, 298, 248, 270, 285)
      ..cubicTo(242, 322, 215, 362, 195, 395)
      ..cubicTo(175, 428, 158, 459, 150, 485)
      ..cubicTo(142, 511, 152, 528, 150, 550)
      ..cubicTo(148, 572, 142, 595, 138, 620)
      ..cubicTo(134, 645, 129, 678, 128, 700)
      ..cubicTo(127, 722, 127, 738, 132, 750)
      ..cubicTo(137, 762, 144, 780, 160, 775)
      ..cubicTo(176, 770, 205, 742, 230, 722)
      ..cubicTo(255, 702, 287, 668, 310, 652)
      ..cubicTo(333, 636, 353, 627, 370, 628)
      ..cubicTo(387, 629, 398, 647, 410, 660)
      ..cubicTo(422, 673, 432, 696, 445, 705)
      ..cubicTo(458, 714, 471, 714, 490, 712)
      ..cubicTo(509, 710, 538, 700, 560, 690)
      ..cubicTo(582, 680, 607, 664, 625, 650)
      ..cubicTo(643, 636, 661, 615, 668, 608);
    return p;
  }

  static final ui.PathMetric _metric = _buildPath().computeMetrics().first;

  static const _drawCurve = Cubic(.4, .1, .35, 1);
  static const _zoomCurve = Cubic(.65, 0, .95, .45);
  static const _zoomOrigin = Offset(420, 270); // inside the "h" loop

  @override
  void paint(Canvas canvas, Size size) {
    final ms = controller.value * _kTotalMs;

    final draw = _seg(ms, 500, 4000, _drawCurve);
    final pop = _seg(ms, 4000, 4600, Curves.easeOut);
    final zoom = _seg(ms, 5000, 6800, _zoomCurve);
    final markOpacity = 1 - ((ms - 6020) / 780).clamp(0.0, 1.0);

    // Fit the 720 x 849 mark on screen, slightly above centre.
    final scale = math.min(size.width * 0.775 / 720, size.height * 0.42 / 849);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2 - 30);
    canvas.scale(scale);
    canvas.translate(-360, -424.5);

    const bounds = Rect.fromLTWH(0, 0, 720, 849);

    if (markOpacity > 0 && draw > 0) {
      canvas.save();
      canvas.translate(_zoomOrigin.dx, _zoomOrigin.dy);
      canvas.scale(1 + 25 * zoom);
      canvas.translate(-_zoomOrigin.dx, -_zoomOrigin.dy);

      canvas.saveLayer(
        bounds,
        Paint()..color = Colors.white.withAlpha((markOpacity * 255).round()),
      );
      canvas.saveLayer(bounds, Paint());
      // 1) the mask: a thick stroke that grows along the path
      canvas.drawPath(
        _metric.extractPath(0, _metric.length * draw),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 170
          ..color = Colors.white,
      );
      if (pop > 0) {
        canvas.drawCircle(
            const Offset(610, 650), 200 * pop, Paint()..color = Colors.white);
      }
      // 2) the logo, only where the mask has been drawn
      canvas.drawImage(
        mark,
        Offset.zero,
        Paint()
          ..blendMode = BlendMode.srcIn
          ..filterQuality = FilterQuality.high,
      );
      canvas.restore();
      canvas.restore();
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SplashPainter old) => old.mark != mark;
}
