import 'package:flutter/material.dart';

class CustomProgressbar extends StatelessWidget {
  final double width;
  final double height;
  final double percent;
  final double startOffset;
  final Color backgroundColor;
  final Color progressColor;
  final bool animation;
  final double animationDuration;

  CustomProgressbar({
    required this.width,
    required this.height,
    required this.percent,
    required this.startOffset,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    required this.animation,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ProgressBarPainter(
        percent: percent,
        startOffset: startOffset,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final double percent;
  final double startOffset;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressBarPainter({
    required this.percent,
    required this.startOffset,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;


    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final double progressWidth = (size.width - startOffset) * percent;
    canvas.drawRect(Rect.fromLTWH(startOffset, 0, progressWidth, size.height),
        progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
