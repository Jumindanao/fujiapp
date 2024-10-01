import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart';
import 'package:fuji_app/adminpages/ChallengeDetailPage.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({super.key});

  @override
  State<AdminChallengesPage> createState() => _AdminChallengesPageState();
}

class _AdminChallengesPageState extends State<AdminChallengesPage> {
  final List<Map<String, String>> challenges = [
    {
      'id': '1',
      'question': 'Good morning sensei',
      'type': 'SELECT',
      'lesson': 'nouns', // Lesson for relationship
      'order': '1',
    },
    {
      'id': '2',
      'question': 'Translate "Water"',
      'type': 'ASSIST',
      'lesson': 'verbs', // Lesson for relationship
      'order': '2',
    },
  ];

  // Navigate to add lesson page
  void _navigateToAddChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChallengeDetailPage(
          challenge: {
            'id': '',
            'question': '',
            'type': '',
            'lesson': '',
            'order': '',
          }, // Empty lesson data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(),
      appBar: AppBar(
        title: const Text("Lessons"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Challenge',
            onPressed:
                _navigateToAddChallenge, // Navigate to add challenge page
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
                    flex: 2,
                    child: Text('ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Question',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Type',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Lesson',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Order',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(),

          // List of lessons
          Expanded(
            child: ListView.builder(
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ID Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                challenge['id'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Title Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                challenge['question'] ?? '',
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          // Unit Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                challenge['type'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Order Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                challenge['lesson'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                challenge['order'] ?? '',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChallengeDetailPage(challenge: challenge),
                          ),
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
