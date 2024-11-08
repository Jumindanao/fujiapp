import 'package:flutter/material.dart';
import 'package:fuji_app/classess/readdata.dart';
import 'package:fuji_app/pages/NavBar.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Speechtotextrecognition extends StatefulWidget {
  const Speechtotextrecognition({super.key});

  @override
  State<Speechtotextrecognition> createState() =>
      _SpeechtotextrecognitionState();
}

class _SpeechtotextrecognitionState extends State<Speechtotextrecognition> {
  final SpeechToText _speechToText = SpeechToText();
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.japanese,
    targetLanguage: TranslateLanguage.english,
  );

  String recognizedWords = "";
  String translatedWords = "";
  double confidenceLevel = 0;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'ja_JP',
    );
    setState(() {
      confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) async {
    setState(() {
      recognizedWords = result.recognizedWords;
      confidenceLevel = result.confidence;
    });

    try {
      final translation = await _translator.translateText(recognizedWords);
      setState(() {
        translatedWords = translation;
      });
    } catch (e) {
      setState(() {
        translatedWords = "Translation error: ${e.toString()}";
      });
    }
  }

  @override
  void dispose() {
    _translator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)?.settings.arguments as Readdata;
    return Scaffold(
      drawer: NavBar(userData: userData),
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          'Speech to Text',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (confidenceLevel > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: LinearProgressIndicator(
                      value: confidenceLevel,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recognized words (Japanese):",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            recognizedWords.isNotEmpty
                                ? recognizedWords
                                : "Say something in Japanese...",
                            style: const TextStyle(
                                fontSize: 22, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Translated words (English):",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          translatedWords.isNotEmpty
                              ? translatedWords
                              : "Translation will appear here...",
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, top: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _speechToText.isListening
                      ? _stopListening
                      : _startListening,
                  child: Icon(
                    Icons.mic,
                    size: 80,
                    color: _speechToText.isListening ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _speechToText.isListening
                      ? "Listening..."
                      : _speechEnabled
                          ? "Tap the microphone to start"
                          : "Speech recognition not available",
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
