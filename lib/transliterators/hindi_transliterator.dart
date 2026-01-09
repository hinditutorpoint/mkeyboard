import 'base_transliterator.dart';
import '../services/hive_service.dart';

class HindiTransliterator implements BaseTransliterator {
  @override
  String get languageName => 'Hindi';

  @override
  String get fontFamily => 'NotoSansDevanagari';

  // Virama (halant)
  static const String _virama = '्';
  static const String _anusvara = 'ं';
  static const String _visarga = 'ः';
  static const String _nukta = '़';
  static const String _chandrabindu = 'ँ';

  // INDEPENDENT VOWELS
  static const Map<String, String> _vowels = {
    'a': 'अ',
    'aa': 'आ',
    'A': 'आ',
    'i': 'इ',
    'ii': 'ई',
    'I': 'ई',
    'ee': 'ई',
    'u': 'उ',
    'uu': 'ऊ',
    'U': 'ऊ',
    'oo': 'ऊ',
    'ri': 'ऋ',
    'R': 'ऋ',
    'e': 'ए',
    'ai': 'ऐ',
    'E': 'ऐ',
    'o': 'ओ',
    'au': 'औ',
    'O': 'औ',
  };

  // VOWEL MATRAS (dependent forms)
  static const Map<String, String> _matras = {
    'a': '',
    'aa': 'ा',
    'A': 'ा',
    'i': 'ि',
    'ii': 'ी',
    'I': 'ी',
    'ee': 'ी',
    'u': 'ु',
    'uu': 'ू',
    'U': 'ू',
    'oo': 'ू',
    'ri': 'ृ',
    'R': 'ृ',
    'e': 'े',
    'ai': 'ै',
    'E': 'ै',
    'o': 'ो',
    'au': 'ौ',
    'O': 'ौ',
  };

  // CONSONANTS
  static const Map<String, String> _consonants = {
    // Velars
    'ka': 'क', 'k': 'क', 'K': 'क',
    'kha': 'ख', 'kh': 'ख', 'Kh': 'ख',
    'ga': 'ग', 'g': 'ग', 'G': 'ग',
    'gha': 'घ', 'gh': 'घ', 'Gh': 'घ',
    'nga': 'ङ', 'ng': 'ङ',

    // Palatals
    'ca': 'च', 'cha': 'च', 'ch': 'च', 'c': 'च',
    'chha': 'छ', 'chh': 'छ', 'Ch': 'छ',
    'ja': 'ज', 'j': 'ज', 'J': 'ज',
    'jha': 'झ', 'jh': 'झ', 'Jh': 'झ',
    'nya': 'ञ', 'ny': 'ञ',

    // Retroflexes
    'Ta': 'ट', 'T': 'ट',
    'Tha': 'ठ', 'Th': 'ठ',
    'Da': 'ड', 'D': 'ड',
    'Dha': 'ढ', 'Dh': 'ढ',
    'Na': 'ण', 'N': 'ण',

    // Dentals
    'ta': 'त', 't': 'त',
    'tha': 'थ', 'th': 'थ',
    'da': 'द', 'd': 'द',
    'dha': 'ध', 'dh': 'ध',
    'na': 'न', 'n': 'न',

    // Labials
    'pa': 'प', 'p': 'प', 'P': 'प',
    'pha': 'फ', 'ph': 'फ', 'Ph': 'फ',
    'ba': 'ब', 'b': 'ब', 'B': 'ब',
    'bha': 'भ', 'bh': 'भ', 'Bh': 'भ',
    'ma': 'म', 'm': 'म', 'M': 'म',

    // Semivowels
    'ya': 'य', 'y': 'य', 'Y': 'य',
    'ra': 'र', 'r': 'र',
    'la': 'ल', 'l': 'ल', 'L': 'ल',
    'va': 'व', 'v': 'व', 'V': 'व', 'wa': 'व', 'w': 'व',

    // Sibilants
    'sha': 'श', 'sh': 'श',
    'ssa': 'ष', 'ss': 'ष',
    'sa': 'स', 's': 'स', 'S': 'स',
    'ha': 'ह', 'h': 'ह', 'H': 'ह',
  };

  // SPECIAL CONJUNCTS
  static const Map<String, String> _specialConjuncts = {
    'ksha': 'क्ष',
    'ksh': 'क्ष',
    'tra': 'त्र',
    'tr': 'त्र',
    'gya': 'ज्ञ',
    'gy': 'ज्ञ',
    'jna': 'ज्ञ',
    'jn': 'ज्ञ',
    'shra': 'श्र',
    'shr': 'श्र',
  };

  // NUKTA CONSONANTS (Urdu/Persian)
  static const Map<String, String> _nuktaConsonants = {
    'qa': 'क$_nukta',
    'q': 'क$_nukta',
    'khha': 'ख$_nukta',
    'x': 'ख$_nukta',
    'gha_': 'ग$_nukta',
    'za': 'ज$_nukta',
    'z': 'ज$_nukta',
    'rha': 'ड$_nukta',
    'rhha': 'ढ$_nukta',
    'fa': 'फ$_nukta',
    'f': 'फ$_nukta',
  };

  // NUMBERS
  static const Map<String, String> _numbers = {
    '0': '०',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
  };

