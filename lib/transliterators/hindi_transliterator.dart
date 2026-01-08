import 'base_transliterator.dart';

class HindiTransliterator implements BaseTransliterator {
  @override
  String get languageName => 'Hindi';

  @override
  String get fontFamily => 'NotoSansDevanagari';

  // ═══════════════════════════════════════════════════════════════════════════
  // DEVANAGARI CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _virama = '्'; // Halant
  static const String _chandrabindu = 'ँ';
  static const String _anusvara = 'ं';
  static const String _visarga = 'ः';
  static const String _nukta = '़';

  // ═══════════════════════════════════════════════════════════════════════════
  // INDEPENDENT VOWELS (स्वर)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> _vowels = {
    'a': 'अ',
    'aa': 'आ',
    'A': 'आ',
    'i': 'इ',
    'ee': 'ई',
    'ii': 'ई',
    'I': 'ई',
    'u': 'उ',
    'oo': 'ऊ',
    'uu': 'ऊ',
    'U': 'ऊ',
    'ri': 'ऋ',
    'Ri': 'ऋ',
    'e': 'ए',
    'ai': 'ऐ',
    'E': 'ऐ',
    'o': 'ओ',
    'au': 'औ',
    'ou': 'औ',
    'O': 'औ',
    'aM': 'अं',
    'aH': 'अः',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // VOWEL MATRAS (Dependent Vowels - मात्राएं)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> _matras = {
    'a': '', // Inherent vowel - no matra needed
    'aa': 'ा', 'A': 'ा',
    'i': 'ि',
    'ee': 'ी', 'ii': 'ी', 'I': 'ी',
    'u': 'ु',
    'oo': 'ू', 'uu': 'ू', 'U': 'ू',
    'ri': 'ृ', 'Ri': 'ृ',
    'e': 'े',
    'ai': 'ै', 'E': 'ै',
    'o': 'ो',
    'au': 'ौ', 'ou': 'ौ', 'O': 'ौ',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSONANTS (व्यंजन)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> _consonants = {
    // Velars (कवर्ग)
    'k': 'क', 'K': 'क',
    'kh': 'ख', 'Kh': 'ख',
    'g': 'ग', 'G': 'ग',
    'gh': 'घ', 'Gh': 'घ',
    'ng': 'ङ',

    // Palatals (चवर्ग)
    'ch': 'च', 'c': 'च',
    'chh': 'छ', 'Ch': 'छ',
    'j': 'ज', 'J': 'ज',
    'jh': 'झ', 'Jh': 'झ',
    'ny': 'ञ', 'Ny': 'ञ',

    // Retroflexes (टवर्ग)
    'T': 'ट',
    'Th': 'ठ',
    'D': 'ड',
    'Dh': 'ढ',
    'N': 'ण',

    // Dentals (तवर्ग)
    't': 'त',
    'th': 'थ',
    'd': 'द',
    'dh': 'ध',
    'n': 'न',

    // Labials (पवर्ग)
    'p': 'प', 'P': 'प',
    'ph': 'फ', 'Ph': 'फ', 'f': 'फ', 'F': 'फ',
    'b': 'ब', 'B': 'ब',
    'bh': 'भ', 'Bh': 'भ',
    'm': 'म', 'M': 'म',

    // Semi-vowels (अंतस्थ)
    'y': 'य', 'Y': 'य',
    'r': 'र', 'R': 'र',
    'l': 'ल', 'L': 'ल',
    'v': 'व', 'w': 'व', 'V': 'व', 'W': 'व',

    // Sibilants (ऊष्म)
    'sh': 'श', 'Sh': 'श',
    'shh': 'ष', 'Shh': 'ष',
    's': 'स', 'S': 'स',
    'h': 'ह', 'H': 'ह',

    // Nukta consonants (for Urdu/Persian sounds)
    'q': 'क़',
    'kh.': 'ख़', 'x': 'ख़', 'X': 'ख़',
    'G.': 'ग़', 'Gh.': 'ग़',
    'z': 'ज़', 'Z': 'ज़',
    'zh': 'झ़',
    'f.': 'फ़',
    'R.': 'ड़', '.D': 'ड़',
    'Rh': 'ढ़', '.Dh': 'ढ़',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL CONJUNCTS (संयुक्त अक्षर)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, String> _conjuncts = {
    'ksh': 'क्ष',
    'kSh': 'क्ष',
    'x': 'क्ष',
    'gy': 'ज्ञ',
    'gY': 'ज्ञ',
    'dny': 'ज्ञ',
    'tr': 'त्र',
    'shr': 'श्र',
    'shri': 'श्री',
    'shree': 'श्री',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // NUMBERS
  // ═══════════════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON WORDS DICTIONARY (with frequency scores)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, _WordEntry> _dictionary = {
    // Greetings & Common phrases
    'namaste': _WordEntry('नमस्ते', 100, ['namastey', 'namasthe']),
    'namaskar': _WordEntry('नमस्कार', 95, ['namaskaaar']),
    'dhanyavaad': _WordEntry('धन्यवाद', 90, ['dhanyawad', 'dhanyavad']),
    'dhanyawad': _WordEntry('धन्यवाद', 90, []),
    'shukriya': _WordEntry('शुक्रिया', 88, ['sukriya']),
    'alvida': _WordEntry('अलविदा', 75, ['alwida']),
    'swagat': _WordEntry('स्वागत', 80, ['swagath']),
    'shubh': _WordEntry('शुभ', 70, ['subh']),
    'shubhkamnaye': _WordEntry('शुभकामनाएं', 65, ['subhkamnaye']),

    // Pronouns (सर्वनाम)
    'main': _WordEntry('मैं', 100, ['mein', 'mai']),
    'mein': _WordEntry('मैं', 100, []),
    'hum': _WordEntry('हम', 98, ['ham']),
    'tum': _WordEntry('तुम', 97, ['tuma']),
    'aap': _WordEntry('आप', 99, ['ap']),
    'yeh': _WordEntry('यह', 96, ['ye', 'yah']),
    'woh': _WordEntry('वह', 95, ['wo', 'vah', 'voh']),
    'ye': _WordEntry('ये', 94, []),
    'wo': _WordEntry('वो', 93, ['vo']),
    'kaun': _WordEntry('कौन', 88, ['kon']),
    'kya': _WordEntry('क्या', 99, ['kia']),
    'kab': _WordEntry('कब', 90, []),
    'kahan': _WordEntry('कहाँ', 89, ['kahaan', 'kaha']),
    'kaise': _WordEntry('कैसे', 92, ['kese']),
    'kyun': _WordEntry('क्यों', 87, ['kyu', 'kyon']),
    'kitna': _WordEntry('कितना', 85, ['kitana']),
    'kaisa': _WordEntry('कैसा', 86, ['kesa']),

    // Verbs - To Be (होना)
    'hai': _WordEntry('है', 100, ['he', 'hay']),
    'hain': _WordEntry('हैं', 98, ['hein']),
    'tha': _WordEntry('था', 95, []),
    'the': _WordEntry('थे', 94, ['they']),
    'thi': _WordEntry('थी', 93, ['thee']),
    'thin': _WordEntry('थीं', 92, ['theen']),
    'hoga': _WordEntry('होगा', 88, ['hoga']),
    'hogi': _WordEntry('होगी', 87, ['hogee']),
    'hoge': _WordEntry('होंगे', 86, []),
    'ho': _WordEntry('हो', 90, []),
    'hona': _WordEntry('होना', 85, []),
    'hua': _WordEntry('हुआ', 84, ['huaa']),
    'hui': _WordEntry('हुई', 83, ['huee']),
    'hue': _WordEntry('हुए', 82, ['huye']),

    // Common Verbs
    'karna': _WordEntry('करना', 95, ['karana']),
    'karta': _WordEntry('करता', 90, ['karata']),
    'karti': _WordEntry('करती', 89, ['karatee']),
    'karte': _WordEntry('करते', 88, ['karate']),
    'karo': _WordEntry('करो', 87, []),
    'kiya': _WordEntry('किया', 86, ['kia']),
    'kar': _WordEntry('कर', 85, []),
    'karunga': _WordEntry('करूँगा', 80, ['karoonga']),
    'karungi': _WordEntry('करूँगी', 79, ['karoongi']),
    'karenge': _WordEntry('करेंगे', 78, []),

    'jana': _WordEntry('जाना', 92, ['jaana']),
    'jata': _WordEntry('जाता', 88, ['jaata']),
    'jati': _WordEntry('जाती', 87, ['jaatee']),
    'jao': _WordEntry('जाओ', 86, []),
    'gaya': _WordEntry('गया', 90, ['gayaa']),
    'gayi': _WordEntry('गई', 89, ['gayee']),
    'gaye': _WordEntry('गए', 88, ['gaye']),
    'jaunga': _WordEntry('जाऊँगा', 75, ['jaaunga']),
    'jaungi': _WordEntry('जाऊँगी', 74, ['jaaungi']),
    'jayenge': _WordEntry('जाएंगे', 73, []),

    'aana': _WordEntry('आना', 90, ['ana']),
    'aata': _WordEntry('आता', 86, ['ata']),
    'aati': _WordEntry('आती', 85, ['atee']),
    'aao': _WordEntry('आओ', 84, ['ao']),
    'aaya': _WordEntry('आया', 88, ['aya']),
    'aayi': _WordEntry('आई', 87, ['ayee']),
    'aaye': _WordEntry('आए', 86, ['aye']),
    'aaunga': _WordEntry('आऊँगा', 72, []),
    'aaungi': _WordEntry('आऊँगी', 71, []),

    'khana': _WordEntry('खाना', 88, ['khaana']),
    'khata': _WordEntry('खाता', 82, ['khaata']),
    'khati': _WordEntry('खाती', 81, ['khaatee']),
    'khao': _WordEntry('खाओ', 80, []),
    'khaya': _WordEntry('खाया', 85, ['khaayaa']),

    'peena': _WordEntry('पीना', 85, ['pina']),
    'peeta': _WordEntry('पीता', 80, ['pita']),
    'piti': _WordEntry('पीती', 79, ['peetee']),
    'piyo': _WordEntry('पियो', 78, []),
    'piya': _WordEntry('पिया', 82, ['piyaa']),

    'bolna': _WordEntry('बोलना', 84, []),
    'bolta': _WordEntry('बोलता', 78, []),
    'bolti': _WordEntry('बोलती', 77, []),
    'bolo': _WordEntry('बोलो', 76, []),
    'bola': _WordEntry('बोला', 80, []),
    'boli': _WordEntry('बोली', 79, []),

    'sunna': _WordEntry('सुनना', 82, ['sunana']),
    'sunta': _WordEntry('सुनता', 76, []),
    'sunti': _WordEntry('सुनती', 75, []),
    'suno': _WordEntry('सुनो', 78, []),
    'suna': _WordEntry('सुना', 77, []),
    'suni': _WordEntry('सुनी', 76, []),

    'dekhna': _WordEntry('देखना', 86, []),
    'dekhta': _WordEntry('देखता', 80, []),
    'dekhti': _WordEntry('देखती', 79, []),
    'dekho': _WordEntry('देखो', 82, []),
    'dekha': _WordEntry('देखा', 84, []),
    'dekhi': _WordEntry('देखी', 83, []),

    'likhna': _WordEntry('लिखना', 80, []),
    'likhta': _WordEntry('लिखता', 74, []),
    'likhti': _WordEntry('लिखती', 73, []),
    'likho': _WordEntry('लिखो', 72, []),
    'likha': _WordEntry('लिखा', 76, []),
    'likhi': _WordEntry('लिखी', 75, []),

    'padhna': _WordEntry('पढ़ना', 82, ['padhana']),
    'padhta': _WordEntry('पढ़ता', 76, []),
    'padhti': _WordEntry('पढ़ती', 75, []),
    'padho': _WordEntry('पढ़ो', 74, []),
    'padha': _WordEntry('पढ़ा', 78, []),
    'padhi': _WordEntry('पढ़ी', 77, []),

    'milna': _WordEntry('मिलना', 84, []),
    'milta': _WordEntry('मिलता', 78, []),
    'milti': _WordEntry('मिलती', 77, []),
    'milo': _WordEntry('मिलो', 76, []),
    'mila': _WordEntry('मिला', 80, []),
    'mili': _WordEntry('मिली', 79, []),
    'milenge': _WordEntry('मिलेंगे', 75, []),

    'chahna': _WordEntry('चाहना', 82, ['chaahna']),
    'chahta': _WordEntry('चाहता', 78, ['chaahta']),
    'chahti': _WordEntry('चाहती', 77, ['chaahtee']),
    'chaho': _WordEntry('चाहो', 76, []),
    'chaha': _WordEntry('चाहा', 80, []),
    'chahiye': _WordEntry('चाहिए', 90, ['chahie']),

    'samajhna': _WordEntry('समझना', 78, []),
    'samajhta': _WordEntry('समझता', 72, []),
    'samajhti': _WordEntry('समझती', 71, []),
    'samjho': _WordEntry('समझो', 70, []),
    'samjha': _WordEntry('समझा', 74, []),
    'samjhi': _WordEntry('समझी', 73, []),

    'sochna': _WordEntry('सोचना', 76, []),
    'sochta': _WordEntry('सोचता', 70, []),
    'sochti': _WordEntry('सोचती', 69, []),
    'socha': _WordEntry('सोचा', 72, []),
    'sochi': _WordEntry('सोची', 71, []),

    'rakhna': _WordEntry('रखना', 78, []),
    'rakhta': _WordEntry('रखता', 72, []),
    'rakhti': _WordEntry('रखती', 71, []),
    'rakho': _WordEntry('रखो', 70, []),
    'rakha': _WordEntry('रखा', 74, []),
    'rakhi': _WordEntry('रखी', 73, []),

    'lena': _WordEntry('लेना', 88, ['lena']),
    'leta': _WordEntry('लेता', 82, []),
    'leti': _WordEntry('लेती', 81, []),
    'lo': _WordEntry('लो', 85, []),
    'liya': _WordEntry('लिया', 86, []),
    'li': _WordEntry('ली', 84, []),
    'liye': _WordEntry('लिए', 88, []),
    'lunga': _WordEntry('लूँगा', 75, ['loonga']),
    'lungi': _WordEntry('लूँगी', 74, ['loongi']),

    'dena': _WordEntry('देना', 88, []),
    'deta': _WordEntry('देता', 82, []),
    'deti': _WordEntry('देती', 81, []),
    'do': _WordEntry('दो', 85, []),
    'diya': _WordEntry('दिया', 86, []),
    'di': _WordEntry('दी', 84, []),
    'diye': _WordEntry('दिए', 83, []),
    'dunga': _WordEntry('दूँगा', 75, ['doonga']),
    'dungi': _WordEntry('दूँगी', 74, ['doongi']),

    'rehna': _WordEntry('रहना', 82, []),
    'rehta': _WordEntry('रहता', 76, []),
    'rehti': _WordEntry('रहती', 75, []),
    'raho': _WordEntry('रहो', 74, []),
    'raha': _WordEntry('रहा', 80, []),
    'rahi': _WordEntry('रही', 79, []),
    'rahe': _WordEntry('रहे', 78, []),
    'rahunga': _WordEntry('रहूँगा', 70, []),
    'rahungi': _WordEntry('रहूँगी', 69, []),

    // Adjectives/Adverbs (विशेषण)
    'accha': _WordEntry('अच्छा', 95, ['acha', 'achha']),
    'acchi': _WordEntry('अच्छी', 94, ['achi', 'achhi']),
    'acche': _WordEntry('अच्छे', 93, ['ache', 'achhe']),
    'bura': _WordEntry('बुरा', 88, []),
    'buri': _WordEntry('बुरी', 87, []),
    'bure': _WordEntry('बुरे', 86, []),

    'bada': _WordEntry('बड़ा', 90, ['bara']),
    'badi': _WordEntry('बड़ी', 89, ['bari']),
    'bade': _WordEntry('बड़े', 88, ['bare']),
    'chhota': _WordEntry('छोटा', 88, ['chota']),
    'chhoti': _WordEntry('छोटी', 87, ['choti']),
    'chhote': _WordEntry('छोटे', 86, ['chote']),

    'naya': _WordEntry('नया', 85, ['nayaa']),
    'nayi': _WordEntry('नयी', 84, ['nayee']),
    'naye': _WordEntry('नये', 83, []),
    'purana': _WordEntry('पुराना', 82, []),
    'purani': _WordEntry('पुरानी', 81, []),
    'purane': _WordEntry('पुराने', 80, []),

    'sundar': _WordEntry('सुंदर', 85, ['sundr']),
    'khubsurat': _WordEntry('खूबसूरत', 82, ['khubsoorat']),

    'theek': _WordEntry('ठीक', 92, ['thik', 'teek']),
    'sahi': _WordEntry('सही', 88, []),
    'galat': _WordEntry('गलत', 85, []),

    'bahut': _WordEntry('बहुत', 95, ['bohot', 'bohut']),
    'zyada': _WordEntry('ज़्यादा', 88, ['jyada', 'zyaada']),
    'kam': _WordEntry('कम', 90, []),
    'thoda': _WordEntry('थोड़ा', 88, ['thora']),
    'thodi': _WordEntry('थोड़ी', 87, ['thori']),
    'thode': _WordEntry('थोड़े', 86, ['thore']),

    'sabse': _WordEntry('सबसे', 85, []),
    'sirf': _WordEntry('सिर्फ', 82, ['sirf']),
    'bilkul': _WordEntry('बिल्कुल', 80, []),
    'zaroor': _WordEntry('ज़रूर', 85, ['jaroor', 'zarur']),
    'shayad': _WordEntry('शायद', 82, []),

    'haan': _WordEntry('हाँ', 98, ['ha', 'haa']),
    'nahi': _WordEntry('नहीं', 98, ['nahin', 'nai']),
    'na': _WordEntry('ना', 95, []),
    'mat': _WordEntry('मत', 90, []),

    // Time words
    'aaj': _WordEntry('आज', 92, ['aj']),
    'kal': _WordEntry('कल', 90, []),
    'parso': _WordEntry('परसों', 78, ['parson']),
    'abhi': _WordEntry('अभी', 88, []),
    'baad': _WordEntry('बाद', 85, ['baad']),
    'pehle': _WordEntry('पहले', 84, ['pahle', 'pahale']),
    'subah': _WordEntry('सुबह', 82, []),
    'dopahar': _WordEntry('दोपहर', 78, []),
    'shaam': _WordEntry('शाम', 80, []),
    'raat': _WordEntry('रात', 82, []),
    'samay': _WordEntry('समय', 75, []),
    'waqt': _WordEntry('वक़्त', 72, ['vaqt']),
    'din': _WordEntry('दिन', 85, []),
    'mahina': _WordEntry('महीना', 75, []),
    'saal': _WordEntry('साल', 80, []),
    'hafta': _WordEntry('हफ़्ता', 75, ['hafta']),

    // Postpositions & Conjunctions
    'men': _WordEntry('में', 95, ['men']),
    'par': _WordEntry('पर', 92, []),
    'se': _WordEntry('से', 95, []),
    'ko': _WordEntry('को', 95, []),
    'ka': _WordEntry('का', 95, []),
    'ki': _WordEntry('की', 95, []),
    'ke': _WordEntry('के', 95, []),
    'aur': _WordEntry('और', 98, ['or']),
    'ya': _WordEntry('या', 92, []),
    'lekin': _WordEntry('लेकिन', 88, ['lakin']),
    'magar': _WordEntry('मगर', 85, []),
    'kyunki': _WordEntry('क्योंकि', 82, ['kyonki']),
    'isliye': _WordEntry('इसलिए', 80, ['islye']),
    'agar': _WordEntry('अगर', 85, []),
    'toh': _WordEntry('तो', 92, ['to']),
    'phir': _WordEntry('फिर', 88, ['fir']),
    'tab': _WordEntry('तब', 85, []),
    'jab': _WordEntry('जब', 85, []),
    'jabtak': _WordEntry('जबतक', 78, []),
    'jaise': _WordEntry('जैसे', 80, []),
    'waise': _WordEntry('वैसे', 78, []),
    'bhi': _WordEntry('भी', 95, []),
    'hi': _WordEntry('ही', 90, []),
    'tak': _WordEntry('तक', 88, []),
    'saath': _WordEntry('साथ', 85, ['sath']),
    'lye': _WordEntry('लिए', 88, ['liye']),
    'wala': _WordEntry('वाला', 85, []),
    'wali': _WordEntry('वाली', 84, []),
    'wale': _WordEntry('वाले', 83, []),

    // Nouns
    'ghar': _WordEntry('घर', 90, []),
    'kaam': _WordEntry('काम', 88, []),
    'paani': _WordEntry('पानी', 88, ['pani']),
    'khna': _WordEntry('खाना', 88, ['khana']),
    'naam': _WordEntry('नाम', 88, ['nam']),
    'jagah': _WordEntry('जगह', 82, []),
    'desh': _WordEntry('देश', 85, []),
    'duniya': _WordEntry('दुनिया', 80, ['dunia']),
    'log': _WordEntry('लोग', 88, []),
    'aadmi': _WordEntry('आदमी', 85, ['admi']),
    'aurat': _WordEntry('औरत', 82, []),
    'ladka': _WordEntry('लड़का', 85, ['ladaka']),
    'ladki': _WordEntry('लड़की', 85, ['ladakee']),
    'baccha': _WordEntry('बच्चा', 82, ['bacha']),
    'bacchi': _WordEntry('बच्ची', 81, ['bachi']),
    'bachche': _WordEntry('बच्चे', 80, ['bache']),
    'dost': _WordEntry('दोस्त', 88, []),
    'pyaar': _WordEntry('प्यार', 85, ['pyar']),
    'zindagi': _WordEntry('ज़िंदगी', 82, ['jindagi', 'zindgi']),
    'dunya': _WordEntry('दुनिया', 80, ['dunya', 'duniya']),
    'sapna': _WordEntry('सपना', 78, []),
    'dil': _WordEntry('दिल', 85, []),
    'mann': _WordEntry('मन', 82, ['man']),
    'baat': _WordEntry('बात', 90, []),
    'sawaal': _WordEntry('सवाल', 82, ['sawal']),
    'jawaab': _WordEntry('जवाब', 82, ['jawab']),
    'matlab': _WordEntry('मतलब', 80, []),
    'fayda': _WordEntry('फ़ायदा', 75, ['faayda', 'faida']),
    'nuksan': _WordEntry('नुकसान', 75, ['nukasaan']),
    'madad': _WordEntry('मदद', 82, []),
    'zaroorat': _WordEntry('ज़रूरत', 78, ['jaroorat']),
    'ijaazat': _WordEntry('इजाज़त', 70, ['ijazat']),
    'mausam': _WordEntry('मौसम', 75, []),
    'paisa': _WordEntry('पैसा', 85, []),
    'dukaan': _WordEntry('दुकान', 78, ['dukan']),
    'school': _WordEntry('स्कूल', 85, ['skool']),
    'college': _WordEntry('कॉलेज', 80, []),
    'office': _WordEntry('ऑफ़िस', 82, []),
    'hospital': _WordEntry('अस्पताल', 78, []),
    'phone': _WordEntry('फ़ोन', 88, ['fon']),
    'computer': _WordEntry('कंप्यूटर', 80, []),
    'internet': _WordEntry('इंटरनेट', 78, []),

    // More common expressions
    'kripya': _WordEntry('कृपया', 85, ['kripaya']),
    'maaf': _WordEntry('माफ़', 82, []),
    'maafi': _WordEntry('माफ़ी', 80, []),
    'sorry': _WordEntry('सॉरी', 85, []),
    'thanks': _WordEntry('थैंक्स', 82, []),
    'please': _WordEntry('प्लीज़', 80, []),
    'welcome': _WordEntry('वेलकम', 78, []),
    'congratulations': _WordEntry('बधाई', 75, []),
    'badhaai': _WordEntry('बधाई', 78, ['badhai']),

    // Numbers as words
    'ek': _WordEntry('एक', 90, []),
    'doo': _WordEntry('दो', 88, ['do']),
    'teen': _WordEntry('तीन', 86, ['tin']),
    'chaar': _WordEntry('चार', 86, ['char']),
    'paanch': _WordEntry('पाँच', 84, ['panch']),
    'chhah': _WordEntry('छह', 82, ['chah']),
    'saat': _WordEntry('सात', 82, []),
    'aath': _WordEntry('आठ', 82, ['ath']),
    'nau': _WordEntry('नौ', 82, []),
    'das': _WordEntry('दस', 82, []),
    'sau': _WordEntry('सौ', 80, []),
    'hazaar': _WordEntry('हज़ार', 78, ['hazar']),
    'lakh': _WordEntry('लाख', 76, []),
    'crore': _WordEntry('करोड़', 74, ['karod']),

    // Days of the week
    'somvaar': _WordEntry('सोमवार', 75, ['somwar']),
    'mangalvaar': _WordEntry('मंगलवार', 74, ['mangalwar']),
    'budhvaar': _WordEntry('बुधवार', 74, ['budhwar']),
    'guruvaar': _WordEntry('गुरुवार', 74, ['guruwar']),
    'shukravaar': _WordEntry('शुक्रवार', 74, ['shukrawar']),
    'shanivaar': _WordEntry('शनिवार', 74, ['shaniwar']),
    'ravivaar': _WordEntry('रविवार', 74, ['raviwar']),

    // Relationships
    'maa': _WordEntry('माँ', 95, ['ma', 'maan']),
    'papa': _WordEntry('पापा', 92, []),
    'pita': _WordEntry('पिता', 88, []),
    'mata': _WordEntry('माता', 88, []),
    'bhai': _WordEntry('भाई', 90, []),
    'behen': _WordEntry('बहन', 88, ['behan']),
    'didi': _WordEntry('दीदी', 85, []),
    'bhaiya': _WordEntry('भैया', 84, ['bhaiyya']),
    'chacha': _WordEntry('चाचा', 80, []),
    'chachi': _WordEntry('चाची', 79, []),
    'mama': _WordEntry('मामा', 80, []),
    'mami': _WordEntry('मामी', 79, []),
    'mausi': _WordEntry('मौसी', 78, []),
    'dada': _WordEntry('दादा', 82, []),
    'dadi': _WordEntry('दादी', 81, []),
    'nana': _WordEntry('नाना', 80, []),
    'nani': _WordEntry('नानी', 79, []),
    'pati': _WordEntry('पति', 85, []),
    'patni': _WordEntry('पत्नी', 84, []),
    'beta': _WordEntry('बेटा', 88, []),
    'beti': _WordEntry('बेटी', 87, []),
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN TRANSLITERATION METHOD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String transliterate(String input) {
    if (input.isEmpty) return '';

    String text = input.trim();

    // Handle multiple words
    List<String> words = text.split(RegExp(r'\s+'));
    List<String> result = [];

    for (String word in words) {
      if (word.isEmpty) continue;
      result.add(_transliterateWord(word));
    }

    return result.join(' ');
  }

  String _transliterateWord(String word) {
    String lowercaseWord = word.toLowerCase();

    // Check dictionary first
    if (_dictionary.containsKey(lowercaseWord)) {
      return _dictionary[lowercaseWord]!.hindi;
    }

    // Check for alternative spellings in dictionary
    for (var entry in _dictionary.entries) {
      if (entry.value.alternatives.contains(lowercaseWord)) {
        return entry.value.hindi;
      }
    }

    // Check conjuncts first
    for (var entry in _conjuncts.entries) {
      if (lowercaseWord == entry.key) {
        return entry.value;
      }
    }

    // Rule-based transliteration
    return _ruleBasedTransliterate(word);
  }

  String _ruleBasedTransliterate(String word) {
    StringBuffer result = StringBuffer();
    int i = 0;
    bool lastWasConsonant = false;
    String? lastConsonant;

    while (i < word.length) {
      // Try to match numbers
      if (_numbers.containsKey(word[i])) {
        result.write(_numbers[word[i]]!);
        i++;
        lastWasConsonant = false;
        continue;
      }

      // Try to match special patterns first
      String? specialMatch = _matchSpecialPattern(word, i);
      if (specialMatch != null) {
        // Check if we need halant before this
        if (lastWasConsonant && lastConsonant != null) {
          // Check if this starts with a vowel
          String nextPart = word.substring(i);
          if (!_startsWithVowel(nextPart)) {
            result.write(_virama);
          }
        }
        result.write(specialMatch);
        i += _getMatchLength(word, i, 'special');
        lastWasConsonant = true;
        continue;
      }

      // Try to match conjuncts
      String? conjunctMatch = _matchConjunct(word, i);
      if (conjunctMatch != null) {
        if (lastWasConsonant) {
          result.write(_virama);
        }
        result.write(conjunctMatch);
        i += _getMatchLength(word, i, 'conjunct');
        lastWasConsonant = true;
        continue;
      }

      // Try to match consonant + vowel combinations
      var (consonant, consonantLen) = _matchConsonant(word, i);
      if (consonant != null) {
        // Add halant if previous was consonant without vowel
        if (lastWasConsonant) {
          result.write(_virama);
        }

        result.write(consonant);
        i += consonantLen;
        lastConsonant = consonant;

        // Now try to match a vowel (matra)
        if (i < word.length) {
          var (matra, matraLen) = _matchMatra(word, i);
          if (matra != null) {
            result.write(matra);
            i += matraLen;
            lastWasConsonant = false;
          } else {
            // Inherent 'a' sound - no matra needed, but mark as consonant
            lastWasConsonant = true;
          }
        } else {
          lastWasConsonant = true;
        }
        continue;
      }

      // Try to match standalone vowel
      var (vowel, vowelLen) = _matchVowel(word, i);
      if (vowel != null) {
        if (lastWasConsonant) {
          // This shouldn't happen with proper parsing, but handle it
          result.write(_virama);
        }
        result.write(vowel);
        i += vowelLen;
        lastWasConsonant = false;
        continue;
      }

      // Handle modifiers
      String? modifier = _matchModifier(word, i);
      if (modifier != null) {
        result.write(modifier);
        i += _getModifierLength(word, i);
        lastWasConsonant = false;
        continue;
      }

      // If nothing matches, just add the character
      result.write(word[i]);
      i++;
      lastWasConsonant = false;
    }

    // Add final halant if word ends with consonant that shouldn't have inherent 'a'
    // (This is a simplification; proper implementation would need more context)

    return result.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER MATCHING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  bool _startsWithVowel(String text) {
    if (text.isEmpty) return false;
    String lower = text.toLowerCase();
    return lower.startsWith('a') ||
        lower.startsWith('e') ||
        lower.startsWith('i') ||
        lower.startsWith('o') ||
        lower.startsWith('u');
  }

  String? _matchSpecialPattern(String word, int start) {
    // Handle special cases like chandrabindu, anusvara, visarga
    if (start + 1 < word.length) {
      String twoChar = word.substring(start, start + 2).toLowerCase();
      if (twoChar == 'an' || twoChar == 'am') {
        // Check if followed by consonant (nasalization)
        if (start + 2 >= word.length || !_isVowel(word[start + 2])) {
          return null; // Let it be handled as regular syllable
        }
      }
    }
    return null;
  }

  String? _matchConjunct(String word, int start) {
    // Try longer matches first
    for (int len = 5; len >= 2; len--) {
      if (start + len <= word.length) {
        String substr = word.substring(start, start + len).toLowerCase();
        if (_conjuncts.containsKey(substr)) {
          return _conjuncts[substr];
        }
      }
    }
    return null;
  }

  (String?, int) _matchConsonant(String word, int start) {
    // Try longer matches first (3, 2, 1 characters)
    for (int len = 3; len >= 1; len--) {
      if (start + len <= word.length) {
        String substr = word.substring(start, start + len);
        // Preserve case for retroflex consonants
        if (_consonants.containsKey(substr)) {
          return (_consonants[substr], len);
        }
        // Also try lowercase
        if (_consonants.containsKey(substr.toLowerCase())) {
          return (_consonants[substr.toLowerCase()], len);
        }
      }
    }
    return (null, 0);
  }

  (String?, int) _matchMatra(String word, int start) {
    // Try longer matches first
    for (int len = 2; len >= 1; len--) {
      if (start + len <= word.length) {
        String substr = word.substring(start, start + len);
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
    // Try longer matches first
    for (int len = 2; len >= 1; len--) {
      if (start + len <= word.length) {
        String substr = word.substring(start, start + len);
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

  String? _matchModifier(String word, int start) {
    if (start >= word.length) return null;

    // Check for chandrabindu (nasal marker)
    if (start + 1 < word.length) {
      String twoChar = word.substring(start, start + 2).toLowerCase();
      if (twoChar == 'n~' || twoChar == 'm~') {
        return _chandrabindu;
      }
    }

    // Check for anusvara
    if (word[start].toLowerCase() == 'n' || word[start].toLowerCase() == 'm') {
      if (start + 1 >= word.length) {
        return _anusvara;
      }
      // Check if followed by consonant
      if (start + 1 < word.length && !_isVowel(word[start + 1])) {
        var (nextConsonant, _) = _matchConsonant(word, start + 1);
        if (nextConsonant != null) {
          return _anusvara;
        }
      }
    }

    // Check for visarga
    if (word[start].toLowerCase() == 'h' && start + 1 >= word.length) {
      // Trailing 'h' could be visarga in some contexts
      // But usually we want it as 'ह', so skip this
    }

    return null;
  }

  int _getMatchLength(String word, int start, String type) {
    if (type == 'conjunct') {
      for (int len = 5; len >= 2; len--) {
        if (start + len <= word.length) {
          String substr = word.substring(start, start + len).toLowerCase();
          if (_conjuncts.containsKey(substr)) {
            return len;
          }
        }
      }
    }
    return 1;
  }

  int _getModifierLength(String word, int start) {
    if (start + 1 < word.length) {
      String twoChar = word.substring(start, start + 2).toLowerCase();
      if (twoChar == 'n~' || twoChar == 'm~') {
        return 2;
      }
    }
    return 1;
  }

  bool _isVowel(String char) {
    return 'aeiouAEIOU'.contains(char);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART SUGGESTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  List<String> getSuggestions(String input, {int limit = 5}) {
    if (input.isEmpty) return [];

    String lastWord = input.split(RegExp(r'\s+')).last.toLowerCase();
    if (lastWord.isEmpty) return [];

    List<_ScoredSuggestion> scoredSuggestions = [];

    // 1. Exact prefix matches from dictionary
    for (var entry in _dictionary.entries) {
      if (entry.key.startsWith(lastWord) && entry.key != lastWord) {
        scoredSuggestions.add(
          _ScoredSuggestion(
            entry.key,
            entry.value.hindi,
            entry.value.frequency + 100, // Boost for prefix match
          ),
        );
      }

      // Also check alternatives
      for (String alt in entry.value.alternatives) {
        if (alt.startsWith(lastWord) && alt != lastWord) {
          scoredSuggestions.add(
            _ScoredSuggestion(
              entry.key, // Use main word
              entry.value.hindi,
              entry.value.frequency + 50, // Slightly lower boost for alt match
            ),
          );
        }
      }
    }

    // 2. Fuzzy matches (for typos)
    if (scoredSuggestions.length < limit) {
      for (var entry in _dictionary.entries) {
        // Skip if already added
        if (scoredSuggestions.any((s) => s.english == entry.key)) continue;

        int distance = _levenshteinDistance(lastWord, entry.key);
        // Allow 1 edit for short words, 2 for longer
        int maxDistance = lastWord.length <= 4 ? 1 : 2;

        if (distance <= maxDistance && distance > 0) {
          scoredSuggestions.add(
            _ScoredSuggestion(
              entry.key,
              entry.value.hindi,
              entry.value.frequency - (distance * 20), // Penalize by distance
            ),
          );
        }
      }
    }

    // 3. Generate on-the-fly suggestion (what the user is typing)
    String currentTransliteration = transliterate(lastWord);
    if (currentTransliteration.isNotEmpty &&
        !scoredSuggestions.any((s) => s.hindi == currentTransliteration)) {
      scoredSuggestions.add(
        _ScoredSuggestion(
          lastWord,
          currentTransliteration,
          50, // Medium priority
        ),
      );
    }

    // Sort by score and return
    scoredSuggestions.sort((a, b) => b.score.compareTo(a.score));

    // Remove duplicates and limit
    Set<String> seen = {};
    List<String> result = [];
    for (var suggestion in scoredSuggestions) {
      if (!seen.contains(suggestion.hindi) && result.length < limit) {
        seen.add(suggestion.hindi);
        result.add(suggestion.english);
      }
    }

    return result;
  }

  // Levenshtein distance for fuzzy matching
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> dp = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // deletion
          dp[i][j - 1] + 1, // insertion
          dp[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[s1.length][s2.length];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class _WordEntry {
  final String hindi;
  final int frequency;
  final List<String> alternatives;

  const _WordEntry(this.hindi, this.frequency, this.alternatives);
}

class _ScoredSuggestion {
  final String english;
  final String hindi;
  final int score;

  _ScoredSuggestion(this.english, this.hindi, this.score);
}
