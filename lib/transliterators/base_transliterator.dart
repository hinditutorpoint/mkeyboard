abstract class BaseTransliterator {
  String transliterate(String input);
  List<String> getSuggestions(String input, {int limit = 5});
  String get languageName;
  String get fontFamily;
}
