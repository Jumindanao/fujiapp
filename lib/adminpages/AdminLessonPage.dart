import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart';
import 'LessonDetailPage.dart'; // Import the LessonDetailPage

class AdminLessonPage extends StatefulWidget {
  const AdminLessonPage({super.key});

  @override
  State<AdminLessonPage> createState() => _AdminLessonPageState();
}

class _AdminLessonPageState extends State<AdminLessonPage> {
  // Sample data for lessons
  final List<Map<String, String>> lessons = [
    {
      'id': '1',
      'title': 'Nouns',
      'unitId': '1', // Unit ID for relationship
      'order': '1',
    },
    {
      'id': '2',
      'title': 'Verbs',
      'unitId': '2',
      'order': '2',
    },
  ];

  // Navigate to add lesson page
  void _navigateToAddLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LessonDetailPage(
          lesson: {
            'id': '',
            'title': '',
            'unitId': '',
            'order': '',
          }, // Empty lesson data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(),
      appBar: AppBar(
        title: const Text("Lessons"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Lesson',
            onPressed: _navigateToAddLesson, // Navigate to add lesson page
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Title',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Unit',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Order',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(),

          // List of lessons
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ID Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lesson['id'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Title Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lesson['title'] ?? '',
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          // Unit Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                lesson['unitId'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Order Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                lesson['order'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LessonDetailPage(lesson: lesson),
                          ),
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
