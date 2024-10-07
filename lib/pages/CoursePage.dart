import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'NavBar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<String> courseTitles = [];
  String? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response =
        await Supabase.instance.client.from('CourseTable').select('Title');

    if (response != null && response.isNotEmpty) {
      setState(() {
        courseTitles = response
            .map<String>((course) => course['Title'].toString())
            .toList();
      });
    } else {
      print('Error fetching courses or no courses available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is String) {
      _selectedCourse = args;
    }

    return Scaffold(
      drawer: NavBar(userData: userData),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCourse ?? 'Select a course',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language courses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (courseTitles.isNotEmpty)
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: courseTitles.map((course) {
                    return _buildCourseCard(course, _selectedCourse == course);
                  }).toList(),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String courseName, bool isSelected) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/LearnPage',
          arguments: {
            'selectedCourse': courseName,
            'userData': userData, // Pass the Readdata object here
          },
        );

        setState(() {
          _selectedCourse = courseName;
        });
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/197/197604.png',
                width: 60,
                height: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                courseName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
