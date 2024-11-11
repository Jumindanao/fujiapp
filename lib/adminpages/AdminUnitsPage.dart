import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart'; // Your own navigation drawer
import 'package:fuji_app/classess/AdminClass.dart';
import 'UnitDetailPage.dart'; // UnitDetailPage
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUnitsPage extends StatefulWidget {
  const AdminUnitsPage({super.key});

  @override
  State<AdminUnitsPage> createState() => _AdminUnitsPageState();
}

class _AdminUnitsPageState extends State<AdminUnitsPage> {
  final supabase = Supabase.instance.client;
  final List<Map<String, String>> units = [];

  /// Fetching units from the supabase
  Future<void> fetchUnits() async {
    final response = await supabase
        .from('UnitsTable')
        .select('UnitID, Title, Description, CourseID');

    if (response.isNotEmpty) {
      if (mounted) {
        setState(() {
          // Clear the previous units before adding new ones
          units.clear();
          // Add each unit to the list
          for (var unit in response) {
            units.add({
              'id': unit['UnitID'].toString(),
              'title': unit['Title'] ?? 'No Title', // Fallback if title is null
              'description': unit['Description'] ??
                  'No Description', // Fallback if description is null
              'courseId':
                  unit['CourseID'].toString(), // Save CourseID for each unit
            });
          }
        });
      }
      print("Units list: $units");
    } else {
      print("Error or no units available.");
    }
  }

  /// Fetch course title based on the CourseID from the Courses table
  Future<String?> fetchCourseTitle(String courseId) async {
    final response = await supabase
        .from('CourseTable')
        .select('Title')
        .eq('CourseID', courseId)
        .single(); // Fetch only one record for CourseID

    if (response['Title'] != null) {
      return response['Title']; // Return the course title
    } else {
      print("No course found for CourseID: $courseId");
      return 'No Course'; // Return a default string if no course is found
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUnits(); // Fetch units when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(), // Your custom Admin Drawer
      appBar: AppBar(
        title: const Text("Units"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Unit',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/UnitDetailPage',
              ).then((result) {
                if (result == true) {
                  fetchUnits(); // Refresh the courses list
                }
              });
            },
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
                  flex: 3,
                  child: Text(
                    'Unit Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Course Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // List of Units
          Expanded(
            child: ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];

                return FutureBuilder<String?>(
                  future:
                      fetchCourseTitle(unit['courseId']!), // Fetch course title
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    String courseTitle = snapshot.data ??
                        'No Course'; // Use the fetched course title

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ListTile(
                          title: Row(
                            children: [
                              // Display course title
                              Expanded(
                                  flex: 3, child: Text(unit['title'] ?? '')),
                              Expanded(
                                  flex: 3,
                                  child: Text(unit['description'] ?? '')),
                              Expanded(flex: 3, child: Text(courseTitle)),
                            ],
                          ),
                          trailing: const Icon(
                              Icons.arrow_forward_ios), // Add arrow icon
                          onTap: () {
                            ReadUnits selectedUnit = ReadUnits(
                              unitid: unit['id'] ?? '',
                              title: unit['title'] ?? '',
                              description: unit['description'] ?? '',
                              fromunitCourseID: unit['courseId'] ?? '',
                            );

                            Navigator.pushNamed(
                              context,
                              '/UnitDetailPage',
                              arguments: selectedUnit,
                            ).then((result) {
                              if (result == true) {
                                fetchUnits(); // Refresh the courses list
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
