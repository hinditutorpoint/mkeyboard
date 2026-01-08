import 'base_transliterator.dart';

class GondiTransliterator implements BaseTransliterator {
  @override
  String get languageName => 'Gondi';

  @override
  String get fontFamily => 'NotoSansMasaramGondi';

  // Masaram Gondi Unicode range: U+11D00–U+11D5F
  static const Map<String, String> _directMappings = {
    'jokhar': '𑴕𑴽𑴎𑴦𑴢', // Hello/Greetings
    'namaskar': '𑴕𑴽𑴎𑴦𑴢 𑴦𑴛𑴧𑴘𑴦𑴢',
    'dhanyavaad': '𑴘𑴟𑴤𑴳𑴮𑴦𑴘', // Thank you
    'shukriya': '𑴡𑴲𑴎𑴴𑴢𑴱𑴦',
    'aap': '𑴀𑴦𑴧', // You
    'main': '𑴋𑴦𑴤', // I
    'naam': '𑴕𑴦𑴋', // Name
    'kaise': '𑴎𑴱𑴙𑴦', // How
    'theek': '𑴞𑴱𑴎', // Fine/OK
    'haan': '𑴮𑴦', // Yes
    'nahi': '𑴕𑴦𑴮𑴱', // No
  };

  // Masaram Gondi syllables mapping
  static const Map<String, String> _syllables = {
    // Numbers (0-9)
    '0': '𑵐', '1': '𑵑', '2': '𑵒', '3': '𑵓', '4': '𑵔',
    '5': '𑵕', '6': '𑵖', '7': '𑵗', '8': '𑵘', '9': '𑵙',

    // Independent vowels
    'a': '𑴀', 'aa': '𑴁', 'i': '𑴂', 'ii': '𑴃', 'ee': '𑴃',
    'u': '𑴄', 'uu': '𑴅', 'oo': '𑴅',
    'e': '𑴆', 'ai': '𑴈', 'o': '𑴋', 'au': '𑴌',

    // Consonants with inherent 'a'
    'ka': '𑴇', 'kha': '𑴈', 'ga': '𑴉', 'gha': '𑴊',
    'ca': '𑴋', 'cha': '𑴌', 'ja': '𑴍', 'jha': '𑴎',
    'nya': '𑴏',
    'ta': '𑴐', 'tha': '𑴑', 'da': '𑴒', 'dha': '𑴓',
    'na': '𑴔',
    'pa': '𑴕', 'pha': '𑴖', 'ba': '𑴗', 'bha': '𑴘',
    'ma': '𑴙',
    'ya': '𑴚', 'ra': '𑴛', 'la': '𑴜', 'va': '𑴝', 'wa': '𑴝',
    'sha': '𑴞', 'sa': '𑴟', 'ha': '𑴠',

    // Consonants with aa
    'kaa': '𑴇𑴱', 'khaa': '𑴈𑴱', 'gaa': '𑴉𑴱', 'ghaa': '𑴊𑴱',
    'caa': '𑴋𑴱', 'chaa': '𑴌𑴱', 'jaa': '𑴍𑴱', 'jhaa': '𑴎𑴱',
    'taa': '𑴐𑴱', 'thaa': '𑴑𑴱', 'daa': '𑴒𑴱', 'dhaa': '𑴓𑴱',
    'naa': '𑴔𑴱',
    'paa': '𑴕𑴱', 'phaa': '𑴖𑴱', 'baa': '𑴗𑴱', 'bhaa': '𑴘𑴱',
    'maa': '𑴙𑴱',
    'yaa': '𑴚𑴱', 'raa': '𑴛𑴱', 'laa': '𑴜𑴱', 'vaa': '𑴝𑴱',
    'shaa': '𑴞𑴱', 'saa': '𑴟𑴱', 'haa': '𑴠𑴱',

    // Consonants with i
    'ki': '𑴇𑴱𑴂', 'khi': '𑴈𑴱𑴂', 'gi': '𑴉𑴱𑴂', 'ghi': '𑴊𑴱𑴂',
    'ci': '𑴋𑴱𑴂', 'chi': '𑴌𑴱𑴂', 'ji': '𑴍𑴱𑴂', 'jhi': '𑴎𑴱𑴂',
    'ti': '𑴐𑴱𑴂', 'thi': '𑴑𑴱𑴂', 'di': '𑴒𑴱𑴂', 'dhi': '𑴓𑴱𑴂',
    'ni': '𑴔𑴱𑴂',
    'pi': '𑴕𑴱𑴂', 'phi': '𑴖𑴱𑴂', 'bi': '𑴗𑴱𑴂', 'bhi': '𑴘𑴱𑴂',
    'mi': '𑴙𑴱𑴂',
    'yi': '𑴚𑴱𑴂', 'ri': '𑴛𑴱𑴂', 'li': '𑴜𑴱𑴂', 'vi': '𑴝𑴱𑴂',
    'shi': '𑴞𑴱𑴂', 'si': '𑴟𑴱𑴂', 'hi': '𑴠𑴱𑴂',

    // Consonants with ee
    'kee': '𑴇𑴲', 'khee': '𑴈𑴲', 'gee': '𑴉𑴲', 'ghee': '𑴊𑴲',
    'cee': '𑴋𑴲', 'chee': '𑴌𑴲', 'jee': '𑴍𑴲', 'jhee': '𑴎𑴲',
    'tee': '𑴐𑴲', 'thee': '𑴑𑴲', 'dee': '𑴒𑴲', 'dhee': '𑴓𑴲',
    'nee': '𑴔𑴲',
    'pee': '𑴕𑴲', 'phee': '𑴖𑴲', 'bee': '𑴗𑴲', 'bhee': '𑴘𑴲',
    'mee': '𑴙𑴲',
    'yee': '𑴚𑴲', 'ree': '𑴛𑴲', 'lee': '𑴜𑴲', 'vee': '𑴝𑴲',
    'shee': '𑴞𑴲', 'see': '𑴟𑴲', 'hee': '𑴠𑴲',

    // Consonants with u
    'ku': '𑴇𑴳', 'khu': '𑴈𑴳', 'gu': '𑴉𑴳', 'ghu': '𑴊𑴳',
    'cu': '𑴋𑴳', 'chu': '𑴌𑴳', 'ju': '𑴍𑴳', 'jhu': '𑴎𑴳',
    'tu': '𑴐𑴳', 'thu': '𑴑𑴳', 'du': '𑴒𑴳', 'dhu': '𑴓𑴳',
    'nu': '𑴔𑴳',
    'pu': '𑴕𑴳', 'phu': '𑴖𑴳', 'bu': '𑴗𑴳', 'bhu': '𑴘𑴳',
    'mu': '𑴙𑴳',
    'yu': '𑴚𑴳', 'ru': '𑴛𑴳', 'lu': '𑴜𑴳', 'vu': '𑴝𑴳',
    'shu': '𑴞𑴳', 'su': '𑴟𑴳', 'hu': '𑴠𑴳',

    // Consonants with oo
    'koo': '𑴇𑴴', 'khoo': '𑴈𑴴', 'goo': '𑴉𑴴', 'ghoo': '𑴊𑴴',
    'coo': '𑴋𑴴', 'choo': '𑴌𑴴', 'joo': '𑴍𑴴', 'jhoo': '𑴎𑴴',
    'too': '𑴐𑴴', 'thoo': '𑴑𑴴', 'doo': '𑴒𑴴', 'dhoo': '𑴓𑴴',
    'noo': '𑴔𑴴',
    'poo': '𑴕𑴴', 'phoo': '𑴖𑴴', 'boo': '𑴗𑴴', 'bhoo': '𑴘𑴴',
    'moo': '𑴙𑴴',
    'yoo': '𑴚𑴴', 'roo': '𑴛𑴴', 'loo': '𑴜𑴴', 'voo': '𑴝𑴴',
    'shoo': '𑴞𑴴', 'soo': '𑴟𑴴', 'hoo': '𑴠𑴴',

    // Consonants with e
    'ke': '𑴇𑴵', 'khe': '𑴈𑴵', 'ge': '𑴉𑴵', 'ghe': '𑴊𑴵',
    'ce': '𑴋𑴵', 'che': '𑴌𑴵', 'je': '𑴍𑴵', 'jhe': '𑴎𑴵',
    'te': '𑴐𑴵', 'the': '𑴑𑴵', 'de': '𑴒𑴵', 'dhe': '𑴓𑴵',
    'ne': '𑴔𑴵',
    'pe': '𑴕𑴵', 'phe': '𑴖𑴵', 'be': '𑴗𑴵', 'bhe': '𑴘𑴵',
    'me': '𑴙𑴵',
    'ye': '𑴚𑴵', 're': '𑴛𑴵', 'le': '𑴜𑴵', 've': '𑴝𑴵',
    'she': '𑴞𑴵', 'se': '𑴟𑴵', 'he': '𑴠𑴵',

    // Consonants with o
    'ko': '𑴇𑴹', 'kho': '𑴈𑴹', 'go': '𑴉𑴹', 'gho': '𑴊𑴹',
    'co': '𑴋𑴹', 'cho': '𑴌𑴹', 'jo': '𑴍𑴹', 'jho': '𑴎𑴹',
    'to': '𑴐𑴹', 'tho': '𑴑𑴹', 'do': '𑴒𑴹', 'dho': '𑴓𑴹',
    'no': '𑴔𑴹',
    'po': '𑴕𑴹', 'pho': '𑴖𑴹', 'bo': '𑴗𑴹', 'bho': '𑴘𑴹',
    'mo': '𑴙𑴹',
    'yo': '𑴚𑴹', 'ro': '𑴛𑴹', 'lo': '𑴜𑴹', 'vo': '𑴝𑴹',
    'sho': '𑴞𑴹', 'so': '𑴟𑴹', 'ho': '𑴠𑴹',
  };

