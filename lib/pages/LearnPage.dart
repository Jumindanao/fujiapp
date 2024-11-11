import 'package:flutter/material.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:fuji_app/pages/QuizPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'NavBar.dart';
import 'dart:math'; // For random status assignment

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  List<Map<String, dynamic>> units = []; // Store fetched units
  Map<String, List<Map<String, dynamic>>> unitLessons =
      {}; // Store lessons for each unit
  Map<String, Map<String, double>> lessonProgress =
      {}; // Store fetched progress
  bool isLoading = true; // Loading state
  String courseID = '';
  String userID = '';
  int userpoints = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isLoading) {
      _fetchUnitsAndLessons();
      fetchThepoints(); // Fetch data on initial load
    } else {
      setState(() {
        _fetchUnitsAndLessons();
        fetchThepoints();
      });
    }
  }

  Future<void> fetchThepoints() async {
    try {
      final responsedPoint = await Supabase.instance.client
          .from('profiles')
          .select('points')
          .eq('id', userID)
          .single();
      if (responsedPoint.isNotEmpty) {
        userpoints = responsedPoint['points'] as int;
        print(userpoints);
      } else {
        userpoints = 0;
        print('no points');
      }
    } catch (e) {}
  }

  // Fetch units, lessons, and challenge progress in one go
  Future<void> _fetchUnitsAndLessons() async {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    courseID = args['courseID'] as String;
    userID = args['userData'].id;

    final unitsResponse = await Supabase.instance.client
        .from('UnitsTable')
        .select('UnitID, CourseID, Title, Description')
        .eq('CourseID', courseID);

    units = List<Map<String, dynamic>>.from(unitsResponse);

    if (units.isNotEmpty) {
      // Fetch lessons and progress for each unit
      for (var unit in units) {
        await _fetchLessonsAndProgress(unit['UnitID']);
      }
    } else {
      print('No units found.');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Fetch lessons for a specific unit and calculate progress
  Future<void> _fetchLessonsAndProgress(String unitID) async {
    final lessonsResponse = await Supabase.instance.client
        .from('LessonsTable')
        .select('LessonID, Title')
        .eq('UnitID', unitID);

    final lessons = List<Map<String, dynamic>>.from(lessonsResponse);

    for (var lesson in lessons) {
      String lessonID = lesson['LessonID'];

      // Check if progress for this lesson is already fetched
      if (!lessonProgress.containsKey(lessonID)) {
        final progressData = await _fetchChallengeProgress(lessonID, userID);
        lessonProgress[lessonID] = progressData;
      }

      // Assign status based on the fetched or cached progress
      double progress = lessonProgress[lessonID]?['progress'] ?? 0.0;
      lesson['status'] = _determineLessonStatus(progress);
    }

    unitLessons[unitID] = lessons;
  }

  String _determineLessonStatus(double progress) {
    if (progress >= 100.0) {
      // Set 100.0 as the threshold for completion
      return 'completed';
    } else if (progress > 0.0) {
      return 'in-progress';
    } else {
      return 'not-started';
    }
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in-progress':
        return Icons.hourglass_bottom;
      case 'not-started':
      default:
        return Icons.circle_outlined;
    }
  }

  Future<Map<String, double>> _fetchChallengeProgress(
      String lessonID, String userID) async {
    // Fetch the challenge IDs for the given lesson
    final challengeIDsResponse = await Supabase.instance.client
        .from('ChallengesTable')
        .select('ChallengeID')
        .eq('LessonID', lessonID);

    final List<String> challengeIDs = challengeIDsResponse
        .map((row) => row['ChallengeID'] as String)
        .toList();

    // If there are no challenges for this lesson, return 0% progress
    if (challengeIDs.isEmpty) {
      print('No challenges for lesson $lessonID.');
      return {'progress': 0.0, 'totalChallenges': 0.0};
    }

    // Fetch challenge progress data for the user if available
    int completedChallenges = 0;
    final completedChallengesResponse = await Supabase.instance.client
        .from('ChallengeProgressTable')
        .select('ChallengeID, isComplete')
        .eq('UserID', userID)
        .inFilter('ChallengeID', challengeIDs);

    // If there's no data in the ChallengeProgressTable, assume no completed challenges
    if (completedChallengesResponse.isEmpty) {
      print('No progress data for challenges of lesson $lessonID.');
      return {
        'progress': 0.0, // No completed challenges, so progress is 0%
        'totalChallenges': challengeIDs.length.toDouble(),
      };
    }

    // Count the completed challenges from the fetched data
    completedChallenges = completedChallengesResponse
        .where((row) => row['isComplete'] == true)
        .length;

    // Calculate the progress percentage
    final int totalChallenges = challengeIDs.length;
    final double progressPercentage = totalChallenges > 0
        ? (completedChallenges / totalChallenges) * 100
        : 0.0;

    // Print statements for debugging
    print('Total challenges for lesson $lessonID: $totalChallenges');
    print('Completed progress for lesson $lessonID: $progressPercentage%');

    return {
      'progress': progressPercentage, // Return progress as a percentage
      'totalChallenges': totalChallenges.toDouble(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String selectedCourse = args['selectedCourse'] as String;
    final Readdata userData = args['userData'] as Readdata;
    final userId = userData.id; // Extract userID

    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: NavBar(userData: userData),
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                courseID = "";
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text(
                      selectedCourse,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/197/197604.png',
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 4),
                Icon(Icons.star, color: Colors.yellow[600], size: 20),
                SizedBox(
                  width: (userpoints.toString().length * 8)
                      .toDouble(), // Adjust width based on digits
                  child: Text(
                    '$userpoints',
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: units.length,
                itemBuilder: (context, index) {
                  return _buildUnitSection(
                    context,
                    units[index]['Title'] ?? 'Unit', // Unit Title
                    units[index]['Description'] ??
                        'Description not available', // Unit Description
                    units[index]['UnitID'], // Pass UnitID to fetch lessons
                    index,
                    userId, // Pass userID to the _buildUnitSection
                  );
                },
              ),
      ),
    );
  }

  Widget _buildUnitSection(
      BuildContext context,
      String unitTitle,
      String unitDescription,
      String unitID,
      int index,
      String userID // Accept userID here
      ) {
    List<Map<String, dynamic>> lessonsForUnit = unitLessons[unitID] ?? [];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF65a0b6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unitTitle,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    unitDescription,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.center,
          children: lessonsForUnit.map((lesson) {
            // Pass LessonID along with lesson title and status
            return _buildCircularIcon(
              lesson['Title'],
              _getIconForStatus(lesson['status']),
              lesson['LessonID'],
              userID, // Pass userID to _buildCircularIcon
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCircularIcon(String lessonTitle, IconData defaultIcon,
      String lessonID, String userID) {
    return FutureBuilder<Map<String, double>>(
      future: _fetchChallengeProgress(lessonID, userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        double progress = snapshot.data?['progress'] ?? 0.0;
        double totalChallenges = snapshot.data?['totalChallenges'] ?? 0.0;

        // Adjust progress to be between 0.0 and 1.0 for CircularProgressIndicator
        double progressFraction = progress / 100.0;

        // Determine icon based on progress
        String status = _determineLessonStatus(progress);
        IconData iconData = _getIconForStatus(status);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuizPage(),
                settings: RouteSettings(
                  arguments: {
                    'lessonID': lessonID,
                    'userID': userID,
                  },
                ),
              ),
            );
          },
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: totalChallenges > 0 ? progressFraction : null,
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalChallenges > 0
                            ? (progress == 1.0 ? Colors.green : Colors.green)
                            : Colors.transparent,
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  Icon(iconData, size: 40, color: Colors.black),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lessonTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
