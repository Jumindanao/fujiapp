import 'package:flutter/material.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late TextEditingController titleController;
  late String courseId; // Declare courseId
  late String thetitle;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the course arguments from the settings
    final ReadCourse args =
        ModalRoute.of(context)!.settings.arguments as ReadCourse;

    // Initialize the controller with the title from args
    courseId = args.courseId; // Set courseId
    thetitle = args.title;
    titleController.text = thetitle; // Set the title directly
  }

  @override
  void dispose() {
    // Dispose controllers when done
    titleController.dispose();
    super.dispose();
  }

  void _saveCourse() async {
    String updatedTitle = titleController.text;

    // Check if we're adding a new course or editing an existing one
    if (courseId.isEmpty) {
      // Adding a new course
      await supabase.from('CourseTable').insert({
        'Title': updatedTitle,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New Course Added')),
      );
    } else {
      // Updating an existing course
      final getResponse = await supabase
          .from('CourseTable')
          .select('Title')
          .eq('CourseID', courseId)
          .single();

      /// DIRI NAG UPDATE SA COURSE
      if (getResponse.isNotEmpty) {
        // Update the course
        await supabase.from('CourseTable').update({
          'Title': updatedTitle,
        }).eq('CourseID', courseId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course details saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That Course does not Exist')),
        );
      }
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    print(courseId);
    print(thetitle);
    return Scaffold(
      appBar: AppBar(
        title: Text(courseId.isEmpty ? 'Add New Course' : 'Edit Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveCourse, // Call save method
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
