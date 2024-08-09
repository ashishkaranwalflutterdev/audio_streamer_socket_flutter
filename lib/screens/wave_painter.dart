import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final double maxAmplitude;

  WaveformPainter({required this.amplitudes, required this.maxAmplitude});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final middle = size.height / 2;
    final scale = size.height / 2 / maxAmplitude;

    for (int i = 0; i < amplitudes.length; i++) {
      final x = (i / (amplitudes.length - 1)) * size.width;
      final y = middle - (amplitudes[i] * scale);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
