import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart';
import 'package:fuji_app/adminpages/ChallengeOptionDetailPage.dart';

class AdminChallengeOptionPage extends StatefulWidget {
  const AdminChallengeOptionPage({super.key});

  @override
  State<AdminChallengeOptionPage> createState() =>
      _AdminChallengeOptionPageState();
}

class _AdminChallengeOptionPageState extends State<AdminChallengeOptionPage> {
  // List of challenge options to be displayed in the table
  final List<Map<String, dynamic>> challengeOptions = [
    {
      'id': '1',
      'text': 'Good morning',
      'correct': true,
      'challenge': 'Good morning sensei',
      'image': 'assets/images/morning.png',
      'audio': 'assets/audio/morning.mp3',
    },
    {
      'id': '2',
      'text': 'Water',
      'correct': false,
      'challenge': 'Translate "Water"',
      'image': 'assets/images/water.png',
      'audio': 'assets/audio/water.mp3',
    },
  ];

  // Navigate to add or edit option
  void _navigateToOptionDetail(Map<String, dynamic> option) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeOptionDetailPage(option: option),
      ),
    );
  }

  // Navigate to add a new option with empty fields
  void _navigateToAddOption() {
    _navigateToOptionDetail({
      'id': '',
      'text': '',
      'correct': false,
      'challenge': '',
      'image': '',
      'audio': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(),
      appBar: AppBar(
        title: const Text("Challenge Options"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Option',
            onPressed: _navigateToAddOption, // Navigate to add option page
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Text',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Correct',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Challenge',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Image Src',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Audio Src',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(),

          // List of challenge options
          Expanded(
            child: ListView.builder(
              itemCount: challengeOptions.length,
              itemBuilder: (context, index) {
                final option = challengeOptions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ID Column
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option['id'].toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Text Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option['text'] ?? '',
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          // Correct or Incorrect Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: Icon(
                                option['correct']
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                color: option['correct']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                          // Challenge Question Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option['challenge'] ?? '',
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          // Image Source Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option['image'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Audio Source Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                option['audio'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _navigateToOptionDetail(option);
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
