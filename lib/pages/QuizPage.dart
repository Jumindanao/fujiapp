import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import the flutter_tts package
import 'package:flutter/material.dart' hide Ink; // Hide Ink from material
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import 'package:audioplayers/audioplayers.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentPoints = 0;
  List<Map<String, dynamic>> quizzes = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  int currentQuizIndex = 0;
  int? selectedOptionIndex;
  bool checkPressed = false;
  bool isAnswerCorrect = false;
  bool hasQuizzes = false; // New variable to track if quizzes are available
  List<List<Offset>> lines = [];
  List<Offset> points = [];
  List<String> theChallengeProgressIDs = [];
  String thechallengeID = '';
  String userID = '';

  String currentLessonID = '';
  bool userAllDone = false;

  final FlutterTts flutterTts = FlutterTts(); // Initialize TTS instance
  final mlkit.Ink _ink = mlkit
      .Ink(); // Use prefixed Ink class // Object to store strokes for recognition
  List<mlkit.StrokePoint> _points = []; // Stroke points
  mlkit.DigitalInkRecognizer? _digitalInkRecognizer;
  final mlkit.DigitalInkRecognizerModelManager _modelManager =
      mlkit.DigitalInkRecognizerModelManager();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _fetchCurrentPoints();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchQuizzes();
    _initializeRecognizer();
    _initializeTTS();
    _audioPlayer = AudioPlayer();
  }

  // DIRI magsugod ang mag check if wala ba niya na answeran
  Future<bool> checkIncompleteQuiz(bool naayfalse) async {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    userID = args['userID'];
    String? checkChallengeID;
    bool isnaayfalse = false;

    // Query the ChallengeProgressTable for incomplete quizzes
    final response = await supabase
        .from('ChallengeProgressTable')
        .select('ChallengeID')
        .eq('UserID', userID)
        .eq('isComplete', false);

    // Check if any records were found
    if (response.isNotEmpty) {
      // Store the first ChallengeID found
      checkChallengeID = response[0]['ChallengeID'] as String?;

      // Find the index of the quiz based on the retrieved ChallengeID
      final index =
          quizzes.indexWhere((quiz) => quiz['ChallengeID'] == checkChallengeID);

      if (index != -1) {
        setState(() {
          currentQuizIndex = index; // Update currentQuizIndex
          // Restore any additional fields if necessary
        });
        currentQuizIndex = index;
        return isnaayfalse = true;
      } else {
        print("ChallengeID $checkChallengeID not found in quizzes.");
        return isnaayfalse;
      }
    } else {
      print("No incomplete quizzes found for UserID: $userID.");
      return false;
    }
  }

//END sa pag check or mubalik sa index

  Future<void> _initializeRecognizer() async {
    String _language = 'ja'; // Set language to Japanese (Kanji)
    _digitalInkRecognizer = mlkit.DigitalInkRecognizer(languageCode: _language);

    // Check if the model is already downloaded, otherwise download it
    bool isDownloaded = await _modelManager.isModelDownloaded(_language);
    if (!isDownloaded) {
      await _modelManager.downloadModel(_language);
    }
  }

  Future<void> _fetchCurrentPoints() async {
    try {
      final userProfile = await supabase
          .from('profiles')
          .select('points')
          .eq('id', userID)
          .single();

      setState(() {
        _currentPoints =
            userProfile['points'] ?? 0; // Initialize the local points
      });
    } catch (error) {
      print('Error fetching points: $error');
    }
  }

