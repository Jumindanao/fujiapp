import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fuji_app/pages/NavBar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String? _selectedCourse;
  String? n4title;
  String? n5title;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    // Fetch the courses from Supabase
    final response = await Supabase.instance.client
        .from('CourseTable') // Ensure your table name is correct
        .select('Title');

    if (response != null && response.length >= 2) {
      // Assuming there are at least two courses (n4 and n5)
      setState(() {
        n4title = response[0]['Title'];
        n5title = response[1]['Title'];
      });
    } else {
      print('Error fetching courses or not enough courses available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
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
            if (n4title != null && n5title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCourseCard(n5title!, _selectedCourse == n5title),
                  const SizedBox(width: 16),
                  _buildCourseCard(n4title!, _selectedCourse == n4title),
                ],
              ),
            ] else
              const Center(
                  child:
                      CircularProgressIndicator()), // Display a loader while fetching
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String courseName, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCourse = courseName;
        });
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Colors.green
                : Colors.black, // Set border color based on selection
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
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
                  color: isSelected
                      ? Colors.blue
                      : Colors.black, // Set text color based on selection
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
