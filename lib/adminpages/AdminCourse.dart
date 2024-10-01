import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart'; // Your own navigation drawer
import 'CourseDetailPage.dart'; // CourseDetailPage

class AdminCourse extends StatefulWidget {
  const AdminCourse({super.key});

  @override
  State<AdminCourse> createState() => _AdminCourseState();
}

class _AdminCourseState extends State<AdminCourse> {
  final List<Map<String, String>> courses = [
    {'id': '1', 'title': 'Japanese(N5)', 'imageSrc': '/jp.svg'},
    {'id': '2', 'title': 'Japanese(N4)', 'imageSrc': '/jp.svg'},
  ];

  void _navigateToAddCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseDetailPage(
          course: {'id': '', 'title': '', 'imageSrc': ''}, // Empty course data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(), // Your custom Admin Drawer
      appBar: AppBar(
        title: const Text("Courses"),
        actions: [
          // Positioned Add Course button to the right
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Course',
            onPressed: _navigateToAddCourse, // Navigate to add course page
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Row for Column Labels
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Title',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Image Src',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(),

          // List of Courses
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(flex: 1, child: Text(course['id'] ?? '')),
                          Expanded(flex: 3, child: Text(course['title'] ?? '')),
                          Expanded(
                              flex: 3, child: Text(course['imageSrc'] ?? '')),
                        ],
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios), // Add arrow icon
                      onTap: () {
                        // Handle the course click (navigate to course details or perform some action)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            // Example: navigate to a course detail page
                            return CourseDetailPage(course: course);
                          }),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
