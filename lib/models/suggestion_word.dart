import 'package:flutter/foundation.dart';

@immutable
class SuggestionWord {
  final String english;
  final String translated;
  final int frequency;
  final List<String> alternatives;

  const SuggestionWord({
    required this.english,
    required this.translated,
    required this.frequency,
    this.alternatives = const [],
  });

  factory SuggestionWord.fromJson(Map<String, dynamic> json) {
    return SuggestionWord(
      english: json['english'] as String,
      translated: json['translated'] as String,
      frequency: json['frequency'] as int? ?? 0,
      alternatives:
          (json['alternatives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'english': english,
      'translated': translated,
      'frequency': frequency,
      'alternatives': alternatives,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuggestionWord &&
        other.english == english &&
        other.translated == translated;
  }

  @override
  int get hashCode => english.hashCode ^ translated.hashCode;
}
