import 'package:flutter/material.dart';
import 'package:fuji_app/classess/NavigatorFromCourse.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'NavBar.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  Widget build(BuildContext context) {
    final NavigationArguments args =
        ModalRoute.of(context)!.settings.arguments as NavigationArguments;

    // Access user data and selected course
    final Readdata userData = args.userData;
    final String courseName = args.courseName;

    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: NavBar(),
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  '/CoursePage',
                  arguments: userData,
                ); // Use userData directly
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text(
                      courseName, // Use the course name from arguments
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/197/197604.png', // Japan flag
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
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
          children: [
            _buildUnitSection(
              context,
              'Unit 1',
              'Introduce yourself',
              ['Hiragana 1', 'Basics', 'Animals', 'Foods', 'Places', 'Travel'],
              [
                Icons.language,
                Icons.egg,
                Icons.pets,
                Icons.restaurant,
                Icons.place,
                Icons.airplanemode_active
              ],
            ),
            const SizedBox(height: 16),
            _buildUnitSection(
              context,
              'Unit 2',
              'Nouns and verbs',
              [], // Add content here for unit 2 as per your requirement
              [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSection(
    BuildContext context,
    String unitTitle,
    String unitDescription,
    List<String> items,
    List<IconData> icons,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFF65a0b6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unitTitle,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    unitDescription,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward), // Placeholder for navigation
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Wrap widget to create the icon layout
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.center,
          children: List.generate(
            items.length,
            (index) => _buildCircularIcon(items[index], icons[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIcon(String label, IconData iconData) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, size: 40, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
