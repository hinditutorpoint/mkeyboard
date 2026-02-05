import 'base_transliterator.dart';
import '../services/hive_service.dart';

/// Masaram Gondi Transliterator - Matches Keyman ITRANS keyboard
/// Based on masaram_gondi.kmn by Rajesh Kumar Dhuriya
class GondiTransliterator implements BaseTransliterator {
  @override
  String get languageName => 'Gondi';

  @override
  String get fontFamily => 'NotoSansMasaramGondi';

  // ═══════════════════════════════════════════════════════════════════════════
  // COMBINING MARKS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String halanta = '𑵄'; // U+11D44 - Final consonant marker
  static const String virama = '𑵅'; // U+11D45 - Conjunct marker (C+C)
  static const String anusvara = '𑵀'; // U+11D40 - Nasalization (M)
  static const String visarga = '𑵁'; // U+11D41 - Aspiration (H)
  static const String sukun = '𑵂'; // U+11D42 - Nukta variant
  static const String chandrabindu = '𑵃'; // U+11D43 - Chandrabindu (MM)
  static const String repha = '𑵆'; // U+11D46 - R before consonant
  static const String rakar = '𑵇'; // U+11D47 - R after consonant

  // ═══════════════════════════════════════════════════════════════════════════
  // INDEPENDENT VOWELS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> independentVowels = {
    'a': '𑴀',
    'aa': '𑴁',
    'A': '𑴁',
    'ā': '𑴁',
    'i': '𑴂',
    'ii': '𑴃',
    'I': '𑴃',
    'ī': '𑴃',
    'ee': '𑴃',
    'u': '𑴄',
    'uu': '𑴅',
    'U': '𑴅',
    'ū': '𑴅',
    'oo': '𑴅',
    'RRi': '𑴇',
    'R^i': '𑴇',
    'Ri': '𑴇',
    '.r': '𑴇',
    'ṛ': '𑴇',
    'RRI': '𑴇',
    'R^I': '𑴇',
    'e': '𑴆',
    'E': '𑴆',
    'ē': '𑴆',
    'ai': '𑴈',
    'aI': '𑴈',
    'ei': '𑴈',
    'o': '𑴉',
    'O': '𑴉',
    'ō': '𑴉',
    'au': '𑴋',
    'aU': '𑴋',
    'ou': '𑴋',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // VOWEL SIGNS (Matras)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> vowelSigns = {
    'aa': '𑴱', 'A': '𑴱', 'ā': '𑴱',
    'i': '𑴲',
    'ii': '𑴳', 'I': '𑴳', 'ī': '𑴳', 'ee': '𑴳',
    'u': '𑴴',
    'uu': '𑴵', 'U': '𑴵', 'ū': '𑴵', 'oo': '𑴵',
    'e': '𑴺', 'ē': '𑴺',
    'ai': '𑴼', 'aI': '𑴼', 'ei': '𑴼',
    'o': '𑴽', 'ō': '𑴽',
    'au': '𑴿', 'aU': '𑴿', 'ou': '𑴿',
    'R': '𑴶', 'ṛ': '𑴶', // Vocalic R
    'RRi': '𑴶', 'R^i': '𑴶', 'Ri': '𑴶',
    'RRI': '𑴶', 'R^I': '𑴶', '.r': '𑴶',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSONANTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> consonants = {
    // Velars
    'k': '𑴌', 'K': '𑴍', 'kh': '𑴍',
    'g': '𑴎', 'G': '𑴏', 'gh': '𑴏',
    'F': '𑴐', 'ng': '𑴐', 'ṅ': '𑴐', '~N': '𑴐', 'N^': '𑴐',

    // Palatals
    'c': '𑴑', 'ch': '𑴑',
    'C': '𑴒', 'chh': '𑴒', 'Ch': '𑴒',
    'j': '𑴓', 'J': '𑴔', 'jh': '𑴔',
    'Y': '𑴕', 'ny': '𑴕', 'ñ': '𑴕', 'JN': '𑴕', '~n': '𑴕',

    // Retroflexes
    'T': '𑴖', 'ṭ': '𑴖',
    'Th': '𑴗', 'ṭh': '𑴗',
    'D': '𑴘', 'ḍ': '𑴘',
    'Dh': '𑴙', 'ḍh': '𑴙',
    'N': '𑴚', 'ṇ': '𑴚',

    // Dentals
    't': '𑴛', 'th': '𑴜',
    'd': '𑴝', 'dh': '𑴞',
    'n': '𑴟',

    // Labials
    'p': '𑴠', 'P': '𑴡', 'ph': '𑴡',
    'b': '𑴢', 'B': '𑴣', 'bh': '𑴣',
    'm': '𑴤',

    // Semivowels
    'y': '𑴥',
    'r': '𑴦',
    'l': '𑴧', 'L': '𑴭', 'ḷ': '𑴭',
    'v': '𑴨', 'w': '𑴨', 'W': '𑴨',

    // Sibilants
    'sh': '𑴩', 'ś': '𑴩',
    'S': '𑴪', 'ss': '𑴪', 'ṣ': '𑴪', 'Sh': '𑴪', 'shh': '𑴪',
    's': '𑴫',
    'h': '𑴬',

    // Special ligatures
    'x': '𑴮', // ksha
    'X': '𑴯', // gya
    'GY': '𑴯', 'dny': '𑴯', 'jny': '𑴯',
    'Z': '𑴰', // tra
  };