  @override
  String transliterate(String input) {
    if (input.isEmpty) return '';

    String text = input.toLowerCase().trim();

    // Check direct mapping
    if (_directMappings.containsKey(text)) {
      return _directMappings[text]!;
    }

    // Word-by-word
    List<String> words = text.split(' ');
    List<String> transliteratedWords = [];

    for (String word in words) {
      if (word.isEmpty) continue;

      if (_directMappings.containsKey(word)) {
        transliteratedWords.add(_directMappings[word]!);
      } else {
        transliteratedWords.add(_transliterateWord(word));
      }
    }

    return transliteratedWords.join(' ');
  }

  String _transliterateWord(String word) {
    String result = '';
    int i = 0;

    while (i < word.length) {
      bool matched = false;

      for (int len = 4; len >= 1 && !matched; len--) {
        if (i + len <= word.length) {
          String substr = word.substring(i, i + len);

          if (_syllables.containsKey(substr)) {
            result += _syllables[substr]!;
            i += len;
            matched = true;
          }
        }
      }

      if (!matched) {
        result += word[i];
        i++;
      }
    }

    return result;
  }

  @override
  List<String> getSuggestions(String input, {int limit = 5}) {
    if (input.isEmpty) return [];

    String lastWord = input.split(' ').last.toLowerCase();
    if (lastWord.isEmpty) return [];

    List<String> suggestions = _directMappings.keys
        .where((key) => key.startsWith(lastWord) && key != lastWord)
        .take(limit)
        .toList();

    return suggestions;
  }
}
