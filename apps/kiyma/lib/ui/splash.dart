import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/ui/palette.dart';

/// What the startup jobs are shown behind.
///
/// A port of the brand screen from the design: cream ground, tiled dots, the
/// wordmark in its charcoal outline, a drawn skewer. Nothing here loads an
/// asset — this is the screen the art is being loaded *behind*, so the
/// illustration is painted rather than drawn from `assets/items`.
class SplashView extends StatefulWidget {
  const SplashView({required this.progress, super.key});

  final double progress;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  // The design's `softGlow`: a breath, not an animation anybody should
  // notice. Startup is usually over before it completes a cycle.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KiymaPalette.krema,
    body: CustomPaint(
      painter: const _TilePainter(),
      child: SafeArea(
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
                          _Badge(),
                          SizedBox(height: 6),
                          _Wordmark(),
                          SizedBox(height: 14),
                          SizedBox(
                            width: 300,
                            height: 56,
                            child: CustomPaint(painter: _SkewerPainter()),
                          ),
                          SizedBox(height: 10),
                          _Tagline(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _Progress(value: widget.progress),
                  ],
                ),
              ),
            ),
            const Align(alignment: Alignment.bottomCenter, child: _Studio()),
          ],
        ),
      ),
    ),
  );
}

/// The cream ground: a faint 48px grid with a 24px dot lattice offset into
/// its centres. Cheap enough to repaint every frame, so it is not cached.
class _TilePainter extends CustomPainter {
  const _TilePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = KiymaPalette.krema,
    );

    final line = Paint()
      ..color = KiymaPalette.komur.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }

    final dot = Paint()..color = KiymaPalette.ahsap.withValues(alpha: 0.06);
    for (var x = 12.0; x < size.width; x += 24) {
      for (var y = 12.0; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 2, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_TilePainter oldDelegate) => false;
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

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: BoxDecoration(
      color: KiymaPalette.ahsap.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: KiymaPalette.ahsap.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.local_fire_department,
          size: 17,
          color: KiymaPalette.ates,
        ),
        const SizedBox(width: 8),
        // Stored uppercase rather than uppercased here: Turkish casing turns
        // "Simülatörü" into "SIMÜLATÖRÜ" under an invariant toUpperCase, and
        // which letters a language shouts is the content's business anyway.
        Text(
          'baslangic.rozet'.tr(),
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 800)],
            fontSize: 11,
            letterSpacing: 2,
            color: KiymaPalette.ahsap,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.local_fire_department,
          size: 17,
          color: KiymaPalette.ates,
        ),
      ],
    ),
  );
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  /// The design's `text-cel-shadow`, at the size it was drawn for. Eight
  /// offsets make the outline, the ninth is the extrusion the letters sit on,
  /// and the last is the shadow it casts.
  static const _size = 84.0;
  static const _at = 96.0;

  @override
  Widget build(BuildContext context) {
    const scale = _size / _at;
    Shadow hard(double dx, double dy) => Shadow(
      color: KiymaPalette.komur,
      offset: Offset(dx * scale, dy * scale),
    );

    return Text(
      'KIYMA',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Rubik',
        fontVariations: const [FontVariation('wght', 900)],
        fontSize: _size,
        height: 1,
        letterSpacing: 6,
        color: KiymaPalette.ates,
        shadows: [
          hard(-3, -3),
          hard(3, -3),
          hard(-3, 3),
          hard(3, 3),
          hard(-4, 0),
          hard(4, 0),
          hard(0, -4),
          hard(0, 4),
          hard(0, 8),
          Shadow(
            color: KiymaPalette.komur.withValues(alpha: 0.35),
            offset: const Offset(0, 12 * scale),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.85,
    child: Text(
      'baslangic.slogan'.tr(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Rubik',
        fontVariations: [FontVariation('wght', 700)],
        fontSize: 13,
        letterSpacing: 2.6,
        color: KiymaPalette.ahsap,
      ),
    ),
  );
}

/// Not in the design, which had nothing to wait for. Kept because the art is
/// 12 MB and a screen that never moves reads as a hang.
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
