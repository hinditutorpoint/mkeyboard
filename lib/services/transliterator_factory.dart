import '../transliterators/base_transliterator.dart';
import '../transliterators/hindi_transliterator.dart';
import '../transliterators/gondi_transliterator.dart';
import '../models/keyboard_language.dart';

class TransliteratorFactory {
  static BaseTransliterator? getTransliterator(KeyboardLanguage language) {
    switch (language) {
      case KeyboardLanguage.hindi:
        return HindiTransliterator();
      case KeyboardLanguage.gondi:
        return GondiTransliterator();
      case KeyboardLanguage.english:
        return null; // No transliteration needed
    }
  }
}