  // Nukta consonants
  static const Map<String, String> nuktaConsonants = {
    'q': '𑴌$sukun',
    'z': '𑴓$sukun',
    'f': '𑴡$sukun',
    '.D': '𑴘$sukun',
    '.Dh': '𑴙$sukun',
  };

  // Numbers
  static const Map<String, String> numbers = {
    '0': '𑵐',
    '1': '𑵑',
    '2': '𑵒',
    '3': '𑵓',
    '4': '𑵔',
    '5': '𑵕',
    '6': '𑵖',
    '7': '𑵗',
    '8': '𑵘',
    '9': '𑵙',
  };

  // Vowel characters for detection
  static const String vowelChars = 'aāiīuūeēoōAIUEO';

  final Map<String, String> _cache = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  bool _isVowel(String c) {
    return vowelChars.contains(c);
  }

  bool _isConsonantStart(String word, int pos) {
    if (pos >= word.length) return false;

    // Try matching consonant at position
    for (int len = 3; len >= 1; len--) {
      if (pos + len <= word.length) {
        final substr = word.substring(pos, pos + len);
        if (consonants.containsKey(substr) ||
            nuktaConsonants.containsKey(substr)) {
          return true;
        }
      }
    }
    return false;
  }

  // Check if 'r' at position is for rakar (C + r + V)
  bool _isRakar(String word, int pos) {
    if (pos >= word.length) return false;
    if (word[pos] != 'r') return false;

    // Must have vowel after 'r'
    int nextPos = pos + 1;
    if (nextPos < word.length) {
      final next = word[nextPos];
      // Check for vowel or 'a' (inherent vowel indicator)
      if (_isVowel(next) || next == 'a') {
        return true;
      }
    }
    return false;
  }

