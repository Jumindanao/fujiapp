import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminLessonPage.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage({super.key});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late TextEditingController titleController;
  late TextEditingController orderController;
  String lessonid = "";
  String lessontitle = "";
  String unitIDz = "";
  String? theSelectedUnitID;
  final supabase = Supabase.instance.client;
  final List<Map<String, String>> unitTitles = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    orderController = TextEditingController();
    fetchunitForLesson(); // Fetch available units
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is ReadLessons) {
      lessonid = arguments.lessonid;
      lessontitle = arguments.title;
      titleController.text = lessontitle;
      unitIDz = arguments.unitID;
    }
    titleController.text = lessontitle;
  }

  /// Fetch units from the database and populate the dropdown
  Future<void> fetchunitForLesson() async {
    final response = await supabase.from('UnitsTable').select('Title,UnitID');

    if (response.isNotEmpty) {
      setState(() {
        unitTitles.clear();
        // Correctly map unit titles and ids
        unitTitles.addAll(
          List<Map<String, String>>.from(response.map((unit) => {
                'title': unit['Title'] as String,
                'id': unit['UnitID'] as String,
              })),
        );
        theSelectedUnitID = unitTitles.firstWhere(
          (course) => course['id'] == unitIDz,
          orElse: () => {'id': '', 'title': 'Select a unit'},
        )['id'];
        if (theSelectedUnitID == null || theSelectedUnitID!.isEmpty) {
          theSelectedUnitID = unitTitles[0]['id'];
        }
      });
    } else {
      print("Error or no units available.");
    }
  }

  /// Save or update lesson in the database
  Future<void> saveLesson() async {
    String updatedTitle = titleController.text;

    if (lessonid.isEmpty) {
      final insertResponse = await supabase.from('LessonsTable').insert({
        'UnitID': theSelectedUnitID,
        'Title': updatedTitle,
      });

      if (insertResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New lesson added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add new lesson!')),
        );
      }
    } else {
      final updateResponse = await supabase.from('LessonsTable').update({
        'Title': updatedTitle,
        'UnitID': theSelectedUnitID,
      }).eq('LessonID', lessonid);

      if (updateResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson details updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update lesson details!')),
        );
      }
    }
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lessonid.isEmpty ? 'Add New Lesson' : 'Edit Lesson'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lesson Title:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Lesson Title',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Unit:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: theSelectedUnitID,
              isExpanded: true,
              hint: const Text("Choose Unit"),
              onChanged: (String? newValue) {
                setState(() {
                  theSelectedUnitID = newValue; // Update the selected unit ID
                });
              },
              items: unitTitles.isNotEmpty
                  ? unitTitles.map<DropdownMenuItem<String>>((unit) {
                      return DropdownMenuItem<String>(
                        value: unit['id'], // Use course['id'] as value
                        child: Text(
                            unit['title'] ?? ''), // Display course['title']
                      );
                    }).toList()
                  : [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No courses available'),
                      ),
                    ],
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: saveLesson,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
