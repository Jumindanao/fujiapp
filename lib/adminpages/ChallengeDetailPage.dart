import 'package:flutter/material.dart';

class ChallengeDetailPage extends StatefulWidget {
  final Map<String, String> challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  late TextEditingController questionController;
  late TextEditingController orderController;
  String? selectedType;
  String? selectedLesson;

  // List of challenges that populate dropdowns
  final List<Map<String, String>> challenges = [
    {
      'id': '1',
      'question': 'Translate Good Morning sensei',
      'type': 'SELECT',
      'lesson': 'nouns',
      'order': '1',
    },
    {
      'id': '2',
      'question': 'Translate Water',
      'type': 'ASSIST',
      'lesson': 'verbs',
      'order': '2',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the challenge data
    questionController =
        TextEditingController(text: widget.challenge['question']);
    orderController = TextEditingController(text: widget.challenge['order']);
    selectedType = widget.challenge['type'];
    selectedLesson = widget.challenge['lesson'];
  }

  @override
  void dispose() {
    // Dispose controllers when done
    questionController.dispose();
    orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get distinct values for "type" and "lesson" from the challenges list
    List<String> types = challenges
        .map((challenge) => challenge['type'] ?? '')
        .toSet()
        .toList(); // Extract unique types
    List<String> lessons = challenges
        .map((challenge) => challenge['lesson'] ?? '')
        .toSet()
        .toList(); // Extract unique lessons

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge['question']?.isEmpty ?? true
            ? 'Add New Challenge'
            : 'Edit Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Field
            const Text(
              'Question:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter question',
              ),
            ),
            const SizedBox(height: 16),

            // Type Selection Dropdown
            const Text(
              'Select Type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedType != ''
                  ? selectedType
                  : null, // Handle empty string
              isExpanded: true,
              hint: const Text("Choose Type"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              items: types.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Lesson Selection Dropdown
            const Text(
              'Select Lesson:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedLesson != ''
                  ? selectedLesson
                  : null, // Handle empty string
              isExpanded: true,
              hint: const Text("Choose Lesson"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLesson = newValue!;
                });
              },
              items: lessons.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Lesson Order Field
            const Text(
              'Challenge Order:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Challenge Order',
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform save logic (e.g., API call or state update)
                  String updatedQuestion = questionController.text;
                  String updatedOrder = orderController.text;
                  String? updatedType = selectedType;
                  String? updatedLesson = selectedLesson;

                  // Save logic or API call goes here

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge details saved!')),
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
