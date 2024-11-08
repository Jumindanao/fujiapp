import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'LessonDetailPage.dart'; // Import the LessonDetailPage
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLessonPage extends StatefulWidget {
  const AdminLessonPage({super.key});

  @override
  State<AdminLessonPage> createState() => _AdminLessonPageState();
}

class _AdminLessonPageState extends State<AdminLessonPage> {
  final supabase = Supabase.instance.client;

  final List<Map<String, String>> lessons = [];
  @override
  void initState() {
    super.initState();
    fetchLessons(); // Call fetchLessons() to load lessons
  }

  //Diri mag sugod ug select for viewing Lessontable
  Future<void> fetchLessons() async {
    final lessonresponse =
        await supabase.from('LessonsTable').select('LessonID,Title,UnitID');
    if (lessonresponse.isNotEmpty) {
      if (mounted) {
        setState(() {
          lessons.clear();
          for (var lesson in lessonresponse) {
            lessons.add({
              'id': lesson['LessonID'].toString(),
              'title': lesson['Title'],
              'theunitID': lesson['UnitID'],
            });
          }
        });
      }
    }
  }

  //

  void _navigateToAddLesson() {
    Navigator.pushNamed(context, '/LessonDetailPage',
        arguments: ReadLessons(
          lessonid: '',
          title: '',
          unitID: '',
        )).then((result) {
      if (result == true) {
        fetchLessons();
      }
    });
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
              onPressed: _navigateToAddLesson),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Title',
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
                          // Title Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                lesson['title'] ?? 'No Lesson',
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          // Unit Column
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Access the lesson map at the current index
                        final lesson = lessons[index];
                        ReadLessons selectedLessons = ReadLessons(
                          lessonid: lesson['id'] ?? '',
                          title: lesson['title'] ?? '',
                          unitID: lesson['theunitID'] ?? '',
                        );

                        Navigator.pushNamed(
                          context,
                          '/LessonDetailPage',
                          arguments: selectedLessons,
                        ).then((result) {
                          if (result == true) {
                            fetchLessons();
                          }
                        });
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
