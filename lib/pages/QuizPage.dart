import 'package:flutter/material.dart';

//oks na ang wriing ani pero kulang ug showbottomsheet
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TransformationController _transformationController =
      TransformationController();
  List<Offset> points = [];
  List<List<Offset>> lines = [];
  int currentQuizIndex = 0; // Track the current quiz index
  int? selectedOptionIndex;
  bool isAnswerCorrect = false;
  bool checkPressed = false; // Track if the "CHECK" button was pressed
  List<Map<String, dynamic>> quizzes = [
    {
      'question': 'Good morning, Sensei',
      'type': 'card',
      'options': [
        "おはようございます\nせんせい",
        "せんせい",
        "おやすみなさい\nせんせい",
        "せんせい おはよ",
      ],
      'correctAnswerIndex': 0
    },
    {
      'question': 'What is the greeting for evening?',
      'type': 'textTile',
      'options': [
        "おはようございます",
        "こんばんは",
        "こんにちは",
      ],
      'correctAnswerIndex': 1
    },
    {
      'question': 'Trace あか (Aka)',
      'type': 'drawingCanvas', // New quiz type for drawing canvas
    },
  ];

  void showCustomBottomSheet(
    BuildContext context, {
    required bool isCorrect,
    required String message,
    required Function action,
    String buttonText = 'NEXT',
    Color? buttonColor,
    Color? messageColor, // New parameter to customize the message text color
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green[50] : Colors.red[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons
                            .check_circle_outline // Correct answer icon (green)
                        : Icons
                            .flag_circle_outlined, // Incorrect answer icon (flag)
                    color: isCorrect
                        ? Colors.green
                        : Colors
                            .red, // Only turns red when the answer is incorrect
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: TextStyle(
                      color:
                          messageColor ?? // Use the custom message color if provided
                              (isCorrect
                                  ? Colors.green
                                  : Colors
                                      .red), // Text color is green for correct, red for incorrect
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  action();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor ??
                      (isCorrect
                          ? Colors.green
                          : Colors
                              .red), // Button is green for correct, red for incorrect
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show the check bottom sheet
  // Show the check bottom sheet
  void showCheckBottomSheet(BuildContext context) {
    showCustomBottomSheet(
      context,
      isCorrect: true, // Force the CHECK icon to be green when checking
      message: 'Check your answer',
      action: _checkAnswer,
      buttonText: 'CHECK',
      buttonColor: Colors.green, // Ensure the CHECK button is always green
      messageColor: Colors.green,
    );
  }

  void _checkAnswer() {
    setState(() {
      checkPressed = true;
      bool correct = selectedOptionIndex ==
          quizzes[currentQuizIndex]['correctAnswerIndex'];
      isAnswerCorrect = correct;
      showCustomBottomSheet(
        context,
        isCorrect: correct,
        message: correct ? 'Correct!' : 'Try Again',
        action: correct ? moveToNextQuiz : () {},
        buttonText: correct ? 'NEXT' : 'RETRY',
      );
    });
  }

  void moveToNextQuiz() {
    setState(() {
      selectedOptionIndex = null;
      checkPressed = false;
      isAnswerCorrect = false;
      currentQuizIndex = (currentQuizIndex + 1) % quizzes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text("QUIZ"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to the previous page
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: (currentQuizIndex + 1) / quizzes.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                quizzes[currentQuizIndex]['question'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: buildQuizWidget(quizzes[currentQuizIndex]['type']),
          ),
        ],
      ),
    );
  }

  Widget buildQuizWidget(String quizType) {
    List<String>? options = quizzes[currentQuizIndex]['options'];
    if (quizType == 'card') {
      return buildCardQuiz(options!);
    } else if (quizType == 'textTile') {
      return buildTextTileQuiz(options!);
    } else if (quizType == 'drawingCanvas') {
      return buildDrawingCanvas(); // Call to the new drawing canvas
    }
    return Container(); // Fallback for unknown quiz types
  }

  Widget buildDrawingCanvas() {
    // Define container size
    double containerSize = MediaQuery.of(context).size.width * 0.8;
    return Center(
      child: Container(
        height: containerSize,
        width: containerSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: Stack(
          children: [
            const Center(
              child: FittedBox(
                fit: BoxFit
                    .contain, // Ensures the text fits within the container
                child: Text(
                  'あか',
                  style: TextStyle(
                    fontFamily: 'KanjiStrokeOrders',
                    color: Colors.grey,
                    fontSize: 300,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  points = [
                    limitToBounds(
                        details.localPosition, containerSize, containerSize)
                  ];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  points.add(limitToBounds(
                      details.localPosition, containerSize, containerSize));
                });
              },
              onPanEnd: (details) {
                setState(() {
                  lines.add(points);
                  points = [];
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawPainter(lines: lines, currentPoints: points),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset limitToBounds(Offset point, double width, double height) {
    double dx = point.dx.clamp(0.0, width);
    double dy = point.dy.clamp(0.0, height);
    return Offset(dx, dy);
  }

  Widget buildCardQuiz(List<String> options) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) => quizOption(options[index], index),
    );
  }

  Widget buildTextTileQuiz(List<String> options) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (context, index) => quizOption(options[index], index),
    );
  }

  Widget quizOption(String optionText, int index) {
    bool isSelected = selectedOptionIndex == index;

    // Blue border when selected, color changes based on selection and answer check
    Color borderColor = isSelected
        ? (checkPressed
            ? (isAnswerCorrect ? Colors.green : Colors.red)
            : Colors.blue)
        : Colors.transparent;

    // Text and icon color update based on answer correctness
    Color optionColor =
        Colors.black; // Default black color for unselected options
    if (isSelected && checkPressed) {
      optionColor = isAnswerCorrect ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOptionIndex = index;
        });
        showCheckBottomSheet(context); // Show the 'CHECK' button when tapped
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected && checkPressed
              ? (isAnswerCorrect ? Colors.green[100] : Colors.red[100])
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: borderColor, width: 3), // Set the border color dynamically
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volume_up,
              size: 24,
              color: optionColor, // Icon color now changes based on correctness
            ),
            const SizedBox(height: 8),
            Text(
              optionText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: optionColor, // Text color remains black until checked
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DrawPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> currentPoints;

  DrawPainter({required this.lines, required this.currentPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Draw all saved lines
    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    // Draw the currently drawing line
    for (int i = 0; i < currentPoints.length - 1; i++) {
      canvas.drawLine(currentPoints[i], currentPoints[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint when the line changes
  }
}
