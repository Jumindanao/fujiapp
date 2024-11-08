import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:fuji_app/classess/jisho_Result.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:fuji_app/pages/NavBar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:async'; // Import for Timer

class JishoDictionary extends StatefulWidget {
  @override
  _JishoDictionaryState createState() => _JishoDictionaryState();
}

class _JishoDictionaryState extends State<JishoDictionary> {
  List<JishoResult> _results = [];
  bool _isLoading = false;
  TextEditingController _controller =
      TextEditingController(); // Controller for the TextField
  Timer? _debounce; // Timer for debouncing input

  Future<Map<String, dynamic>?> fetchJishoData(String query) async {
    final url = Uri.parse(
        'https://thingproxy.freeboard.io/fetch/https://jisho.org/api/v1/search/words?keyword=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<List<String>> fetchExampleSentences(String query) async {
    final sentenceUrl = Uri.parse(
        'https://thingproxy.freeboard.io/fetch/https://jisho.org/search/$query%20%23sentences');

    try {
      final response = await http.get(sentenceUrl);
      if (response.statusCode == 200) {
        final document = parse(response.body);
        print(document.outerHtml);

        final sentenceElements = document.querySelectorAll('.sentence_content');
        final sentences = sentenceElements.map((element) {
          return element.text.trim();
        }).toList();

        return sentences.isNotEmpty ? sentences : ['No examples available'];
      } else {
        print('Failed to load sentences: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sentences: $e');
    }

    return [];
  }

  void searchDictionary(String query) async {
    setState(() {
      _isLoading = true;
    });

    final data = await fetchJishoData(query);
    if (data != null && data['data'] != null) {
      _results = data['data']
          .map<JishoResult>((json) => JishoResult.fromJson(json))
          .toList();

      // Fetch example sentences concurrently
      final List<Future<void>> fetchTasks = _results.map((result) {
        return fetchExampleSentences(result.japaneseWord).then((sentences) {
          result.exampleSentence =
              sentences.isNotEmpty ? sentences.first : 'No example available';
        });
      }).toList();

      // Wait for all example sentences to be fetched
      await Future.wait(fetchTasks);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Example sentence copied to clipboard!'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)?.settings.arguments as Readdata;
    return Scaffold(
      drawer: NavBar(userData: userData),
      appBar: AppBar(
        title: const Text('Dictionary'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText:
                    'Search for a Japanese word, English, Romaji, words, or text...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear(); // Clear the text field
                    setState(() {
                      _results.clear(); // Clear results when input is cleared
                    });
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  searchDictionary(value); // Perform search on "Enter"
                }
              },
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.japaneseWord,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${result.reading} - ${result.englishMeaning}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Example sentence: ${result.exampleSentence?.isNotEmpty == true ? result.exampleSentence : 'No example available.'}',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      tooltip: 'Copy to clipboard',
                                      onPressed: () {
                                        _copyToClipboard(
                                            result.exampleSentence ??
                                                'No example available.');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel any pending timer
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }
}
