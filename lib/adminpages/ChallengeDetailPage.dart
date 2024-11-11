import 'package:flutter/material.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeDetailPage extends StatefulWidget {
  const ChallengeDetailPage({super.key});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  // Initialize TextEditingController with a default value
  TextEditingController questionController = TextEditingController();

  String challengeid = '';
  String thequestion = '';
  String lessonid = '';
  String? selectedType;
  String? selectedLesson;
  String fetchLesson = '';
  String insertQuestion = '';

  List<String> lessons = [];
  final Map<String, String> lessonIdMap =
      {}; // Map to hold LessonID for each lesson
  final supabase = Supabase.instance.client;

  final List<String> types = ['Select', 'Assist', 'Write'];

  // Flag to check if the question has been initialized already
  bool isQuestionInitialized = false;

  @override
  void initState() {
    super.initState();
    selectedType = types[0]; // Ensure selectedType defaults to 'Select'
    selectedLesson = null; // Ensure selectedLesson starts as null until fetched
    fetchLessons();
  }

  @override
  void dispose() {
    questionController.dispose(); // Dispose the TextEditingController when done
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is ReadChallenges) {
      challengeid = arguments.challengeid;
      lessonid = arguments.lessonid;
      thequestion = arguments.questions;
      fetchLesson = arguments.lesson;

      // Only set questionController.text if it's not already set
      if (!isQuestionInitialized) {
        questionController.text = thequestion;
        isQuestionInitialized =
            true; // Mark that the question has been initialized
      }
    }
  }

  Future<void> fetchLessons() async {
    final response =
        await supabase.from('LessonsTable').select('LessonID, Title');

    if (response.isNotEmpty) {
      setState(() {
        lessons.clear();
        lessonIdMap.clear(); // Reset the map

        // Populate the lessons list and the lessonIdMap
        for (var item in response as List<dynamic>) {
          if (item['Title'] != null && item['LessonID'] != null) {
            String title = item['Title'] as String;
            String lessonId =
                item['LessonID'].toString(); // Assuming LessonID is a string
            lessons.add(title);
            lessonIdMap[title] = lessonId; // Map the title to LessonID
          }
        }

        // Remove duplicates if any
        lessons = lessons.toSet().toList();

        // If lessonid is not empty, set selectedLesson immediately
        if (lessonid.isNotEmpty) {
          selectedLesson = lessonIdMap.keys.firstWhere(
            (key) => lessonIdMap[key] == lessonid,
            orElse: () => lessons.isNotEmpty
                ? lessons[0]
                : '', // Fallback to the first lesson if lessonid is invalid
          );
        } else {
          // Otherwise, automatically select the first lesson
          selectedLesson = lessons.isNotEmpty ? lessons[0] : null;
        }

        // Ensure the selectedLesson exists in the lessons list (in case lessonid was invalid)
        selectedLesson =
            selectedLesson ?? (lessons.isNotEmpty ? lessons[0] : '');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to fetch lessons: Technical Issues')),
      );
    }
  }

  Future<void> addingOrUpdateChallenge() async {
    String updatedQuestion =
        questionController.text; // Get the latest value from the controller
    String? updatedType = selectedType;
    String? updatedLessonId =
        lessonIdMap[selectedLesson]; // Get the LessonID using the map

    if (updatedLessonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid lesson.')),
      );
      return;
    }

    if (challengeid.isEmpty) {
      insertQuestion = updatedQuestion;
      final response = await supabase.from('ChallengesTable').insert({
        'LessonID': updatedLessonId,
        'Questions': updatedQuestion,
        'Type': updatedType,
      });

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challenge added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Challenge insertion failed: Something went wrong, please try again.')),
        );
      }
    } else {
      // Update existing challenge
      final response = await supabase.from('ChallengesTable').update({
        'LessonID': updatedLessonId,
        'Questions': updatedQuestion,
        'Type': updatedType,
      }).eq('ChallengeID', challengeid);

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challenge updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Challenge update failed: Something went wrong in the update process.')),
        );
      }
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(thequestion.isEmpty ? 'Add New Challenge' : 'Edit Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // TextField for the question input
            TextField(
              controller: questionController, // This should remain intact
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter question',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Dropdown for selecting type
            DropdownButton<String>(
              value: selectedType,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue; // Update only the selectedType
                  // Don't modify the questionController here
                });
              },
              items: types.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Select Lesson:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Dropdown for selecting lesson
            lessons.isEmpty
                ? const Center(
                    child: CircularProgressIndicator()) // Loading indicator
                : DropdownButton<String>(
                    value: selectedLesson,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLesson = newValue; // Update only selectedLesson
                        // Don't modify the questionController here either
                      });
                    },
                    items:
                        lessons.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await addingOrUpdateChallenge();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Save',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
