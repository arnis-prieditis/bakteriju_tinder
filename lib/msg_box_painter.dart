import 'package:flutter/material.dart';

class MsgBoxPainter extends CustomPainter {
  final bool outgoing;
  final bool filled;
  final Color color;

  const MsgBoxPainter({
    required this.outgoing,
    required this.filled,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const Radius radius = Radius.circular(10.0);
    RRect rrect = RRect.fromRectAndRadius(rect, radius);
    final Paint paint = Paint();
    paint.style = filled ? PaintingStyle.fill : PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    paint.color = color;
    canvas.drawRRect(rrect, paint);
    final Offset circle_offset = Offset(outgoing ? size.width - 10.0 : 10.0, size.height + 10.0);
    canvas.drawCircle(circle_offset, 7.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
