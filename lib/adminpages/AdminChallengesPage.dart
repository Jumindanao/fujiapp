import 'package:flutter/material.dart';
import 'package:fuji_app/adminpages/AdminNav.dart';
import 'package:fuji_app/classess/AdminClass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({super.key});

  @override
  State<AdminChallengesPage> createState() => _AdminChallengesPageState();
}

class _AdminChallengesPageState extends State<AdminChallengesPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, String>> readChallenges = [];

  @override
  void initState() {
    super.initState();
    fetchingChallenges(); // Call the fetching function when the page is initialized
  }

  ///diri mag fetch ta gikan sa supabase para ma show
  Future<void> fetchingChallenges() async {
    try {
      // Fetch challenges from the ChallengesTable
      final challengeResponse = await supabase
          .from('ChallengesTable')
          .select('ChallengeID, LessonID, Type, Questions');

      // Check if response is not empty and then process it
      if (challengeResponse.isNotEmpty) {
        List<Map<String, String>> challenges = [];

        for (var challenge in challengeResponse) {
          // Get the LessonID for each challenge
          final lessonID = challenge['LessonID'].toString();

          // Fetch the Lesson title from the LessonsTable using LessonID
          final lessonResponse = await supabase
              .from('LessonsTable')
              .select('Title')
              .eq('LessonID', lessonID)
              .single(); // Assuming LessonID is unique and returns one result

          String lessonTitle = lessonResponse['Title'] ?? 'Unknown Lesson';

          // Map the challenge data along with the fetched lesson title
          challenges.add({
            'id': challenge['ChallengeID'].toString(),
            'lessonid': lessonID,
            'lesson': lessonTitle, // Use the fetched lesson title
            'type': challenge['Type'] ?? '',
            'question': challenge['Questions'] ?? '',
          });
        }

        // Update the list and trigger a UI rebuild
        if (mounted) {
          setState(() {
            readChallenges = challenges; // Store the fetched challenges
          });
        }
      } else {
        print('No challenges found.');
      }
    } catch (e) {
      print('Error fetching challenges: $e');
    }
  }

  ///

  // Navigate to add lesson page
  void _navigateToAddChallenge() {
    Navigator.pushNamed(
      context,
      '/ChallengeDetailPage',
      arguments: ReadChallenges(
          challengeid: '',
          lesson: '',
          lessonid: '',
          thetype: '',
          questions: ''),
    ).then((result) {
      if (result == true) {
        fetchingChallenges();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe6f0ff),
      drawer: const AdminNav(),
      appBar: AppBar(
        title: const Text("Challenge"),
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
              ],
            ),
          ),
          const Divider(),

          // List of lessons
          Expanded(
            child: ListView.builder(
              itemCount: readChallenges.length,
              itemBuilder: (context, index) {
                final challenge = readChallenges[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title Column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                challenge['question'] ?? 'No Questions',
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
                                challenge['type'] ?? 'No Types',
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
                                challenge['lesson'] ?? 'NO Lessons',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ReadChallenges readChallenge = ReadChallenges(
                          challengeid: challenge['id']!,
                          lessonid: challenge['lessonid']!,
                          lesson: challenge['lesson']!,
                          thetype: challenge['type']!,
                          questions: challenge['question']!,
                        );

                        Navigator.pushNamed(
                          context,
                          '/ChallengeDetailPage',
                          arguments: readChallenge,
                        ).then((result) {
                          if (result == true) {
                            fetchingChallenges();
                          }
                        });
                        ;
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
