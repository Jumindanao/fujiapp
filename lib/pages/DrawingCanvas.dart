import 'package:flutter/material.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset?> points = []; // Store user drawing points

  void _clearDrawing() {
    setState(() {
      points.clear(); // Clear the drawing points
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trace あか (Aka)')),
      body: Stack(
        children: [
          // Background for stroke order using font
          Center(
            child: Text(
              'がぎ', // Character to display
              style: TextStyle(
                fontSize: 200,
                fontFamily: 'KanjiStrokeOrders', // Use the custom font
                color: Colors.grey.withOpacity(0.9), // Faint color for tracing
              ),
            ),
          ),
          // Gesture detector for user drawing
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Store user drawing points
                points.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              points.add(null); // Separate strokes by adding null
            },
            child: CustomPaint(
              painter: CharacterPainter(points),
              size: Size.infinite,
            ),
          ),
          // Floating action button to clear the drawing
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _clearDrawing,
              tooltip: 'Clear Drawing',
              child: const Icon(Icons.clear),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to visualize user drawing
class CharacterPainter extends CustomPainter {
  final List<Offset?> points;
  CharacterPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
