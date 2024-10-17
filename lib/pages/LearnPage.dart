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
  bool isLoading = true; // Loading state
  String courseID = ''; // Declare courseID here

  // Map to hold unit titles and their corresponding icons
  final Map<String, IconData> unitIcons = {
    'Hiragana 1': Icons.language,
    'Basics': Icons.egg,
    'Animals': Icons.pets,
    'Foods': Icons.restaurant,
    'Places': Icons.place,
    'Travel': Icons.airplanemode_active,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isLoading) {
      _fetchUnitsAndLessons();
    }
  }

  // Fetch units and lessons in one go
  Future<void> _fetchUnitsAndLessons() async {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    courseID = args['courseID'] as String; // Assign courseID here
    // Fetch units from the database
    final unitsResponse = await Supabase.instance.client
        .from('UnitsTable')
        .select('UnitID, CourseID, Title, Description')
        .eq('CourseID', courseID);

    // Extract data from the response
    final List<dynamic>? unitsData = unitsResponse as List<dynamic>?;

    if (unitsData != null) {
      // Convert dynamic data to List<Map<String, dynamic>>
      units = List<Map<String, dynamic>>.from(unitsData);

      // For each unit, fetch its lessons and store them in a map
      for (var unit in units) {
        String unitID = unit['UnitID'];
        await _fetchLessonsForUnit(
            unitID); // Fetch lessons for each unit and store them
      }
    } else {
      print('No units found.');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Fetch lessons for a specific unitID and store them in the unitLessons map
  Future<void> _fetchLessonsForUnit(String unitID) async {
    final response = await Supabase.instance.client
        .from('LessonsTable')
        .select('LessonID, Title, UnitID')
        .eq('UnitID', unitID);

    // Extract data from the response
    final List<dynamic>? data = response as List<dynamic>?;

    if (data != null) {
      // Convert dynamic data to List<Map<String, dynamic>> and add simulated status
      List<Map<String, dynamic>> lessons =
          List<Map<String, dynamic>>.from(data).map((lesson) {
        return {
          ...lesson,
          'status': _getRandomStatus(), // Assign random status to each lesson
        };
      }).toList();

      // Store the lessons under the specific unitID
      unitLessons[unitID] = lessons;
    } else {
      unitLessons[unitID] = []; // If no lessons found, store an empty list
      print('No lessons found for UnitID: $unitID');
    }
  }

  // Function to return a random status (simulating lesson progress)
  String _getRandomStatus() {
    List<String> statuses = ['not-started', 'in-progress', 'completed'];
    return statuses[Random().nextInt(statuses.length)];
  }

  // Function to determine which icon to show based on lesson status
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
            const Spacer(),
            Row(
              children: [
                Icon(Icons.circle, color: Colors.yellow[600], size: 16),
                const SizedBox(width: 4),
                const Text(
                  '0',
                  style: TextStyle(color: Colors.black),
                ),
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
    IconData iconData = unitIcons[unitTitle] ?? Icons.help;

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

  Widget _buildCircularIcon(
      String lessonTitle, IconData iconData, String lessonID, String userID) {
    return GestureDetector(
      onTap: () {
        // Navigate to QuizPage and pass the lessonID and userID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QuizPage(),
            settings: RouteSettings(
              arguments: {
                'lessonID': lessonID,
                'userID': userID, // Passing the userID to QuizPage
              },
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 40, color: Colors.black),
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
  }
}
