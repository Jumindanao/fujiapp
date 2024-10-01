import 'package:flutter/material.dart';

class CourseDetailPage extends StatefulWidget {
  final Map<String, String> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late TextEditingController idController;
  late TextEditingController titleController;
  late TextEditingController imageSrcController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with course data (empty if adding a new course)
    idController = TextEditingController(text: widget.course['id']);
    titleController = TextEditingController(text: widget.course['title']);
    imageSrcController = TextEditingController(text: widget.course['imageSrc']);
  }

  @override
  void dispose() {
    // Dispose controllers when done
    idController.dispose();
    titleController.dispose();
    imageSrcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course['title']?.isEmpty ?? true
            ? 'Add New Course' // Title for Add Course
            : 'Edit Course'), // Title for Edit Course
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course ID Field
            const Text(
              'Course ID:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Course ID',
              ),
            ),
            const SizedBox(height: 16),

            // Course Title Field
            const Text(
              'Course Title:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Course Title',
              ),
            ),
            const SizedBox(height: 16),

            // Image Source Field
            const Text(
              'Image Source:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: imageSrcController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Image Source',
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform save logic (e.g., API call or state update)
                  String updatedId = idController.text;
                  String updatedTitle = titleController.text;
                  String updatedImageSrc = imageSrcController.text;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course details saved!')),
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
