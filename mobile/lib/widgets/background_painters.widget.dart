import 'package:flutter/material.dart';
import 'package:customer_app/theme/theme.dart';

class TopRightWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // First wave (lighter, stretches further)
    final path2 = Path()
      ..moveTo(size.width * 0.4, 0)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.2,
        size.width,
        size.height * 0.25,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path2, paint2);

    // Second wave (slightly darker, closer to corner)
    final path1 = Path()
      ..moveTo(size.width * 0.6, 0)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.1,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomRightCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Large circle overlapping the bottom right corner
    canvas.drawCircle(Offset(size.width, size.height), 120, fillPaint);
    canvas.drawCircle(Offset(size.width, size.height), 120, strokePaint);

    // Medium circle slightly offset
    canvas.drawCircle(
      Offset(size.width - 40, size.height + 40),
      140,
      strokePaint,
    );

    // Small accent circle
    canvas.drawCircle(
      Offset(size.width - 150, size.height - 80),
      15,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomLeftDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    double spacing = 20.0;
    int rows = 6;
    int cols = 6;

    double startX = -10.0;
    double startY = size.height - (rows * spacing) + 10;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Create a fade effect where dots further top-right are smaller/more transparent
        double radius = 2.5 - ((r + c) * 0.15);
        if (radius > 0) {
          canvas.drawCircle(
            Offset(startX + (c * spacing), startY + (r * spacing)),
            radius,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
