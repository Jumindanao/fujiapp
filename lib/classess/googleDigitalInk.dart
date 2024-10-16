// ignore_for_file: file_names

import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class DigitalInk {
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();
  var _language = 'en';
  final _languages = [
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'pt',
    'ru',
    'zh-Hani'
  ];
  DigitalInkRecognizer? _digitalInkRecognizer;
  final Ink _ink = Ink();
  List<StrokePoint> _points = [];
  String _recognizedText = '';
}
