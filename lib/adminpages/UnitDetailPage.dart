import 'package:flutter/material.dart';

class UnitDetailPage extends StatefulWidget {
  final Map<String, String> unit;

  const UnitDetailPage({super.key, required this.unit});

  @override
  State<UnitDetailPage> createState() => _UnitDetailPageState();
}

class _UnitDetailPageState extends State<UnitDetailPage> {
  late TextEditingController idController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String? selectedCourse; // For storing selected course

  final List<Map<String, String>> courses = [
    {'id': '1', 'title': 'Japanese(N5)'},
    {'id': '2', 'title': 'Japanese(N4)'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with unit data (empty if adding a new unit)
    idController = TextEditingController(text: widget.unit['id']);
    titleController = TextEditingController(text: widget.unit['title']);
    descriptionController =
        TextEditingController(text: widget.unit['description']);
    selectedCourse = widget.unit['courseId']; // Pre-select course if editing
  }

  @override
  void dispose() {
    // Dispose controllers when done
    idController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit['title']?.isEmpty ?? true
            ? 'Add New Unit' // Title for Add Unit
            : 'Edit Unit'), // Title for Edit Unit
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit ID Field
            const Text(
              'Unit ID:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Unit ID',
              ),
            ),
            const SizedBox(height: 16),

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
              value: selectedCourse!.isNotEmpty ? selectedCourse : null,
              isExpanded: true,
              hint: const Text("Choose Course"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourse = newValue!;
                });
              },
              items: courses.isNotEmpty
                  ? courses.map<DropdownMenuItem<String>>(
                      (Map<String, String> course) {
                      return DropdownMenuItem<String>(
                        value: course['id'],
                        child: Text(course['title'] ?? ''),
                      );
                    }).toList()
                  : [], // In case the list is empty
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform save logic (e.g., API call or state update)
                  String updatedId = idController.text;
                  String updatedTitle = titleController.text;
                  String updatedDescription = descriptionController.text;
                  String? updatedCourseId = selectedCourse;

                  // Validation or save logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unit details saved!')),
                  );
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
