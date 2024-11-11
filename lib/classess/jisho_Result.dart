class JishoResult {
  final String japaneseWord;
  final String reading;
  final String englishMeaning;
  String? exampleSentence;

  JishoResult({
    required this.japaneseWord,
    required this.reading,
    required this.englishMeaning,
    this.exampleSentence,
  });

  factory JishoResult.fromJson(Map<String, dynamic> json) {
    final japanese = json['japanese'][0];
    return JishoResult(
      japaneseWord: japanese['word'] ?? '',
      reading: japanese['reading'] ?? '',
      englishMeaning: json['senses'][0]['english_definitions'].join(', '),
    );
  }
}