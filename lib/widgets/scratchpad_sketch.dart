import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ScratchpadSketch extends StatelessWidget {
  const ScratchpadSketch({
    super.key,
    required this.strokes,
    required this.width,
    required this.height,
    this.showHint = false,
  });

  final List<List<Offset>> strokes;
  final double width;
  final double height;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _ScratchpadSketchPainter(strokes),
        child: showHint && strokes.isEmpty
            ? const Center(
                child: Text(
                  'Sentuh dan geser untuk menggambar',
                  style: TextStyle(color: AppColors.mutedInk, fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }
}

class _ScratchpadSketchPainter extends CustomPainter {
  const _ScratchpadSketchPainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final points = stroke
          .map((point) => Offset(point.dx * size.width, point.dy * size.height))
          .toList();
      if (points.length == 1) {
        canvas.drawCircle(
          points.single,
          1.5,
          paint..style = PaintingStyle.fill,
        );
        paint.style = PaintingStyle.stroke;
        continue;
      }

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchpadSketchPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