// Function to update the points both locally and in Supabase
  Future<void> _updateUserPoints(int pointsToAdd) async {
    setState(() {
      _currentPoints += pointsToAdd; // Update the local points first
    });

    try {
      // Update points in the database
      await supabase.from('profiles').update({
        'points': _currentPoints, // Use the updated local points
      }).eq('id', userID);

      print('Points updated successfully!');
    } catch (error) {
      print('Error updating points: $error');
    }
  }
  // End sa Function to update ang points sa supabase

  //DIRI mag start ang checking para sa practice
  Future<bool?> isPractice() async {
    try {
      final isPracticeresponse = await supabase
          .from('CheckingTable')
          .select('isDone')
          .eq('ChallengeProgressID', theChallengeProgressIDs);

      if (isPracticeresponse.isEmpty) {
        userAllDone = false;
        return userAllDone;
      } else {
        // Set userAllDone based on whether all isDone columns are true
        userAllDone = isPracticeresponse.every((row) => row['isDone'] == true);
        return userAllDone; // Return the calculated value
      }
    } catch (error) {
      // Error handling
      print('Error: $error');
      return null; // Return null in case of an error
    }
  }

  //

  @override
  void dispose() {
    _digitalInkRecognizer?.close(); // Close recognizer when not needed
    super.dispose();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage("ja-JP"); // Set language to Japanese
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(3.0);
  }

  Future<void> _fetchQuizzes() async {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String lessonID = args['lessonID'];
    currentLessonID = lessonID;

    final response = await Supabase.instance.client
        .from('ChallengesTable')
        .select(
            'ChallengeID, Type, Questions, Options:ChallengeOptions(ChallengeOptionID, Answers, Correct)')
        .eq('LessonID', lessonID);

    final data = response;

    if (data.isNotEmpty) {
      thechallengeID = data[currentQuizIndex]['ChallengeID'];
      setState(() {
        quizzes = List<Map<String, dynamic>>.from(data);
        hasQuizzes = true; // IF NA FETCH ANG QUIZ MAHIMONG TRUE
      });
    } else {
      setState(() {
        hasQuizzes = false; // IF WALA THEN FALSE
        thechallengeID = 'nothing';
      });
    }
  }

  Future<void> insertChallengeProgressTable() async {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    userID = args['userID'];

    // Get the challenge ID dynamically based on the current quiz
    thechallengeID = quizzes[currentQuizIndex]['ChallengeID'];

    const bool iscomplete = true;

    // Check if the progress already exists to prevent duplicates
    final existingProgress = await Supabase.instance.client
        .from('ChallengeProgressTable')
        .select()
        .eq('ChallengeID', thechallengeID)
        .eq('UserID', userID)
        .maybeSingle();

    if (existingProgress == null) {
      // Insert progress only if it doesn't already exist
      await Supabase.instance.client.from('ChallengeProgressTable').insert({
        'ChallengeID': thechallengeID,
        'UserID': userID,
        'isComplete': iscomplete,
      });
      final response = await Supabase.instance.client
          .from('ChallengeProgressTable')
          .select('CPTID') // Assuming CPTID is the primary key
          .eq('UserID', userID)
          .eq('ChallengeID', thechallengeID);

      if (response.isNotEmpty) {
        for (var item in response) {
          theChallengeProgressIDs.add(item['CPTID']); // Store CPTIDs
        }
      }
    } else {
      // Check if 'isComplete' is false and update if necessary
      if (existingProgress['isComplete'] == false) {
        await Supabase.instance.client
            .from('ChallengeProgressTable')
            .update({'isComplete': iscomplete})
            .eq('ChallengeID', thechallengeID)
            .eq('UserID', userID);

        print(
            'Updated isComplete to true for ChallengeID: $thechallengeID and UserID: $userID');
      } else {
        print(
            'Progress already complete for ChallengeID: $thechallengeID and UserID: $userID');
      }
    }
  }

  Future<void> speakOption(String option) async {
    await flutterTts.speak(option);
  }

  Widget buildQuizWidget(String quizType) {
    List<String> options = quizzes[currentQuizIndex]['Options']
        .map<String>((option) => option['Answers'] as String)
        .toList();

    if (quizType == 'Select') {
      return buildCardQuiz(options);
    } else if (quizType == 'Assist') {
      return buildTextTileQuiz(options);
    } else if (quizType == 'Write') {
      // Fetch the correct Kanji (answer) for the 'Write' quiz type
      String correctKanji = quizzes[currentQuizIndex]['Options']
          .firstWhere((option) => option['Correct'] == true)['Answers'];

      // Pass the correct Kanji to the buildDrawingCanvas method
      return buildDrawingCanvas(correctKanji);
    }
    return Container(); // Fallback for unknown quiz types
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

  Widget buildDrawingCanvas(String kanjiText) {
    double containerSize = MediaQuery.of(context).size.width * 0.8;

    /// DIRI MAG SUGOD UG RECOGNITION SA TEXT
    Future<void> recogniseText(
        BuildContext context, String correctKanji) async {
      if (_digitalInkRecognizer != null && _ink.strokes.isNotEmpty) {
        try {
          final candidates = await _digitalInkRecognizer?.recognize(_ink);
          String recognizedText = '';
          if (candidates != null && candidates.isNotEmpty) {
            recognizedText = candidates.first.text;
          }
          bool correct = recognizedText == correctKanji;
          if (correct) {
            _audioPlayer.play(AssetSource('correctsound.wav'));
            insertChallengeProgressTable(); // Call the function here
            _updateUserPoints(10);
          } else {
            _audioPlayer
                .play(AssetSource('wrongsound.wav')); // Don't await here
          }

          // Show custom bottom sheet with the recognition result
          showCustomBottomSheet(
            context,
            isCorrect: correct,
            message: correct ? 'Correct!' : 'Wrong Please Try Again',
            action:
                correct ? moveToNextQuiz : () {}, // action for NEXT or RETRY
            buttonText: correct ? 'NEXT' : 'RETRY',
            buttonColor: correct ? Colors.green : Colors.red,
            messageColor: correct ? Colors.green : Colors.red,
          );
        } catch (e) {
          // Handle recognition error and show in bottom sheet
          showCustomBottomSheet(
            context,
            isCorrect: false,
            message: 'Recognition Error: $e',
            action: () {},
            buttonText: 'RETRY',
            buttonColor: Colors.red,
            messageColor: Colors.red,
          );
        }
      } else {
        // If no strokes are drawn, inform the user to draw before recognition
        showCustomBottomSheet(
          context,
          isCorrect: false,
          message: 'Please draw before recognition',
          action: () {},
          buttonText: 'RETRY',
          buttonColor: Colors.red,
          messageColor: Colors.red,
        );
      }
    }

    /// DIRI MAG END ANG RECOGNITION SA TEXT
    return Center(
      child: Column(
        children: [
          Container(
            height: containerSize,
            width: containerSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: Stack(
              children: [
                // Display Kanji as background
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      kanjiText, //CORRECT ANSWER GIKAN SA DATABASE(SUPABASE)
                      style: const TextStyle(
                        fontFamily: 'KanjiStrokeOrders',
                        color: Colors.grey,
                        fontSize: 300,
                      ),
                    ),
                  ),
                ),
                // Handle drawing
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _ink.strokes.add(mlkit.Stroke()); // Start a new stroke
                      _points = [
                        mlkit.StrokePoint(
                          x: limitToBounds(details.localPosition, containerSize,
                                  containerSize)
                              .dx,
                          y: limitToBounds(details.localPosition, containerSize,
                                  containerSize)
                              .dy,
                          t: DateTime.now().millisecondsSinceEpoch,
                        )
                      ];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      // Add points to the current stroke
                      _points.add(mlkit.StrokePoint(
                        x: limitToBounds(details.localPosition, containerSize,
                                containerSize)
                            .dx,
                        y: limitToBounds(details.localPosition, containerSize,
                                containerSize)
                            .dy,
                        t: DateTime.now().millisecondsSinceEpoch,
                      ));
                      _ink.strokes.last.points = _points;
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      // Convert StrokePoints to Offsets and store the stroke
                      lines.add(_points
                          .map((point) => Offset(point.x, point.y))
                          .toList());
                      _points = [];
                    });
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: DrawPainter(
                      lines: lines,
                      currentPoints: _points
                          .map((point) => Offset(point.x, point.y))
                          .toList(), // Convert to Offset
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Buttons for recognition and clearing the pad
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    recogniseText(context, kanjiText), // Recognize button
                child: const Text('Recognize'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    lines.clear();
                    _ink.strokes.clear(); // Clear Ink strokes
                  });
                },
                child: Text('Clear Pad'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Offset limitToBounds(Offset point, double width, double height) {
    double x = point.dx.clamp(0.0, width);
    double y = point.dy.clamp(0.0, height);
    return Offset(x, y);
  }

  Widget quizOption(String optionText, int index) {
    bool isSelected = selectedOptionIndex == index;

    Color borderColor = isSelected
        ? (checkPressed
            ? (isAnswerCorrect ? Colors.green : Colors.red)
            : Colors.blue)
        : Colors.transparent;

    Color optionColor = Colors.black;
    if (isSelected && checkPressed) {
      optionColor = isAnswerCorrect ? Colors.green : Colors.red;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOptionIndex = index;

          // Check if selected option is correct
          isAnswerCorrect =
              quizzes[currentQuizIndex]['Options'][index]['Correct'];
        });
        showCheckBottomSheet(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected && checkPressed
              ? (isAnswerCorrect ? Colors.green[100] : Colors.red[100])
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 3),
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
            GestureDetector(
              onTap: () => speakOption(optionText), // Speak option on tap
              child: Icon(
                Icons.volume_up,
                size: 24,
                color: optionColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              optionText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: optionColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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

  void _checkAnswer() async {
    setState(() {
      checkPressed = true;
      bool correct =
          quizzes[currentQuizIndex]['Options'][selectedOptionIndex]['Correct'];
      isAnswerCorrect = correct;
    });

    // Play correct or wrong answer sound without awaiting the result
    if (isAnswerCorrect) {
      _audioPlayer.play(AssetSource('correctsound.wav')); // Don't await here
      await _updateUserPoints(10); //it will add points in the database
    } else {
      _audioPlayer.play(AssetSource('wrongsound.wav')); // Don't await here
    }

    // Call the database insertion if the answer is correct
    if (isAnswerCorrect) {
      insertChallengeProgressTable();
    }

    // Show custom bottom sheet immediately
    showCustomBottomSheet(
      context,
      isCorrect: isAnswerCorrect,
      message: isAnswerCorrect ? 'Correct!' : 'Try Again',
      action: isAnswerCorrect ? moveToNextQuiz : () {},
      buttonText: isAnswerCorrect ? 'NEXT' : 'RETRY',
    );
  }

  // DESIGN FOR CHECKING SA WRITING NA QUIZ
  void _checkWritingAnswer(BuildContext context, String correctKanji) async {
    if (_digitalInkRecognizer != null && _ink.strokes.isNotEmpty) {
      try {
        final candidates = await _digitalInkRecognizer?.recognize(_ink);
        String recognizedText = '';
        if (candidates != null && candidates.isNotEmpty) {
          recognizedText = candidates.first.text;
        }

        bool correct = recognizedText == correctKanji;

        // Insert progress into the database if the answer is correct
        if (correct) {
          insertChallengeProgressTable(); // Call the function here
        }

        // Show custom bottom sheet
        showCustomBottomSheet(
          context,
          isCorrect: correct,
          message: correct ? 'Correct!' : 'Try Again',
          action: correct ? moveToNextQuiz : () {},
          buttonText: correct ? 'NEXT' : 'RETRY',
          buttonColor: correct ? Colors.green : Colors.red,
          messageColor: correct ? Colors.green : Colors.red,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Recognition Error: $e'),
          duration: const Duration(seconds: 2),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please draw before recognition'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  // END SA DESIGN SA WRITING QUIZ

  void moveToNextQuiz() async {
    if (currentQuizIndex + 1 >= quizzes.length) {
      await _audioPlayer.play(AssetSource('finishedsound.wav'));

      int finalPoints = _currentPoints;
      // bool naayfalse = false;
      // checkIncompleteQuiz(naayfalse);
      // if (naayfalse = true) {
      //   insertChallengeProgressTableIncomplete();
      // }
      // else {
      Navigator.pushNamed(
        context,
        '/FinishPage',
        arguments: {
          'currentpoints': finalPoints,
          'userID': userID,
          'quizIndex': currentQuizIndex,
          'lessonID': currentLessonID,
        },
      );
    } else {
      setState(() {
        selectedOptionIndex = null;
        checkPressed = false;
        isAnswerCorrect = false;
        currentQuizIndex = (currentQuizIndex + 1) % quizzes.length;
      });
    }
  }

  Future<void> insertChallengeProgressTableIncomplete() async {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    userID = args['userID']; // Fetch user ID from passed arguments

    // Get the challenge ID dynamically based on the current quiz
    // thechallengeID = quizzes[currentQuizIndex]['ChallengeID'];

    const bool iscomplete = false;

    // Check if the progress already exists to prevent duplicates
    final existingProgress = await Supabase.instance.client
        .from('ChallengeProgressTable')
        .select()
        .eq('ChallengeID', thechallengeID)
        .eq('UserID', userID)
        .maybeSingle();

    if (existingProgress == null) {
      // Insert progress only if it doesn't already exist
      await Supabase.instance.client.from('ChallengeProgressTable').insert({
        'ChallengeID': thechallengeID,
        'UserID': userID,
        'isComplete': iscomplete,
      });
      final response = await Supabase.instance.client
          .from('ChallengeProgressTable')
          .select('CPTID')
          .eq('UserID', userID)
          .eq('ChallengeID', thechallengeID);

      if (response.isNotEmpty) {
        for (var item in response) {
          theChallengeProgressIDs.add(item['CPTID']); // Store CPTIDs
        }
      }
    } else {
      print(
          'Progress already exists for ChallengeID: $thechallengeID and UserID: $userID');
    }
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
            insertChallengeProgressTableIncomplete(); // This can also be optional based on completion
            Navigator.pop(context, true); // Return a true flag
          },
        ),
      ),
      body: !hasQuizzes // Check if there are quizzes
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "There is no lesson at the moment.",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : quizzes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LinearProgressIndicator(
                        value: (currentQuizIndex + 1) / quizzes.length,
                        backgroundColor: Colors.grey[300],
                        color: Colors.greenAccent,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        quizzes[currentQuizIndex]
                            ['Questions'], // Display the question
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child:
                            buildQuizWidget(quizzes[currentQuizIndex]['Type']),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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

    // Draw stored lines
    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    // Draw current points
    for (int i = 0; i < currentPoints.length - 1; i++) {
      canvas.drawLine(currentPoints[i], currentPoints[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DrawPainter oldDelegate) => true;
}
