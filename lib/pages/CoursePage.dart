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
  String courseID = '';
  List<String> courseTitles = [];
  List<String> courseIDs = []; // List to store CourseIDs
  String? _selectedCourse;
  String userid = '';
  int userpoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response = await Supabase.instance.client
        .from('CourseTable')
        .select('CourseID, Title');

    if (response.isNotEmpty) {
      setState(() {
        // Store the course titles and their corresponding IDs
        courseTitles = response
            .map<String>((course) => course['Title'].toString())
            .toList();
        courseIDs = response
            .map<String>((course) => course['CourseID'].toString())
            .toList();
      });
    } else {
      print('Error fetching courses or no courses available');
    }
  }

  //fetching points
  Future<void> fetchThepoints() async {
    try {
      final responsedPoint = await Supabase.instance.client
          .from('profiles')
          .select('points')
          .eq('id', userid)
          .single();
      if (responsedPoint.isNotEmpty) {
        userpoints = responsedPoint['points'] as int;
        print(userpoints);
      } else {
        userpoints = 0;
        print('no points');
      }
    } catch (e) {}
  }
  //

  @override
  Widget build(BuildContext context) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;
    userid = userData.id;
    fetchThepoints();
    return Scaffold(
      drawer: NavBar(userData: userData),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SingleChildScrollView(
          // Wrap Row in SingleChildScrollView
          scrollDirection:
              Axis.horizontal, // Set scroll direction to horizontal
          child: Row(
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
              const SizedBox(width: 16), // Adjust space between elements
            ],
          ),
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
                  children: List.generate(courseTitles.length, (index) {
                    return _buildCourseCard(courseTitles[index],
                        _selectedCourse == courseTitles[index], index);
                  }),
                ),
              )
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "There is no course at the moment.",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String courseName, bool isSelected, int index) {
    final Readdata userData =
        ModalRoute.of(context)!.settings.arguments as Readdata;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCourse = courseName;
          courseID = courseIDs[index];
        });

        Navigator.pushNamed(
          context,
          '/LearnPage',
          arguments: {
            'selectedCourse': courseName,
            'userData': userData,
            'courseID': courseID,
          },
        );
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
