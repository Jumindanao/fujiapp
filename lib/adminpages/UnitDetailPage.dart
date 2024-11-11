import 'package:flutter/material.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming ReadUnits is defined like this:

class UnitDetailPage extends StatefulWidget {
  const UnitDetailPage({super.key});

  @override
  State<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends State<UnitDetailPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String fromunitCourseID = "";
  String theunitID = "";
  final supabase = Supabase.instance.client;

  String? selectedCourseId; // Store the selected Course ID (not title)
  final List<Map<String, String>> courses = [];

  ReadUnits?
      selectedUnit; // Make it nullable to avoid the LateInitializationError

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    fetchCourses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is ReadUnits) {
      selectedUnit = arguments;

      // Initialize the controllers with the passed unit data
      titleController.text = selectedUnit!
          .title; // Force unwrapping since we ensure selectedUnit is not null here
      descriptionController.text = selectedUnit!.description;
      fromunitCourseID = selectedUnit!.fromunitCourseID;
      theunitID = selectedUnit!.unitid;
    }
  }

  /// Fetch courses and populate the dropdown
  Future<void> fetchCourses() async {
    final response =
        await supabase.from('CourseTable').select('Title, CourseID');

    if (response.isNotEmpty) {
      setState(() {
        // Clear previous courses before adding new ones
        courses.clear();

        // Add each course to the list using map
        courses.addAll(List<Map<String, String>>.from(response.map((course) => {
              'title': course['Title'] as String,
              'id': course['CourseID'] as String, // Store CourseID
            })));

        // If courses are fetched, set the course matching fromunitCourseID as the selected course
        selectedCourseId = courses.firstWhere(
          (course) => course['id'] == fromunitCourseID,
          orElse: () => {'id': '', 'title': 'Select a course'},
        )['id']; // Set selectedCourseId to the CourseID

        // If no match found, set the first course as the selected course
        if (selectedCourseId == null || selectedCourseId!.isEmpty) {
          selectedCourseId = courses[0]['id'];
        }
      });
    } else {
      print("Error or no courses available.");
    }
  }

  /// Update Unit in the database
  Future<void> updateUnit() async {
    String updatedTitle = titleController.text;
    String updatedDescription = descriptionController.text;
    String? updatedCourseId = selectedCourseId;

    if (theunitID.isEmpty) {
      await supabase.from('UnitsTable').insert({
        'CourseID': selectedCourseId,
        'Title': titleController.text,
        'Description': descriptionController.text,
      });
    } else {
      // Update the `UnitTable` record with the new values
      final response = await supabase
          .from('UnitsTable') // Update the `UnitTable`
          .update({
        'Title': updatedTitle,
        'Description': updatedDescription,
        'CourseID': updatedCourseId, // Updating the course ID
      }).eq('UnitID', theunitID); // Update based on UnitID

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit details updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unit details is not Updated!')),
        );
      }
    }
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If it's a new unit (selectedUnit is null), proceed without waiting for anything
    // Show the form for a new unit
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedUnit == null || selectedUnit!.title.isEmpty
              ? 'Add New Unit'
              : 'Edit Unit',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit Title Field
            const Text(
              'Unit Title:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Unit Title',
              ),
            ),
            const SizedBox(height: 16),

            // Unit Description Field
            const Text(
              'Unit Description:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Unit Description',
              ),
            ),
            const SizedBox(height: 16),

            // Course Selection Dropdown
            const Text(
              'Select Course:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedCourseId, // Use CourseID as value
              hint: const Text("Choose Course"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourseId = newValue; // Update the selected CourseID
                });
              },
              items: courses.isNotEmpty
                  ? courses.map<DropdownMenuItem<String>>((course) {
                      return DropdownMenuItem<String>(
                        value: course['id'], // Use course['id'] as value
                        child: Text(
                            course['title'] ?? ''), // Display course['title']
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

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  updateUnit(); // Call the update function when pressed
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.blue, // Button color
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