  // Transliteration cache
  final Map<String, String> _cache = {};

  @override
  String transliterate(String input) {
    if (input.isEmpty) return '';

    // Check cache
    if (_cache.containsKey(input)) {
      return _cache[input]!;
    }

    final words = input.split(RegExp(r'\s+'));
    final result = words.map(_transliterateWord).join(' ');

    // Cache result
    _cache[input] = result;

    // Limit cache size
    if (_cache.length > 500) {
      _cache.clear();
    }

    return result;
  }

  String _transliterateWord(String word) {
    if (word.isEmpty) return '';

    final buffer = StringBuffer();
    int i = 0;
    bool lastWasConsonant = false;

    while (i < word.length) {
      // Try numbers
      if (_numbers.containsKey(word[i])) {
        if (lastWasConsonant) {
          buffer.write(_virama);
          lastWasConsonant = false;
        }
        buffer.write(_numbers[word[i]]!);
        i++;
        continue;
      }

      // Try nukta consonants
      bool matched = false;
      for (int len = 5; len >= 2; len--) {
        if (i + len <= word.length) {
          final substr = word.substring(i, i + len).toLowerCase();
          if (_nuktaConsonants.containsKey(substr)) {
            if (lastWasConsonant) buffer.write(_virama);
            buffer.write(_nuktaConsonants[substr]!);
            i += len;
            lastWasConsonant = true;
            matched = true;
            break;
          }
        }
      }
      if (matched) continue;

      // Try special conjuncts
      for (int len = 4; len >= 2; len--) {
        if (i + len <= word.length) {
          final substr = word.substring(i, i + len).toLowerCase();
          if (_specialConjuncts.containsKey(substr)) {
            if (lastWasConsonant) buffer.write(_virama);
            buffer.write(_specialConjuncts[substr]!);
            i += len;
            lastWasConsonant = true;
            matched = true;
            break;
          }
        }
      }
      if (matched) continue;

      // Try consonant + vowel
      final consonantMatch = _matchConsonant(word, i);
      if (consonantMatch.$1 != null) {
        if (lastWasConsonant) buffer.write(_virama);
        buffer.write(consonantMatch.$1!);
        i += consonantMatch.$2;

        // Try matra
        if (i < word.length) {
          final matraMatch = _matchMatra(word, i);
          if (matraMatch.$1 != null && matraMatch.$1!.isNotEmpty) {
            buffer.write(matraMatch.$1!);
            i += matraMatch.$2;
            lastWasConsonant = false;
          } else {
            lastWasConsonant = true;
          }
        } else {
          lastWasConsonant = true;
        }
        continue;
      }

      // Try standalone vowel
      final vowelMatch = _matchVowel(word, i);
      if (vowelMatch.$1 != null) {
        if (lastWasConsonant) buffer.write(_virama);
        buffer.write(vowelMatch.$1!);
        i += vowelMatch.$2;
        lastWasConsonant = false;
        continue;
      }

      // Handle anusvara (m/n before consonant)
      final char = word[i].toLowerCase();
      if ((char == 'm' || char == 'n') && i + 1 < word.length) {
        final next = word[i + 1].toLowerCase();
        if (_consonants.containsKey(next) ||
            _consonants.containsKey(
              '$next'
              'a',
            )) {
          buffer.write(_anusvara);
          i++;
          lastWasConsonant = false;
          continue;
        }
      }

      // Handle visarga (h at end)
      if (char == 'h' && (i + 1 >= word.length || word[i + 1] == ' ')) {
        buffer.write(_visarga);
        i++;
        lastWasConsonant = false;
        continue;
      }

      // Unmatched character
      if (lastWasConsonant && word[i] != ' ') {
        buffer.write(_virama);
        lastWasConsonant = false;
      }
      buffer.write(word[i]);
      i++;
    }

    return buffer.toString();
  }

  (String?, int) _matchConsonant(String word, int start) {
    for (int len = 4; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (_consonants.containsKey(substr)) {
          return (_consonants[substr], len);
        }
        if (_consonants.containsKey(substr.toLowerCase())) {
          return (_consonants[substr.toLowerCase()], len);
        }
      }
    }
    return (null, 0);
  }

  (String?, int) _matchMatra(String word, int start) {
    for (int len = 3; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (_matras.containsKey(substr)) {
          return (_matras[substr], len);
        }
        if (_matras.containsKey(substr.toLowerCase())) {
          return (_matras[substr.toLowerCase()], len);
        }
      }
    }
    return (null, 0);
  }

  (String?, int) _matchVowel(String word, int start) {
    for (int len = 3; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (_vowels.containsKey(substr)) {
          return (_vowels[substr], len);
        }
        if (_vowels.containsKey(substr.toLowerCase())) {
          return (_vowels[substr.toLowerCase()], len);
        }
      }
    }
    return (null, 0);
  }

  @override
  List<String> getSuggestions(String input, {int limit = 5}) {
    if (input.isEmpty) return [];

    final lastWord = input.split(RegExp(r'\s+')).last.toLowerCase();
    if (lastWord.isEmpty) return [];

    // Get from Hive
    final suggestions = HiveService.getSuggestions(
      lastWord,
      1, // Hindi languageIndex
      limit: limit,
    );

    return suggestions.map((s) => s.englishWord).toList();
  }
}
