import 'base_transliterator.dart';
import '../services/hive_service.dart';

/// COMPLETE Masaram Gondi Transliterator with Proper Unicode
/// Follows official Unicode specification for Masaram Gondi (U+11D00–U+11D5F)
class GondiTransliterator implements BaseTransliterator {
  @override
  String get languageName => 'Gondi';

  @override
  String get fontFamily => 'NotoSansMasaramGondi';

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL COMBINING MARKS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String virama = '𑵅'; // Halant/Killer (removes 'a')
  static const String anusvara = '𑵀'; // ṃ/ṁ (nasalization)
  static const String visarga = '𑵁'; // ḥ/ः (aspiration)
  static const String sukun = '𑵂'; // No vowel marker
  static const String nukta = '𑵃'; // Dot (for aspirated/non-standard)
  static const String signNukta = '𑵄'; // Alternative nukta
  static const String raVowelSign1 = '𑵆'; // Ra vowel sign (older)
  static const String raVowelSign2 = '𑵇'; // Ra vowel sign (modern)

  // ═══════════════════════════════════════════════════════════════════════════
  // INDEPENDENT VOWELS (Standalone forms)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> independentVowels = {
    'a': '𑴀',
    'aa': '𑴁',
    'A': '𑴁',
    'i': '𑴂',
    'ii': '𑴃',
    'I': '𑴃',
    'ee': '𑴃',
    'u': '𑴄',
    'uu': '𑴅',
    'U': '𑴅',
    'oo': '𑴅',
    'ri': '𑴆',
    'R': '𑴆',
    'rii': '𑴇',
    'RR': '𑴇',
    'e': '𑴈',
    'o': '𑴉',
    'ai': '𑴊',
    'E': '𑴊',
    'au': '𑴋',
    'O': '𑴋',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // VOWEL SIGNS/MATRAS (Dependent forms - used after consonants)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> vowelSigns = {
    'a': '', // Inherent vowel (no sign needed)
    'aa': '𑴱',
    'A': '𑴱',
    'i': '𑴲',
    'ii': '𑴳',
    'I': '𑴳',
    'ee': '𑴳',
    'u': '𑴴',
    'uu': '𑴵',
    'U': '𑴵',
    'oo': '𑴵',
    'ri': '𑴶',
    'R': '𑴶',
    'rii': '𑴷',
    'RR': '𑴷',
    'e': '𑴺',
    'o': '𑴽',
    'oo2': '𑴾', // Alternate o
    'ai': '𑴼',
    'E': '𑴼',
    'au': '𑴿',
    'O': '𑴿',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSONANTS (Base forms with inherent 'a')
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> consonants = {
    // VELARS (कवर्ग)
    'ka': '𑴌',
    'k': '𑴌',
    'K': '𑴌',
    'kha': '𑴍',
    'kh': '𑴍',
    'Kh': '𑴍',
    'ga': '𑴎',
    'g': '𑴎',
    'G': '𑴎',
    'gha': '𑴏',
    'gh': '𑴏',
    'Gh': '𑴏',
    'nga': '𑴐',
    'ng': '𑴐',
    'NG': '𑴐',

    // PALATALS (चवर्ग)
    'ca': '𑴑',
    'cha': '𑴑',
    'ch': '𑴑',
    'c': '𑴑',
    'chha': '𑴒',
    'chh': '𑴒',
    'Ch': '𑴒',
    'ja': '𑴓',
    'j': '𑴓',
    'J': '𑴓',
    'jha': '𑴔',
    'jh': '𑴔',
    'Jh': '𑴔',
    'nya': '𑴕',
    'ny': '𑴕',
    'nya2': '𑴕',

    // RETROFLEXES (टवर्ग)
    'Ta': '𑴖',
    'T': '𑴖',
    'TA': '𑴖',
    'Tha': '𑴗',
    'Th': '𑴗',
    'TH': '𑴗',
    'Da': '𑴘',
    'D': '𑴘',
    'DA': '𑴘',
    'Dha': '𑴙',
    'Dh': '𑴙',
    'DH': '𑴙',
    'Na': '𑴚',
    'N': '𑴚',
    'NA': '𑴚',

    // DENTALS (तवर्ग)
    'ta': '𑴛',
    't': '𑴛',
    'tha': '𑴜',
    'th': '𑴜',
    'da': '𑴝',
    'd': '𑴝',
    'dha': '𑴞',
    'dh': '𑴞',
    'na': '𑴟',
    'n': '𑴟',

    // LABIALS (पवर्ग)
    'pa': '𑴠',
    'p': '𑴠',
    'P': '𑴠',
    'pha': '𑴡',
    'ph': '𑴡',
    'Ph': '𑴡',
    'ba': '𑴢',
    'b': '𑴢',
    'B': '𑴢',
    'bha': '𑴣',
    'bh': '𑴣',
    'Bh': '𑴣',
    'ma': '𑴤',
    'm': '𑴤',
    'M': '𑴤',

    // SEMIVOWELS (अंतस्थ)
    'ya': '𑴥',
    'y': '𑴥',
    'Y': '𑴥',
    'ra': '𑴦',
    'r': '𑴦',
    'R': '𑴦',
    'la': '𑴧',
    'l': '𑴧',
    'L': '𑴧',
    'va': '𑴨',
    'v': '𑴨',
    'V': '𑴨',
    'wa': '𑴨',
    'w': '𑴨',
    'W': '𑴨',

    // SIBILANTS (ऊष्म)
    'sha': '𑴩',
    'sh': '𑴩',
    'SH': '𑴩',
    'ssa': '𑴪',
    'ss': '𑴪',
    'SS': '𑴪',
    'sa': '𑴫',
    's': '𑴫',
    'S': '𑴫',
    'ha': '𑴬',
    'h': '𑴬',
    'H': '𑴬',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL CONSONANT FORMS (with nukta/visarga)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> specialConsonants = {
    // Nukta forms (Urdu/Persian sounds)
    'qa': '𑴌$signNukta',
    'q': '𑴌$signNukta',
    'khha': '𑴍$signNukta',
    'x': '𑴍$signNukta',
    'X': '𑴍$signNukta',
    'za': '𑴓$signNukta',
    'z': '𑴓$signNukta',
    'Z': '𑴓$signNukta',
    'dda': '𑴘$signNukta',
    'rha': '𑴘$signNukta',
    'fa': '𑴡$signNukta',
    'f': '𑴡$signNukta',
    'F': '𑴡$signNukta',

    // South-Indic forms
    'la_': '𑴭', // Special la
    'zha': '𑴭', // ḻa
    'rra': '𑴦$sukun', // ṟa
    'nna': '𑴟$sukun', // ṉa
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // CONJUNCTS (Consonant clusters)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> conjuncts = {
    // KSH ligature
    'ksha': '𑴮',
    'ksh': '𑴮',
    'kshe': '𑴮𑴺',
    'kshaa': '𑴮𑴱',

    // RA-form conjuncts (using ra vowel sign)
    'kra': '𑴌$raVowelSign2',
    'kr': '𑴌$raVowelSign2',
    'krai': '𑴌$raVowelSign2𑴼',
    'kraa': '𑴌$raVowelSign2𑴱',

    'khra': '𑴍$raVowelSign2',
    'khr': '𑴍$raVowelSign2',
    'gra': '𑴎$raVowelSign2',
    'gr': '𑴎$raVowelSign2',
    'ghra': '𑴏$raVowelSign2',
    'ghr': '𑴏$raVowelSign2',
    'nga_ra': '𑴐$raVowelSign2',

    'chra': '𑴒$raVowelSign2',
    'chr': '𑴒$raVowelSign2',
    'jra': '𑴓$raVowelSign2',
    'jr': '𑴓$raVowelSign2',
    'jhra': '𑴔$raVowelSign2',

    'Tra': '𑴖$raVowelSign2',
    'Tr': '𑴖$raVowelSign2',
    'Thra': '𑴗$raVowelSign2',
    'Dra': '𑴘$raVowelSign2',
    'Dr': '𑴘$raVowelSign2',
    'Dhra': '𑴙$raVowelSign2',

    'tra': '𑴛$raVowelSign2',
    'tr': '𑴛$raVowelSign2',
    'trai': '𑴛$raVowelSign2𑴼',
    'traa': '𑴛$raVowelSign2𑴱',
    'thra': '𑴜$raVowelSign2',
    'thr': '𑴜$raVowelSign2',
    'dra': '𑴝$raVowelSign2',
    'dr': '𑴝$raVowelSign2',
    'dhra': '𑴞$raVowelSign2',
    'dhr': '𑴞$raVowelSign2',

    'pra': '𑴠$raVowelSign2',
    'pr': '𑴠$raVowelSign2',
    'prai': '𑴠$raVowelSign2𑴼',
    'praa': '𑴠$raVowelSign2𑴱',
    'phra': '𑴡$raVowelSign2',
    'phr': '𑴡$raVowelSign2',
    'bra': '𑴢$raVowelSign2',
    'br': '𑴢$raVowelSign2',
    'bhra': '𑴣$raVowelSign2',
    'bhr': '𑴣$raVowelSign2',
    'mra': '𑴤$raVowelSign2',
    'mr': '𑴤$raVowelSign2',

    'shra': '𑴩$raVowelSign2',
    'shr': '𑴩$raVowelSign2',
    'shrai': '𑴩$raVowelSign2𑴼',
    'shraa': '𑴩$raVowelSign2𑴱',
    'vra': '𑴨$raVowelSign2',
    'vr': '𑴨$raVowelSign2',
    'hra': '𑴬$raVowelSign2',
    'hr': '𑴬$raVowelSign2',

    // Double consonants
    'kka': '𑴌$virama𑴌',
    'kkai': '𑴌$virama𑴌𑴼',
    'kkaa': '𑴌$virama𑴌𑴱',
    'gga': '𑴎$virama𑴎',
    'chcha': '𑴒$virama𑴒',
    'jja': '𑴓$virama𑴓',
    'jjai': '𑴓$virama𑴓𑴼',
    'TDa': '𑴖$virama𑴖',
    'DDa': '𑴘$virama𑴘',
    'tta': '𑴛$virama𑴛',
    'ttai': '𑴛$virama𑴛𑴼',
    'ttaa': '𑴛$virama𑴛𑴱',
    'dda': '𑴝$virama𑴝',
    'nna': '𑴟$virama𑴟',
    'ppa': '𑴠$virama𑴠',
    'bba': '𑴢$virama𑴢',
    'mma': '𑴤$virama𑴤',
    'yya': '𑴥$virama𑴥',
    'lla': '𑴧$virama𑴧',
    'vva': '𑴨$virama𑴨',
    'ssa': '𑴫$virama𑴫',
    'ssai': '𑴫$virama𑴫𑴼',

    // Other common conjuncts
    'kta': '𑴌$virama𑴛',
    'kya': '𑴌$virama𑴥',
    'ky': '𑴌$virama𑴥',
    'kva': '𑴌$virama𑴨',
    'kv': '𑴌$virama𑴨',
    'kla': '𑴌$virama𑴧',
    'kl': '𑴌$virama𑴧',
    'kna': '𑴌$virama𑴟',
    'kn': '𑴌$virama𑴟',
    'kma': '𑴌$virama𑴤',
    'km': '𑴌$virama𑴤',

    'gya': '𑴎$virama𑴥',
    'gy': '𑴎$virama𑴥',
    'gna': '𑴎$virama𑴟',
    'gn': '𑴎$virama𑴟',
    'gla': '𑴎$virama𑴧',
    'gl': '𑴎$virama𑴧',

    'cha': '𑴑$virama𑴑',
    'chya': '𑴒$virama𑴥',
    'chy': '𑴒$virama𑴥',

    'jya': '𑴓$virama𑴥',
    'jy': '𑴓$virama𑴥',
    'jna': '𑴓$virama𑴕', // Ligature for ñ
    'jn': '𑴓$virama𑴕',

    'Tya': '𑴖$virama𑴥',
    'Ty': '𑴖$virama𑴥',
    'Tva': '𑴖$virama𑴨',
    'Tv': '𑴖$virama𑴨',

    'Dya': '𑴘$virama𑴥',
    'Dy': '𑴘$virama𑴥',

    'tya': '𑴛$virama𑴥',
    'ty': '𑴛$virama𑴥',
    'tyai': '𑴛$virama𑴥𑴼',
    'tva': '𑴛$virama𑴨',
    'tv': '𑴛$virama𑴨',
    'tna': '𑴛$virama𑴟',
    'tn': '𑴛$virama𑴟',
    'tma': '𑴛$virama𑴤',
    'tm': '𑴛$virama𑴤',

    'dya': '𑴝$virama𑴥',
    'dy': '𑴝$virama𑴥',
    'dva': '𑴝$virama𑴨',
    'dv': '𑴝$virama𑴨',
    'dna': '𑴝$virama𑴟',
    'dn': '𑴝$virama𑴟',

    'dhya': '𑴞$virama𑴥',
    'dhy': '𑴞$virama𑴥',
    'dhva': '𑴞$virama𑴨',
    'dhv': '𑴞$virama𑴨',

    'nta': '𑴟$virama𑴛',
    'nt': '𑴟$virama𑴛',
    'nda': '𑴟$virama𑴝',
    'nd': '𑴟$virama𑴝',
    'ndha': '𑴟$virama𑴞',
    'ndh': '𑴟$virama𑴞',
    'nya_': '𑴟$virama𑴥',
    'nma': '𑴟$virama𑴤',
    'nm': '𑴟$virama𑴤',
    'nva': '𑴟$virama𑴨',
    'nv': '𑴟$virama𑴨',

    'pya': '𑴠$virama𑴥',
    'py': '𑴠$virama𑴥',
    'pla': '𑴠$virama𑴧',
    'pl': '𑴠$virama𑴧',
    'pta': '𑴠$virama𑴛',
    'pt': '𑴠$virama𑴛',

    'phya': '𑴡$virama𑴥',
    'phy': '𑴡$virama𑴥',

    'bya': '𑴢$virama𑴥',
    'by': '𑴢$virama𑴥',
    'bda': '𑴢$virama𑴝',
    'bd': '𑴢$virama𑴝',

    'bhya': '𑴣$virama𑴥',
    'bhy': '𑴣$virama𑴥',
    'bhva': '𑴣$virama𑴨',
    'bhv': '𑴣$virama𑴨',

    'mya': '𑴤$virama𑴥',
    'my': '𑴤$virama𑴥',
    'mba': '𑴤$virama𑴢',
    'mb': '𑴤$virama𑴢',
    'mpa': '𑴤$virama𑴠',
    'mp': '𑴤$virama𑴠',
    'mla': '𑴤$virama𑴧',
    'ml': '𑴤$virama𑴧',

    'rka': '𑴦$virama𑴌',
    'rk': '𑴦$virama𑴌',
    'rga': '𑴦$virama𑴎',
    'rg': '𑴦$virama𑴎',
    'rcha': '𑴦$virama𑴒',
    'rch': '𑴦$virama𑴒',
    'rja': '𑴦$virama𑴓',
    'rj': '𑴦$virama𑴓',
    'rta': '𑴦$virama𑴛',
    'rt': '𑴦$virama𑴛',
    'rda': '𑴦$virama𑴝',
    'rd': '𑴦$virama𑴝',
    'rna': '𑴦$virama𑴟',
    'rn': '𑴦$virama𑴟',
    'rpa': '𑴦$virama𑴠',
    'rp': '𑴦$virama𑴠',
    'rba': '𑴦$virama𑴢',
    'rb': '𑴦$virama𑴢',
    'rma': '𑴦$virama𑴤',
    'rm': '𑴦$virama𑴤',
    'rya': '𑴦$virama𑴥',
    'ry': '𑴦$virama𑴥',
    'rva': '𑴦$virama𑴨',
    'rv': '𑴦$virama𑴨',
    'rsha': '𑴦$virama𑴩',
    'rsh': '𑴦$virama𑴩',
    'rsa': '𑴦$virama𑴫',
    'rs': '𑴦$virama𑴫',

    'lka': '𑴧$virama𑴌',
    'lk': '𑴧$virama𑴌',
    'lga': '𑴧$virama𑴎',
    'lg': '𑴧$virama𑴎',
    'lpa': '𑴧$virama𑴠',
    'lp': '𑴧$virama𑴠',
    'lba': '𑴧$virama𑴢',
    'lb': '𑴧$virama𑴢',
    'lma': '𑴧$virama𑴤',
    'lm': '𑴧$virama𑴤',
    'lya': '𑴧$virama𑴥',
    'ly': '𑴧$virama𑴥',
    'lva': '𑴧$virama𑴨',
    'lv': '𑴧$virama𑴨',

    'vya': '𑴨$virama𑴥',
    'vy': '𑴨$virama𑴥',

    'shya': '𑴩$virama𑴥',
    'shy': '𑴩$virama𑴥',
    'shva': '𑴩$virama𑴨',
    'shv': '𑴩$virama𑴨',

    'ska': '𑴫$virama𑴌',
    'sk': '𑴫$virama𑴌',
    'sta': '𑴫$virama𑴛',
    'st': '𑴫$virama𑴛',
    'stra': '𑴫$virama𑴛$raVowelSign2',
    'str': '𑴫$virama𑴛$raVowelSign2',
    'stya': '𑴫$virama𑴛$virama𑴥',
    'sty': '𑴫$virama𑴛$virama𑴥',
    'stha': '𑴫$virama𑴜',
    'sth': '𑴫$virama𑴜',
    'sna': '𑴫$virama𑴟',
    'sn': '𑴫$virama𑴟',
    'spa': '𑴫$virama𑴠',
    'sp': '𑴫$virama𑴠',
    'sma': '𑴫$virama𑴤',
    'sm': '𑴫$virama𑴤',
    'sva': '𑴫$virama𑴨',
    'sv': '𑴫$virama𑴨',

    'hma': '𑴬$virama𑴤',
    'hm': '𑴬$virama𑴤',
    'hna': '𑴬$virama𑴟',
    'hn': '𑴬$virama𑴟',
    'hya': '𑴬$virama𑴥',
    'hy': '𑴬$virama𑴥',
    'hva': '𑴬$virama𑴨',
    'hv': '𑴬$virama𑴨',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // NUMBERS (Masaram Gondi Digits)
  // ═══════════════════════════════════════════════════════════════════════════

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

  // Cache
  final Map<String, String> _cache = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN TRANSLITERATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String transliterate(String input) {
    if (input.isEmpty) return '';

    if (_cache.containsKey(input)) {
      return _cache[input]!;
    }

    final words = input.split(RegExp(r'\s+'));
    final result = words.map(_transliterateWord).join(' ');

    _cache[input] = result;

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
      // Handle numbers
      if (numbers.containsKey(word[i])) {
        if (lastWasConsonant) {
          buffer.write(virama);
          lastWasConsonant = false;
        }
        buffer.write(numbers[word[i]]!);
        i++;
        continue;
      }

      // Try longer conjuncts first (up to 5 characters)
      bool matched = false;
      for (int len = 5; len >= 2; len--) {
        if (i + len <= word.length) {
          final substr = word.substring(i, i + len).toLowerCase();

          // Try conjuncts first
          if (conjuncts.containsKey(substr)) {
            if (lastWasConsonant) buffer.write(virama);
            buffer.write(conjuncts[substr]!);
            i += len;
            lastWasConsonant = true;
            matched = true;
            break;
          }

          // Try special consonants (nukta forms)
          if (specialConsonants.containsKey(substr)) {
            if (lastWasConsonant) buffer.write(virama);
            buffer.write(specialConsonants[substr]!);
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
        if (lastWasConsonant) buffer.write(virama);
        buffer.write(consonantMatch.$1!);
        i += consonantMatch.$2;

        // Try to match vowel sign after consonant
        if (i < word.length) {
          final vowelMatch = _matchVowelSign(word, i);
          if (vowelMatch.$1 != null && vowelMatch.$1!.isNotEmpty) {
            buffer.write(vowelMatch.$1!);
            i += vowelMatch.$2;
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
      final vowelMatch = _matchIndependentVowel(word, i);
      if (vowelMatch.$1 != null) {
        if (lastWasConsonant) buffer.write(virama);
        buffer.write(vowelMatch.$1!);
        i += vowelMatch.$2;
        lastWasConsonant = false;
        continue;
      }

      // Handle anusvara (m/n before consonant)
      final char = word[i].toLowerCase();
      if ((char == 'm' || char == 'n') && i + 1 < word.length) {
        final next = word[i + 1].toLowerCase();
        if (consonants.containsKey(next) ||
            consonants.containsKey('${next}a') ||
            consonants.containsKey('${next}ha')) {
          buffer.write(anusvara);
          i++;
          lastWasConsonant = false;
          continue;
        }
      }

      // Handle visarga (h at end or before consonant)
      if (char == 'h') {
        if (i + 1 >= word.length) {
          buffer.write(visarga);
          i++;
          lastWasConsonant = false;
          continue;
        } else if (word[i + 1] == ' ') {
          buffer.write(visarga);
          i++;
          lastWasConsonant = false;
          continue;
        }
      }

      // Unmatched character
      if (lastWasConsonant && word[i] != ' ') {
        buffer.write(virama);
        lastWasConsonant = false;
      }
      buffer.write(word[i]);
      i++;
    }

    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MATCHING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  (String?, int) _matchConsonant(String word, int start) {
    for (int len = 4; len >= 1; len--) {
      if (start + len <= word.length) {
        final substr = word.substring(start, start + len);

        // Try exact match first
        if (consonants.containsKey(substr)) {
          return (consonants[substr], len);
        }

        // Try lowercase
        if (consonants.containsKey(substr.toLowerCase())) {
          return (consonants[substr.toLowerCase()], len);
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

        if (vowelSigns.containsKey(substr.toLowerCase())) {
          return (vowelSigns[substr.toLowerCase()], len);
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

        if (independentVowels.containsKey(substr.toLowerCase())) {
          return (independentVowels[substr.toLowerCase()], len);
        }
      }
    }
    return (null, 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUGGESTIONS (using JSON loader)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  List<String> getSuggestions(String input, {int limit = 5}) {
    if (input.isEmpty) return [];

    final lastWord = input.split(RegExp(r'\s+')).last.toLowerCase();
    if (lastWord.isEmpty) return [];

    // Get from Hive
    final suggestions = HiveService.getSuggestions(
      lastWord,
      2, // Gondi languageIndex
      limit: limit,
    );

    return suggestions.map((s) => s.englishWord).toList();
  }
}
