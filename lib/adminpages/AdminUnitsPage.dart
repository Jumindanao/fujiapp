import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart'; // Your own navigation drawer
import 'UnitDetailPage.dart'; // UnitDetailPage

class AdminUnitsPage extends StatefulWidget {
  const AdminUnitsPage({super.key});

  @override
  State<AdminUnitsPage> createState() => _AdminUnitsPageState();
}

class _AdminUnitsPageState extends State<AdminUnitsPage> {
  final List<Map<String, String>> units = [
    {
      'id': '1',
      'title': 'Introduction',
      'description': 'Basic introduction to N5',
      'courseId': '1'
    },
    {
      'id': '2',
      'title': 'Grammar 1',
      'description': 'Basic grammar for N5',
      'courseId': '1'
    },
  ];

  void _navigateToAddUnit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UnitDetailPage(
          unit: {
            'id': '',
            'title': '',
            'description': '',
            'courseId': ''
          }, // Empty unit data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(), // Your custom Admin Drawer
      appBar: AppBar(
        title: const Text("Units"),
        actions: [
          // Positioned Add Unit button to the right
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Unit',
            onPressed: _navigateToAddUnit, // Navigate to add unit page
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
                    flex: 1,
                    child: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Title',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Description',
                        style: TextStyle(fontWeight: FontWeight.bold))),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(flex: 1, child: Text(unit['id'] ?? '')),
                          Expanded(flex: 3, child: Text(unit['title'] ?? '')),
                          Expanded(
                              flex: 3, child: Text(unit['description'] ?? '')),
                        ],
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios), // Add arrow icon
                      onTap: () {
                        // Handle the unit click (navigate to unit details or perform some action)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            // Navigate to the Unit Detail Page
                            return UnitDetailPage(unit: unit);
                          }),
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
