import 'package:flutter/material.dart';
import 'package:fuji_app/classess/readdata.dart';

import 'package:fuji_app/pages/NavBar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

String? _selectedCourse;

class _CoursePageState extends State<CoursePage> {
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
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // Navigates back when tapped
              },
            ),
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
                    // If no course is selected, show 'Select a course'
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use null-safe check (_selectedCourse == courseName)
                _buildCourseCard(
                    'Japanese (N5)', _selectedCourse == 'Japanese (N5)'),
                const SizedBox(width: 16),
                _buildCourseCard(
                    'Japanese (N4)', _selectedCourse == 'Japanese (N4)'),
              ],
            ),
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
        setState(() {
          _selectedCourse = courseName; // Update the selected course on tap
          Navigator.of(context).pushReplacementNamed('/LearnPage',
              arguments: Readdata(
                  id: userData.id,
                  theusername: userData.theusername,
                  theemail: userData.theemail,
                  therole: userData.therole));
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
