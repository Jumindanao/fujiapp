import 'package:flutter/material.dart';

class ChallengeOptionDetailPage extends StatefulWidget {
  final Map<String, dynamic>? option; // Existing option data if editing

  const ChallengeOptionDetailPage({super.key, this.option});

  @override
  State<ChallengeOptionDetailPage> createState() =>
      _ChallengeOptionDetailPageState();
}

class _ChallengeOptionDetailPageState extends State<ChallengeOptionDetailPage> {
  late TextEditingController textController;
  late TextEditingController imageController;
  late TextEditingController audioController;
  bool isCorrect = false;
  String? selectedChallenge;

  // List of available challenges (replace with real data)
  final List<Map<String, String>> challenges = [
    {
      'id': '1',
      'question': 'Good morning sensei',
    },
    {
      'id': '2',
      'question': 'Translate "Water"',
    },
  ];

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.option?['text'] ?? '');
    imageController =
        TextEditingController(text: widget.option?['image'] ?? '');
    audioController =
        TextEditingController(text: widget.option?['audio'] ?? '');
    isCorrect = widget.option?['correct'] ?? false;
    selectedChallenge = widget.option?['challenge'] ?? null;
  }

  @override
  void dispose() {
    textController.dispose();
    imageController.dispose();
    audioController.dispose();
    super.dispose();
  }

  void _saveOption() {
    // Perform save logic (API call or local storage)
    String optionText = textController.text;
    String imageSrc = imageController.text;
    String audioSrc = audioController.text;
    bool correct = isCorrect;
    String? challenge = selectedChallenge;

    // Save logic or API call goes here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Option saved!')),
    );
    Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.option?['text']?.isEmpty ?? true
            ? 'Add New Challenge'
            : 'Edit Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text field for the option
            const Text(
              'Option Text:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter option text',
              ),
            ),
            const SizedBox(height: 16),

            // Switch for correct option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Is Correct:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: isCorrect,
                  onChanged: (value) {
                    setState(() {
                      isCorrect = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown for challenge selection
            const Text(
              'Select Challenge:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedChallenge != ''
                  ? selectedChallenge
                  : null, // Handle empty string
              isExpanded: true,
              hint: const Text("Choose Type"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedChallenge = newValue!;
                });
              },
              items: challenges.map<DropdownMenuItem<String>>(
                  (Map<String, String> challenge) {
                return DropdownMenuItem<String>(
                  value: challenge['question'],
                  child: Text(challenge['question']!),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Text field for image source
            const Text(
              'Image Source:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter image source path',
              ),
            ),
            const SizedBox(height: 16),

            // Text field for audio source
            const Text(
              'Audio Source:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: audioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter audio source path',
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveOption,
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
