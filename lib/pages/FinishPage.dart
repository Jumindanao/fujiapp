import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import 'package:fuji_app/classess/readdata.dart';
import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});

  @override
  FinishPageState createState() => FinishPageState();
}

class FinishPageState extends State<FinishPage> {
  late ConfettiController _confettiController;
  late int currentPoints;
  int thefinalPoint = 0;
  bool isLoading = true;
  String userID = '';
  int thequizIndex = 0;
  String theCourseID = '';
  String theselectedCourse = '';
  String passedLessonID = '';

  late List<String> cptids = []; // Initialize cptids as an empty list
  final supabase = Supabase.instance.client;
  bool recordsInserted = false;
  Readdata? userData;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    currentPoints = args['currentpoints'];
    userID = args['userID'];
    thequizIndex = args['quizIndex']; // Assuming userID is passed in args
    passedLessonID = args['lessonID'];

    thefinalPoint = currentPoints;
    // Fetch CPTIDs based on userID
    _getChallengeProgressTable(userID).then((_) {
      print('CPT IDs: $cptids');
      insertCheckingTable(cptids); // Insert after fetching
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _getChallengeProgressTable(String userID) async {
    try {
      // Fetch all columns from the ChallengeProgressTable where userID matches
      final response = await supabase
          .from('ChallengeProgressTable')
          .select()
          .eq('UserID', userID);

      if (response.isNotEmpty) {
        for (var item in response) {
          String cptid = item['CPTID'] as String; // Get the CPTID
          cptids.add(cptid); // Add the CPTID to the list
          print('CPTID: $cptid'); // Do whatever you need with each CPTID
        }
      } else {
        print('No records found for userID: $userID');
      }
    } catch (error) {
      print('Error fetching Challenge Progress Table: $error');
    }
  }

  Future<void> insertCheckingTable(List<String> cptids) async {
    try {
      print('Attempting to insert cptids: $cptids');

      final Set<String> existingIDs = {};

      for (String cptid in cptids) {
        final existingRecordResponse = await Supabase.instance.client
            .from('CheckingTable')
            .select('ChallengeProgressID')
            .eq('ChallengeProgressID', cptid);

        if (existingRecordResponse.isNotEmpty) {
          existingIDs.add(cptid);
        }
      }

      final List<Map<String, dynamic>> recordsToInsert = cptids
          .where((cptid) => !existingIDs.contains(cptid))
          .map((cptid) => {
                'ChallengeProgressID': cptid,
                'isDone': true,
              })
          .toList();

      print('Records to insert: $recordsToInsert');

      if (recordsToInsert.isNotEmpty) {
        final response = await Supabase.instance.client
            .from('CheckingTable')
            .insert(recordsToInsert);

        if (response.error == null) {
          recordsInserted = true;
          print('Data inserted successfully: ${response.data}');
        }
      } else {
        recordsInserted = false; // No new records means points should be 0
      }

      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          thefinalPoint = recordsInserted ? thefinalPoint : 0;
          isLoading = false; // Set loading to false after completion
        });
      }
    } catch (error) {
      print('Error inserting data: $error');
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading in case of error
        });
      }
    }
  }

  //END
  @override
  Widget build(BuildContext context) {
    if (userData != null) {
      print(
          'User Data: ${userData!.theusername}, ${userData!.theemail}, ${userData!.therole}, ${userData!.isPrivacy}');
    } else {
      print('No user data found');
    }
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(), // Show a loading spinner
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),

                // Display the final points once loading is done
                Text(
                  thefinalPoint > 0
                      ? 'Congratulations! You earned $thefinalPoint points!'
                      : 'You have already completed this quiz. No points earned this time.',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _scoreBox(
                        label: 'TOTAL Points',
                        value: '$thefinalPoint', // Display final points
                        color: Colors.orange,
                        icon: Icons.circle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _bottomButton(
                          text: 'PRACTICE AGAIN',
                          color: Colors.grey.shade300,
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/QuizPage',
                              arguments: {
                                'userID': userID,
                                'quizIndex':
                                    thequizIndex, // Or whatever index you want to restart from
                                'lessonID': passedLessonID,
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _bottomButton(
                          text: 'CONTINUE',
                          color: Colors.green,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.popUntil(
                                context, ModalRoute.withName('/LearnPage'));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (thefinalPoint > 0) // Show confetti only if points are earned
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: _drawStar,
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

  Path _drawStar(Size size) {
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