  // Check if 'r' at position is for repha (V + r + C)
  bool _isRepha(String word, int pos) {
    if (pos >= word.length) return false;
    if (word[pos] != 'r') return false;

    // Must have consonant after 'r'
    int nextPos = pos + 1;
    if (nextPos < word.length) {
      return _isConsonantStart(word, nextPos);
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN TRANSLITERATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String transliterate(String input) {
    if (input.isEmpty) return '';

    if (_cache.containsKey(input)) {
      return _cache[input]!;
    }

    // Split by whitespace but preserve spaces
    final result = StringBuffer();
    final parts = input.split(RegExp(r'(\s+)'));

    for (final part in parts) {
      if (part.trim().isEmpty) {
        result.write(part);
      } else {
        result.write(_transliterateWord(part));
      }
    }

    final output = result.toString();
    _cache[input] = output;

    if (_cache.length > 500) {
      _cache.clear();
    }

    return output;
  }

  String _transliterateWord(String word) {
    if (word.isEmpty) return '';

    final buffer = StringBuffer();
    int i = 0;

    // Track state
    bool hasConsonant = false; // Have unconsumed consonant
    bool hasVowel = false; // Current syllable has vowel

    while (i < word.length) {
      final char = word[i];
      final remaining = word.substring(i);

      // ─────────────────────────────────────────────────────────────────────
      // NUMBERS
      // ─────────────────────────────────────────────────────────────────────
      if (numbers.containsKey(char)) {
        if (hasConsonant && !hasVowel) {
          buffer.write(halanta);
        }
        buffer.write(numbers[char]!);
        hasConsonant = false;
        hasVowel = false;
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // PUNCTUATION
      // ─────────────────────────────────────────────────────────────────────
      if (char == '.') {
        // Special check: if '.' starts a special sequence, skip punctuation handling
        if (remaining.startsWith('.r') ||
            remaining.startsWith('.D') ||
            remaining.startsWith('.n') ||
            remaining.startsWith('.m') ||
            remaining.startsWith('.h') ||
            remaining.startsWith('.N')) {
          // Fall through to regular matching
        } else {
          if (hasConsonant && !hasVowel) {
            buffer.write(halanta);
          }

          // Count dots
          int dotCount = 1;
          while (i + dotCount < word.length && word[i + dotCount] == '.') {
            dotCount++;
          }

          if (dotCount >= 3) {
            buffer.write('॥');
            i += 3;
          } else if (dotCount >= 2) {
            buffer.write('।');
            i += 2;
          } else {
            buffer.write('।');
            i++;
          }

          hasConsonant = false;
          hasVowel = false;
          continue;
        }
      }

      // ─────────────────────────────────────────────────────────────────────
      // WHITESPACE (Pass through)
      // ─────────────────────────────────────────────────────────────────────
      if (char == ' ' || char == '\n' || char == '\t') {
        if (hasConsonant && !hasVowel) {
          buffer.write(halanta);
        }
        buffer.write(char);
        hasConsonant = false;
        hasVowel = false;
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // CHANDRABINDU (MM or .N)
      // ─────────────────────────────────────────────────────────────────────
      if (remaining.startsWith('.N') || (remaining.startsWith('MM'))) {
        buffer.write(chandrabindu);
        i += 2;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // ANUSVARA (M after vowel, or ṃ, or .n, .m)
      // ─────────────────────────────────────────────────────────────────────
      if (remaining.startsWith('.n') || remaining.startsWith('.m')) {
        buffer.write(anusvara);
        i += 2;
        continue;
      }

      if ((char == 'M' && hasVowel) || char == 'ṃ' || char == 'ṁ') {
        buffer.write(anusvara);
        hasConsonant = false;
        hasVowel = false;
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // VISARGA (H after vowel, or ḥ, or .h)
      // ─────────────────────────────────────────────────────────────────────
      if (remaining.startsWith('.h')) {
        buffer.write(visarga);
        i += 2;
        continue;
      }

      if ((char == 'H' && hasVowel) || char == 'ḥ') {
        buffer.write(visarga);
        hasConsonant = false;
        hasVowel = false;
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // REPHA: 'r' after vowel, before consonant (V + r + C)
      // Example: mArkA → maa + repha + kaa
      // ─────────────────────────────────────────────────────────────────────
      if (char == 'r' && hasVowel && _isRepha(word, i)) {
        buffer.write(repha);
        hasConsonant = false;
        hasVowel = false;
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // RAKAR: 'r' after consonant, before vowel (C + r + V)
      // Example: kro → ka + rakar + o
      // ─────────────────────────────────────────────────────────────────────
      if (char == 'r' && hasConsonant && !hasVowel) {
        int nextPos = i + 1;

        // Check what comes after 'r'
        if (nextPos < word.length) {
          final next = word[nextPos];

          // r + a = rakar with inherent vowel
          if (next == 'a') {
            // Check if it's just 'a' (inherent) or 'aa', 'ai', 'au'
            int afterA = nextPos + 1;
            if (afterA < word.length) {
              final afterAChar = word[afterA];
              if (afterAChar == 'a' || afterAChar == 'A') {
                // 'raa' = rakar + aa sign
                buffer.write(rakar);
                buffer.write('𑴱');
                i = afterA + 1;
                hasVowel = true;
                continue;
              } else if (afterAChar == 'i' || afterAChar == 'I') {
                // 'rai' = rakar + ai sign
                buffer.write(rakar);
                buffer.write('𑴼');
                i = afterA + 1;
                hasVowel = true;
                continue;
              } else if (afterAChar == 'u' || afterAChar == 'U') {
                // 'rau' = rakar + au sign
                buffer.write(rakar);
                buffer.write('𑴿');
                i = afterA + 1;
                hasVowel = true;
                continue;
              }
            }
            // Just 'ra' = rakar with inherent a
            buffer.write(rakar);
            i = nextPos + 1;
            hasVowel = true;
            continue;
          }

          // r + other vowel = rakar + vowel sign
          final vowelMatch = _matchVowelSign(word, nextPos);
          if (vowelMatch.$1 != null) {
            buffer.write(rakar);
            buffer.write(vowelMatch.$1!);
            i = nextPos + vowelMatch.$2;
            hasVowel = true;
            continue;
          }

          // r + consonant = conjunct (not rakar)
          if (_isConsonantStart(word, nextPos)) {
            // This is r as part of conjunct, use virama
            buffer.write(virama);
            buffer.write('𑴦'); // ra
            hasConsonant = true;
            hasVowel = false;
            i++;
            continue;
          }
        }

        // 'r' at end = rakar with inherent a (or halanta?)
        // According to Keyman: 𑴌𑵆 at end... but that's repha position
        // Let's use rakar for Cr at end
        buffer.write(rakar);
        hasVowel = true;
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // CONSONANTS
      // ─────────────────────────────────────────────────────────────────────
      final consonantMatch = _matchConsonant(word, i);
      if (consonantMatch.$1 != null) {
        // If previous consonant has no vowel, add virama for conjunct
        if (hasConsonant && !hasVowel) {
          buffer.write(virama);
        }

        buffer.write(consonantMatch.$1!);
        i += consonantMatch.$2;
        hasConsonant = true;
        hasVowel = false;

        // Check for following vowel
        if (i < word.length) {
          // Handle 'a' specially
          // NOTE: I am keeping the 'a' logic roughly same, but JS has a slight difference in how it iterates.
          // JS says:
          // if (word[i] === 'a') { ... }
          // Here i is already incremented in JS.
          // In my code here, i is updated at end of block.
          // Let's check my logic:
          // i += consonantMatch.$2;
          // if (i < word.length) { if (word[i] == 'a') ... }
          // This handles the 'a' AFTER the consonant. This is correct.

          if (word[i] == 'a') {
            int nextPos = i + 1;
            // Check for 'aa', 'ai', 'au'
            if (nextPos < word.length) {
              final next = word[nextPos];
              if (next == 'a' || next == 'A') {
                buffer.write('𑴱'); // aa
                i = nextPos + 1;
                hasVowel = true;
                continue;
              } else if (next == 'i' || next == 'I') {
                buffer.write('𑴼'); // ai
                i = nextPos + 1;
                hasVowel = true;
                continue;
              } else if (next == 'u' || next == 'U') {
                buffer.write('𑴿'); // au
                i = nextPos + 1;
                hasVowel = true;
                continue;
              } else if (next == 'e') {
                buffer.write('𑵃'); // ae (chandrabindu?)
                i = nextPos + 1;
                hasVowel = true;
                continue;
              }
            }
            // Just 'a' = inherent vowel, no matra needed
            i++;
            hasVowel = true;
            continue;
          }

          // Try matching other vowel signs
          final vowelMatch = _matchVowelSign(word, i);
          if (vowelMatch.$1 != null) {
            buffer.write(vowelMatch.$1!);
            i += vowelMatch.$2;
            hasVowel = true;
            continue;
          }
        }
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // INDEPENDENT VOWELS (at word start or after another vowel)
      // ─────────────────────────────────────────────────────────────────────
      if (!hasConsonant || hasVowel) {
        final vowelMatch = _matchIndependentVowel(word, i);
        if (vowelMatch.$1 != null) {
          if (hasConsonant && !hasVowel) {
            buffer.write(halanta);
          }
          buffer.write(vowelMatch.$1!);
          i += vowelMatch.$2;
          hasConsonant = false;
          hasVowel = true;
          continue;
        }
      }

      // ─────────────────────────────────────────────────────────────────────
      // SKIP SPECIAL CHARS
      // ─────────────────────────────────────────────────────────────────────
      if (char == '^' || char == '~') {
        i++;
        continue;
      }

      // ─────────────────────────────────────────────────────────────────────
      // UNMATCHED - pass through
      // ─────────────────────────────────────────────────────────────────────
      if (hasConsonant && !hasVowel) {
        buffer.write(halanta);
      }
      buffer.write(char);
      hasConsonant = false;
      hasVowel = false;
      i++;
    }

    // Handle final state - consonant without vowel gets halanta
    if (hasConsonant && !hasVowel) {
      buffer.write(halanta);
    }

    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MATCHING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  (String?, int) _matchConsonant(String word, int start) {
    // Check nukta consonants first
    for (int len = 2; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (nuktaConsonants.containsKey(substr)) {
          return (nuktaConsonants[substr], len);
        }
      }
    }

    // Then regular consonants (try longer matches first)
    for (int len = 3; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (consonants.containsKey(substr)) {
          return (consonants[substr], len);
        }
      }
    }
    return (null, 0);
  }

  (String?, int) _matchVowelSign(String word, int start) {
    for (int len = 3; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (vowelSigns.containsKey(substr)) {
          return (vowelSigns[substr], len);
        }
      }
    }
    return (null, 0);
  }

  (String?, int) _matchIndependentVowel(String word, int start) {
    for (int len = 3; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);
        if (independentVowels.containsKey(substr)) {
          return (independentVowels[substr], len);
        }
      }
    }
    return (null, 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUGGESTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  List<String> getSuggestions(String input, {int limit = 5}) {
    if (input.isEmpty) return [];

    final lastWord = input.split(RegExp(r'\s+')).last.toLowerCase();
    if (lastWord.isEmpty) return [];

    final suggestions = HiveService.getSuggestions(lastWord, 2, limit: limit);

    return suggestions.map((s) => s.englishWord).toList();
  }
}
