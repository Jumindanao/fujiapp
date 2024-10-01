import 'package:flutter/material.dart';

class LessonDetailPage extends StatefulWidget {
  final Map<String, String> lesson;

  const LessonDetailPage({super.key, required this.lesson});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  late TextEditingController titleController;
  late TextEditingController orderController;
  String? selectedUnit;

  // Sample data for units (could be fetched from a database)
  final List<Map<String, String>> units = [
    {'id': '1', 'title': 'Unit 1'},
    {'id': '2', 'title': 'Unit 2'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the lesson data
    titleController = TextEditingController(text: widget.lesson['title']);
    orderController = TextEditingController(text: widget.lesson['order']);
    selectedUnit = widget.lesson['unitId']; // Pre-select unit if editing
  }

  @override
  void dispose() {
    // Dispose controllers when done
    titleController.dispose();
    orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson['title']?.isEmpty ?? true
            ? 'Add New Lesson'
            : 'Edit Lesson'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson Title Field
            const Text(
              'Lesson Title:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Lesson Title',
              ),
            ),
            const SizedBox(height: 16),

            // Unit Selection Dropdown
            const Text(
              'Select Unit:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedUnit?.isNotEmpty == true ? selectedUnit : null,
              isExpanded: true,
              hint: const Text("Choose Unit"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue!;
                });
              },
              items: units.isNotEmpty
                  ? units.map<DropdownMenuItem<String>>(
                      (Map<String, String> unit) {
                      return DropdownMenuItem<String>(
                        value: unit['id'],
                        child: Text(unit['title'] ?? ''),
                      );
                    }).toList()
                  : [],
            ),
            const SizedBox(height: 16),

            // Lesson Order Field
            const Text(
              'Lesson Order:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Lesson Order',
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform save logic (e.g., API call or state update)
                  String updatedTitle = titleController.text;
                  String updatedOrder = orderController.text;
                  String? updatedUnit = selectedUnit;

                  // Validation or save logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson details saved!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: Colors.blue,
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
