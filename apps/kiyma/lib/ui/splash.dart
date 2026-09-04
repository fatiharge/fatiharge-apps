import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kiyma/ui/brand.dart';
import 'package:kiyma/ui/palette.dart';

class SplashView extends StatefulWidget {
  const SplashView({
    required this.progress,
    this.hold = const Duration(seconds: 1),
    super.key,
  });

  final double progress;

  final Duration hold;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  )..repeat(reverse: true);

  late final AnimationController _held = AnimationController(
    vsync: this,
    duration: widget.hold,
  )..forward();

  @override
  void dispose() {
    _breath.dispose();
    _held.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BrandBackground(
    child: Stack(
      children: [
        const Positioned(top: 14, left: 22, child: _CornerTrim()),
        const Positioned(
          top: 14,
          right: 22,
          child: _CornerTrim(mirrored: true),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: Tween<double>(
                    begin: 1,
                    end: 1.02,
                  ).animate(_breath),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wordmark(),
                      SizedBox(height: 14),
                      SizedBox(
                        width: 300,
                        height: 56,
                        child: CustomPaint(painter: _SkewerPainter()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedBuilder(
                  animation: _held,
                  builder: (context, _) => _Progress(
                    value: math.max(_held.value, widget.progress),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Align(alignment: Alignment.bottomCenter, child: _Studio()),
      ],
    ),
  );
}

class _CornerTrim extends StatelessWidget {
  const _CornerTrim({this.mirrored = false});

  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final pieces = [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: KiymaPalette.ahsap,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: KiymaPalette.komur, width: 2),
        ),
      ),
      const SizedBox(width: 6),
      const _Dot(),
      const SizedBox(width: 6),
      Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: KiymaPalette.komur,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ];
    return Opacity(
      opacity: 0.25,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: mirrored ? pieces.reversed.toList() : pieces,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: const BoxDecoration(
      color: KiymaPalette.ates,
      shape: BoxShape.circle,
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 160,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: KiymaPalette.komur.withValues(alpha: 0.12),
        valueColor: const AlwaysStoppedAnimation(KiymaPalette.ates),
      ),
    ),
  );
}

class _Studio extends StatelessWidget {
  const _Studio();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: KiymaPalette.krema.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KiymaPalette.komur.withValues(alpha: 0.1)),
      ),
      child: Text(
        'dafalabs',
        style: TextStyle(
          fontFamily: 'Rubik',
          fontVariations: const [FontVariation('wght', 700)],
          fontSize: 11,
          letterSpacing: 2,
          color: KiymaPalette.komur.withValues(alpha: 0.6),
        ),
      ),
    ),
  );
}

/// The skewer from the design, drawn rather than loaded.
///
/// Laid out in the SVG's own 380x70 space and scaled to whatever box it is
/// given, so the numbers below can be read against the design file.
class _SkewerPainter extends CustomPainter {
  const _SkewerPainter();

  static const _et = Color(0xFFC4321F);
  static const _etKoyu = Color(0xFFB3301C);
  static const _parlak = Color(0xFFF5A069);
  static const _yesil = Color(0xFF6FA82E);
  static const _celik = Color(0xFFB9BEC4);
  static const _sap = Color(0xFF5C3B1E);

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 380, size.height / 70);

    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Blade, then handle over it.
    canvas
      ..drawLine(
        const Offset(12, 35),
        const Offset(368, 35),
        stroke(KiymaPalette.komur, 8),
      )
      ..drawLine(const Offset(14, 35), const Offset(366, 35), stroke(_celik, 4))
      ..drawLine(
        const Offset(368, 35),
        const Offset(376, 35),
        stroke(KiymaPalette.ahsap, 6),
      )
      ..drawLine(
        const Offset(8, 35),
        const Offset(36, 35),
        stroke(KiymaPalette.ahsap, 10),
      )
      ..drawLine(const Offset(10, 35), const Offset(34, 35), stroke(_sap, 4));

    for (final x in [48.0, 114.0, 180.0, 246.0]) {
      _meat(canvas, x, stroke);
    }
    _garnish(canvas, stroke);

    canvas.restore();
  }

  void _meat(Canvas canvas, double x, Paint Function(Color, double) stroke) {
    RRect box(double dx, double dy, double w, double h, double r) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + dx, dy, w, h),
          Radius.circular(r),
        );

    canvas
      ..drawRRect(box(0, 16, 56, 38, 14), Paint()..color = KiymaPalette.komur)
      ..drawRRect(box(3, 19, 50, 32, 11), Paint()..color = _et)
      ..drawRRect(box(5, 21, 46, 26, 9), Paint()..color = _etKoyu);

    // Char marks, leaning the way the design draws them.
    for (final offset in [14.0, 28.0, 42.0]) {
      canvas.drawLine(
        Offset(x + offset, 19),
        Offset(x + offset - 3, 51),
        stroke(KiymaPalette.komur, 3.5),
      );
    }

    canvas
      ..drawPath(
        Path()
          ..moveTo(x + 8, 23)
          ..quadraticBezierTo(x + 27, 20, x + 46, 23),
        stroke(_parlak, 2),
      )
      ..drawCircle(Offset(x + 20, 27), 1.5, Paint()..color = _yesil)
      ..drawCircle(Offset(x + 36, 39), 1.5, Paint()..color = KiymaPalette.ates);
  }

  void _garnish(Canvas canvas, Paint Function(Color, double) stroke) {
    final pepper = Path()
      ..moveTo(302, 24)
      ..cubicTo(314, 18, 332, 20, 342, 26)
      ..cubicTo(334, 32, 318, 34, 304, 30)
      ..close();
    canvas
      ..drawPath(pepper, Paint()..color = _yesil)
      ..drawPath(pepper, stroke(KiymaPalette.komur, 2.5))
      ..drawLine(
        const Offset(314, 22),
        const Offset(316, 29),
        stroke(KiymaPalette.komur, 2),
      )
      ..drawLine(
        const Offset(326, 23),
        const Offset(328, 29),
        stroke(KiymaPalette.komur, 2),
      );

    final tomato = Rect.fromCenter(
      center: const Offset(320, 44),
      width: 24,
      height: 20,
    );
    canvas
      ..drawOval(tomato, Paint()..color = _et)
      ..drawOval(tomato, stroke(KiymaPalette.komur, 2.5))
      ..drawOval(
        Rect.fromCenter(
          center: const Offset(320, 43),
          width: 18,
          height: 14,
        ),
        Paint()..color = KiymaPalette.ates,
      )
      ..drawLine(
        const Offset(314, 41),
        const Offset(326, 45),
        stroke(KiymaPalette.komur, 2),
      );
  }

  @override
  bool shouldRepaint(_SkewerPainter oldDelegate) => false;
}
