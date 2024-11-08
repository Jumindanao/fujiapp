import 'package:flutter/material.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fuji_app/adminpages/AdminNav.dart';
import 'CourseDetailPage.dart';

class AdminCourse extends StatefulWidget {
  const AdminCourse({super.key});

  @override
  State<AdminCourse> createState() => _AdminCourseState();
}

class _AdminCourseState extends State<AdminCourse> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<ReadCourse> courses = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response =
        await supabase.from('CourseTable').select('CourseID,Title');

    if (response.isNotEmpty) {
      setState(() {
        courses = List<ReadCourse>.from(
          response.map((course) => ReadCourse(
                courseId: course['CourseID'],
                title: course['Title'],
              )),
        );
      });
    }
  }

  void _navigateToAddCourse() {
    Navigator.pushNamed(
      context,
      '/CourseDetailPage',
      arguments: ReadCourse(courseId: '', title: ''),
    ).then((result) {
      if (result == true) {
        _fetchCourses(); // Refresh the courses list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(),
      appBar: AppBar(
        title: const Text("Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Course',
            onPressed: _navigateToAddCourse,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Title',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
              ],
            ),
          ),
          const Divider(),
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
                          Expanded(
                            flex: 3,
                            child: Text(course.title.isNotEmpty
                                ? course.title
                                : 'No Title'),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/CourseDetailPage',
                          arguments: ReadCourse(
                            courseId: course.courseId,
                            title: course.title,
                          ),
                        ).then((result) {
                          if (result == true) {
                            _fetchCourses(); // Refresh the courses list
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
