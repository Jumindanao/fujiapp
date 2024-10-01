import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});

  @override
  _FinishPageState createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    // Start the confetti animation
    _confettiController.play();
  }

  @override
  void dispose() {
    // Dispose confetti controller when done
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Celebration Icon and Text
              const Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.purple,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Great job!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You've completed the lesson.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Score Section (XP and Hearts)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // XP Box
                    _scoreBox(
                      label: 'TOTAL XP',
                      value: '80',
                      color: Colors.orange,
                      icon: Icons.circle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Practice Again and Continue Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded will make the button take equal width
                    Expanded(
                      child: _bottomButton(
                        text: 'PRACTICE AGAIN',
                        color: Colors.grey.shade300,
                        textColor: Colors.black,
                        onPressed: () {
                          // Handle Practice Again action
                        },
                      ),
                    ),
                    const SizedBox(width: 16), // Add some space between buttons
                    Expanded(
                      child: _bottomButton(
                        text: 'CONTINUE',
                        color: Colors.green,
                        textColor: Colors.white,
                        onPressed: () {
                          // Handle Continue action
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Falling confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality:
                  BlastDirectionality.explosive, // All directions
              shouldLoop: false, // Set to true if you want continuous confetti
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple
              ], // Confetti colors
              createParticlePath:
                  _drawStar, // Custom shape for confetti (optional)
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Optional: You can create custom shapes for the confetti
  Path _drawStar(Size size) {
    // Logic to draw a star for custom confetti shape
    double startRadius = size.width / 2;
    Path path = Path();
    for (int i = 0; i < 5; i++) {
      double x = startRadius * math.cos((i * 72) * math.pi / 180);
      double y = startRadius * math.sin((i * 72) * math.pi / 180);
      path.lineTo(x + startRadius, y + startRadius);
    }
    path.close();
    return path;
  }
}
