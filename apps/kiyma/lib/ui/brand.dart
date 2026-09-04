import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiyma/ui/palette.dart';

/// The cream ground every screen outside the kitchen sits on: the design's
/// 48px grid with a 24px dot lattice offset into its centres.
class BrandBackground extends StatelessWidget {
  const BrandBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KiymaPalette.krema,
    body: CustomPaint(
      painter: const _TilePainter(),
      child: SafeArea(child: child),
    ),
  );
}

class _TilePainter extends CustomPainter {
  const _TilePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = KiymaPalette.krema);

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

/// A cream panel with the design's dark outline.
class BrandCard extends StatelessWidget {
  const BrandCard({required this.child, this.width, super.key});

  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: KiymaPalette.krema,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: KiymaPalette.komur.withValues(alpha: 0.5),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: KiymaPalette.komur.withValues(alpha: 0.18),
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

/// Flat fill, 2px border, and a hard offset shadow that reads as thickness.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = KiymaPalette.ates,
    this.big = false,
    this.onHold,
    this.holdFor = const Duration(seconds: 3),
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool big;

  /// Fired after [holdFor] of holding, instead of the tap. Long enough that
  /// nobody finds it by accident.
  final VoidCallback? onHold;
  final Duration holdFor;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  Timer? _hold;
  bool _held = false;

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  void _start(_) {
    if (widget.onHold == null) return;
    _held = false;
    _hold = Timer(widget.holdFor, () {
      _held = true;
      widget.onHold!();
    });
  }

  void _stop() => _hold?.cancel();

  void _tap() {
    if (_held) {
      _held = false;
      return;
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed;
    final icon = widget.icon;
    final big = widget.big;
    final color = widget.color;
    final label = widget.label;
    final enabled = onPressed != null;
    final fill = enabled ? color : const Color(0xFFC9BEAE);
    return Opacity(
      opacity: enabled ? 1 : 0.75,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? _tap : null,
          onTapDown: enabled ? _start : null,
          onTapUp: (_) => _stop(),
          onTapCancel: _stop,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: big ? 62 : 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KiymaPalette.komur, width: 2),
              boxShadow: const [
                BoxShadow(color: KiymaPalette.komur, offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: big ? 24 : 20, color: KiymaPalette.komur),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontVariations: const [FontVariation('wght', 700)],
                      fontSize: big ? 19 : 15,
                      letterSpacing: 0.6,
                      color: KiymaPalette.komur,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small rounded readout for a corner.
class BrandChip extends StatelessWidget {
  const BrandChip({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: KiymaPalette.ahsap.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: KiymaPalette.ahsap.withValues(alpha: 0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: KiymaPalette.ates),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontVariations: [FontVariation('wght', 700)],
            fontSize: 13,
            color: KiymaPalette.komur,
          ),
        ),
      ],
    ),
  );
}

/// The wordmark, at whatever size the screen has room for.
class Wordmark extends StatelessWidget {
  const Wordmark({this.size = 84, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scale = size / 96;
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
        fontSize: size,
        height: 1,
        letterSpacing: size * 0.07,
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
            offset: Offset(0, 12 * scale),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }
}
