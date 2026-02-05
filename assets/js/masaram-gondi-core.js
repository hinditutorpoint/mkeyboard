/**
 * Masaram Gondi Direct Typing Plugin
 * v5.7.0 - Complete Rewrite with All Fixes
 * 
 * Core Transliteration Engine
 * 
 * @author Rajesh Kumar Dhuriya
 * @license MIT
 */

(function ($) {
    'use strict';

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS - UNICODE CHARACTERS
    // ═══════════════════════════════════════════════════════════════════════════

    const MARKS = {
        halanta: '𑵄',        // U+11D44 - Final consonant
        virama: '𑵅',         // U+11D45 - Conjunct marker
        anusvara: '𑵀',       // U+11D40 - Nasalization
        visarga: '𑵁',        // U+11D41 - Aspiration
        sukun: '𑵂',          // U+11D42 - Nukta
        chandrabindu: '𑵃',   // U+11D43 - Chandrabindu
        repha: '𑵆',          // U+11D46 - Repha
        rakar: '𑵇'           // U+11D47 - Rakar
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // ENGLISH (ITRANS) TO GONDI MAPPINGS
    // ═══════════════════════════════════════════════════════════════════════════

    const EN_VOWELS = {
        'a': '𑴀',
        'aa': '𑴁', 'A': '𑴁', 'ā': '𑴁',
        'i': '𑴂',
        'ii': '𑴃', 'I': '𑴃', 'ī': '𑴃', 'ee': '𑴃',
        'u': '𑴄',
        'uu': '𑴅', 'U': '𑴅', 'ū': '𑴅', 'oo': '𑴅',
        'RRi': '𑴇', 'R^i': '𑴇', 'Ri': '𑴇', '.r': '𑴇', 'ṛ': '𑴇',
        'RRI': '𑴇', 'R^I': '𑴇',
        'e': '𑴆', 'E': '𑴆', 'ē': '𑴆',
        'ai': '𑴈', 'aI': '𑴈', 'ei': '𑴈',
        'o': '𑴉', 'O': '𑴉', 'ō': '𑴉',
        'au': '𑴋', 'aU': '𑴋', 'ou': '𑴋'
    };

    const EN_MATRAS = {
        'aa': '𑴱', 'A': '𑴱', 'ā': '𑴱',
        'i': '𑴲',
        'ii': '𑴳', 'I': '𑴳', 'ī': '𑴳', 'ee': '𑴳',
        'u': '𑴴',
        'uu': '𑴵', 'U': '𑴵', 'ū': '𑴵', 'oo': '𑴵',
        'e': '𑴺', 'ē': '𑴺',
        'ai': '𑴼', 'aI': '𑴼', 'ei': '𑴼',
        'o': '𑴽', 'ō': '𑴽',
        'au': '𑴿', 'aU': '𑴿', 'ou': '𑴿',
        'RRi': '𑴶', 'R^i': '𑴶', 'Ri': '𑴶',
        'RRI': '𑴶', 'R^I': '𑴶', '.r': '𑴶', 'ṛ': '𑴶'
    };

    const EN_CONSONANTS = {
        // Velars
        'k': '𑴌', 'kh': '𑴍', 'K': '𑴍',
        'g': '𑴎', 'gh': '𑴏', 'G': '𑴏',
        'ng': '𑴐', '~N': '𑴐', 'N^': '𑴐', 'F': '𑴐', 'ṅ': '𑴐',
        // Palatals
        'ch': '𑴑', 'c': '𑴑',
        'chh': '𑴒', 'Ch': '𑴒', 'C': '𑴒',
        'j': '𑴓', 'jh': '𑴔', 'J': '𑴔',
        'ny': '𑴕', '~n': '𑴕', 'JN': '𑴕', 'Y': '𑴕', 'ñ': '𑴕',
        // Retroflexes
        'T': '𑴖', 'ṭ': '𑴖', 'Th': '𑴗', 'ṭh': '𑴗',
        'D': '𑴘', 'ḍ': '𑴘', 'Dh': '𑴙', 'ḍh': '𑴙',
        'N': '𑴚', 'ṇ': '𑴚',
        // Dentals
        't': '𑴛', 'th': '𑴜', 'd': '𑴝', 'dh': '𑴞', 'n': '𑴟',
        // Labials
        'p': '𑴠', 'ph': '𑴡', 'P': '𑴡',
        'b': '𑴢', 'bh': '𑴣', 'B': '𑴣', 'm': '𑴤',
        // Semivowels
        'y': '𑴥', 'r': '𑴦', 'l': '𑴧', 'L': '𑴭', 'ḷ': '𑴭',
        'v': '𑴨', 'w': '𑴨',
        // Sibilants
        'sh': '𑴩', 'ś': '𑴩',
        'Sh': '𑴪', 'S': '𑴪', 'shh': '𑴪', 'ṣ': '𑴪',
        's': '𑴫', 'h': '𑴬',
        // Special conjuncts
        'x': '𑴮', 'GY': '𑴯', 'dny': '𑴯', 'jny': '𑴯', 'X': '𑴯', 'Z': '𑴰',
        // Nukta
        'q': '𑴌' + MARKS.sukun,
        'z': '𑴓' + MARKS.sukun,
        'f': '𑴡' + MARKS.sukun,
        '.D': '𑴘' + MARKS.sukun,
        '.Dh': '𑴙' + MARKS.sukun
    };

    const EN_NUMBERS = {
        '0': '𑵐', '1': '𑵑', '2': '𑵒', '3': '𑵓', '4': '𑵔',
        '5': '𑵕', '6': '𑵖', '7': '𑵗', '8': '𑵘', '9': '𑵙'
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // HINDI (DEVANAGARI) TO GONDI MAPPINGS - COMPLETE
    // ═══════════════════════════════════════════════════════════════════════════

    const HI_VOWELS = {
        'अ': '𑴀', 'आ': '𑴁', 'इ': '𑴂', 'ई': '𑴃',
        'उ': '𑴄', 'ऊ': '𑴅', 'ऋ': '𑴇', 'ॠ': '𑴇',
        'ऌ': '𑴧', 'ॡ': '𑴧',
        'ए': '𑴆', 'ऐ': '𑴈', 'ओ': '𑴉', 'औ': '𑴋',
        'ऑ': '𑴉'  // For English loanwords
    };

    const HI_MATRAS = {
        'ा': '𑴱',   // aa
        'ि': '𑴲',   // i
        'ी': '𑴳',   // ii
        'ु': '𑴴',   // u
        'ू': '𑴵',   // uu
        'ृ': '𑴶',   // ri
        'ॄ': '𑴶',   // rii
        'ॢ': '𑴧',   // li
        'ॣ': '𑴧',   // lii
        'े': '𑴺',   // e
        'ै': '𑴼',   // ai
        'ो': '𑴽',   // o
        'ौ': '𑴿',   // au
        'ॉ': '𑴽'    // For English loanwords
    };

    const HI_CONSONANTS = {
        // Velars
        'क': '𑴌', 'ख': '𑴍', 'ग': '𑴎', 'घ': '𑴏', 'ङ': '𑴐',
        // Palatals
        'च': '𑴑', 'छ': '𑴒', 'ज': '𑴓', 'झ': '𑴔', 'ञ': '𑴕',
        // Retroflexes
        'ट': '𑴖', 'ठ': '𑴗', 'ड': '𑴘', 'ढ': '𑴙', 'ण': '𑴚',
        // Dentals
        'त': '𑴛', 'थ': '𑴜', 'द': '𑴝', 'ध': '𑴞', 'न': '𑴟',
        // Labials
        'प': '𑴠', 'फ': '𑴡', 'ब': '𑴢', 'भ': '𑴣', 'म': '𑴤',
        // Semivowels
        'य': '𑴥', 'र': '𑴦', 'ल': '𑴧', 'ळ': '𑴭', 'व': '𑴨',
        // Sibilants
        'श': '𑴩', 'ष': '𑴪', 'स': '𑴫', 'ह': '𑴬',
        // Nukta consonants
        'क़': '𑴌' + MARKS.sukun,
        'ख़': '𑴍' + MARKS.sukun,
        'ग़': '𑴎' + MARKS.sukun,
        'ज़': '𑴓' + MARKS.sukun,
        'ड़': '𑴘' + MARKS.sukun,
        'ढ़': '𑴙' + MARKS.sukun,
        'फ़': '𑴡' + MARKS.sukun,
        'य़': '𑴥' + MARKS.sukun,
        'ऱ': '𑴦' + MARKS.sukun,
        'ऴ': '𑴭' + MARKS.sukun
    };

    const HI_NUMBERS = {
        '०': '𑵐', '१': '𑵑', '२': '𑵒', '३': '𑵓', '४': '𑵔',
        '५': '𑵕', '६': '𑵖', '७': '𑵗', '८': '𑵘', '९': '𑵙'
    };

    const HI_MARKS = {
        '्': MARKS.virama,      // Virama/Halant
        'ं': MARKS.anusvara,    // Anusvara
        'ः': MARKS.visarga,     // Visarga
        'ँ': MARKS.chandrabindu, // Chandrabindu
        '़': MARKS.sukun,        // Nukta
        'ऽ': '',                 // Avagraha (skip)
        '॰': '.',                // Abbreviation
        '।': '।',                // Danda
        '॥': '॥'                 // Double Danda
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // GONDI TO IPA MAPPINGS
    // ═══════════════════════════════════════════════════════════════════════════

    const GONDI_TO_IPA = {
        // Vowels
        '𑴀': 'a',      // a
        '𑴁': 'aː',     // aa
        '𑴂': 'i',      // i
        '𑴃': 'iː',     // ii
        '𑴄': 'u',      // u
        '𑴅': 'uː',     // uu
        '𑴇': 'r̩',     // ri
        '𑴆': 'e',      // e
        '𑴈': 'ai',     // ai
        '𑴉': 'o',      // o
        '𑴋': 'au',     // au

        // Consonants (with implicit 'a')
        '𑴌': 'ka',     // ka
        '𑴍': 'kʰa',    // kha
        '𑴎': 'ga',     // ga
        '𑴏': 'gʰa',    // gha
        '𑴐': 'ŋa',     // nga
        '𑴑': 'tʃa',    // ca
        '𑴒': 'tʃʰa',    // cha
        '𑴓': 'dʒa',    // ja
        '𑴔': 'dʒʰa',    // jha
        '𑴕': 'ɲa',     // nya
        '𑴖': 'ʈa',     // tta
        '𑴗': 'ʈʰa',    // ttha
        '𑴘': 'ɖa',     // dda
        '𑴙': 'ɖʰa',    // ddha
        '𑴚': 'ɳa',     // nna
        '𑴛': 'ta',     // ta
        '𑴜': 'tʰa',    // tha
        '𑴝': 'da',     // da
        '𑴞': 'dʰa',    // dha
        '𑴟': 'na',     // na
        '𑴠': 'pa',     // pa
        '𑴡': 'pʰa',    // pha
        '𑴢': 'ba',     // ba
        '𑴣': 'bʰa',    // bha
        '𑴤': 'ma',     // ma
        '𑴥': 'ja',     // ya
        '𑴦': 'ra',     // ra
        '𑴧': 'la',     // la
        '𑴨': 'ʋa',     // va
        '𑴩': 'ʃa',     // sha
        '𑴪': 'ʂa',     // ssa
        '𑴫': 'sa',     // sa
        '𑴬': 'ha',     // ha

        // Special consonants with nukta (with implicit 'a')
        '𑴌𑵂': 'qa',     // qa (k + nukta)
        '𑴓𑵂': 'za',     // za (j + nukta)
        '𑴡𑵂': 'fa',     // fa (ph + nukta)
        '𑴘𑵂': 'ɽa',     // rra (dd + nukta)
        '𑴙𑵂': 'ɽʰa',    // rrha (ddh + nukta)

        // Special conjuncts (with implicit 'a')
        '𑴮': 'ksa',     // ksha
        '𑴯': 'dʒɲa',    // jnya
        '𑴰': 'dʒa',     // dza

        // Marks
        '𑵄': '',       // halanta (no sound, removes implicit 'a')
        '𑵅': '',       // virama (no sound)
        '𑵀': 'ŋ',      // anusvara
        '𑵁': 'h',      // visarga
        '𑵂': '',       // nukta (modifies consonant)
        '𑵃': '̃',       // chandrabindu (nasalization)
        '𑵆': 'r',      // repha
        '𑵇': 'r',      // rakar

        // Matras (vowel signs, replace implicit 'a')
        '𑴱': 'aː',     // aa
        '𑴲': 'i',      // i
        '𑴳': 'iː',     // ii
        '𑴴': 'u',      // u
        '𑴵': 'uː',     // uu
        '𑴶': 'r̩',     // ri
        '𑴺': 'e',      // e
        '𑴼': 'ai',     // ai
        '𑴽': 'o',      // o
        '𑴿': 'au',     // au

        // Numbers (keep as is)
        '𑵐': '0', '𑵑': '1', '𑵒': '2', '𑵓': '3', '𑵔': '4',
        '𑵕': '5', '𑵖': '6', '𑵗': '7', '𑵘': '8', '𑵙': '9'
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // DEFAULT SUGGESTIONS DATA
    // ═══════════════════════════════════════════════════════════════════════════

    const DEFAULT_SUGGESTIONS = {
        // Greetings
        'namaste': 'नमस्ते',
        'namaskara': 'नमस्कार',
        'pranama': 'प्रणाम',

        // Common words
        'dhanyavaada': 'धन्यवाद',
        'shukriyaa': 'शुक्रिया',
        'aapa': 'आप',
        'tuma': 'तुम',
        'main': 'मैं',
        'huma': 'हम',
        'vaha': 'वह',
        'yaha': 'यह',

        // Question words
        'kya': 'क्या',
        'kaise': 'कैसे',
        'kaba': 'कब',
        'kahan': 'कहाँ',
        'kauna': 'कौन',
        'kyuna': 'क्यों',

        // Verbs
        'hai': 'है',
        'hain': 'हैं',
        'tha': 'था',
        'thi': 'थी',
        'the': 'थे',
        'hogaa': 'होगा',
        'karnaa': 'करना',
        'jaanaa': 'जाना',
        'aanaa': 'आना',
        'khanaa': 'खाना',
        'peenaa': 'पीना',
        'sonaa': 'सोना',
        'uthnaa': 'उठना',

        // Adjectives
        'acchaa': 'अच्छा',
        'buraa': 'बुरा',
        'badaa': 'बड़ा',
        'chhotaa': 'छोटा',
        'nayaa': 'नया',
        'puranaa': 'पुराना',

        // Nouns
        'ghara': 'घर',
        'paani': 'पानी',
        'khaanaa': 'खाना',
        'naama': 'नाम',
        'kaama': 'काम',
        'dina': 'दिन',
        'raata': 'रात',

        // Numbers
        'eka': 'एक',
        'do': 'दो',
        'teena': 'तीन',
        'chaara': 'चार',
        'paancha': 'पाँच',

        // Gondi specific
        'gondi': 'गोंडी',
        'gondwana': 'गोंडवाना',
        'masarama': 'मसाराम',
        'rajesha': 'राजेश',
        'kumara': 'कुमार',
        'dhuriyaa': 'धुरिया',
        'dhurveyaa': 'धुर्व्या',
        'marko': 'मार्को',
        'akkii': 'अक्की',
        'aMge': 'अंगे',
        'aadhaara': 'आधार',
        'siMha': 'सिंह',
        'kumare': 'कुमरे',
        'sevaa': 'सेवा',
        'johaara': 'जोहार',
        'jaya': 'जय',
        'sevaa': 'सेवा',
        'kunjaama': 'कुंजाम',
        'wadiwaa': 'वडीवा',
        'haMshraaj': 'हंशराज',
        'daadaa': 'दादा',
        'dayee': 'दायी',
        'dayii': 'दाई',
        'motiiraavana': 'मोतीरावन',
        'kangaali': 'कंगाली',
        'heeraalaala': 'हीरालाल',
        'kusharaama': 'कुशराम',
        'mandalaa': 'मंडला',
        'mangaa': 'मंगा',
        'mayajuu': 'मयजू',
        'miyaaDa': 'मियड़',
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // KEYBOARD LAYOUTS
    // ═══════════════════════════════════════════════════════════════════════════

    const KEYBOARD_LAYOUTS = {
        itrans: {
            name: 'ITRANS (English)',
            rows: [
                { keys: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'], class: 'number-row' },
                { keys: ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'], class: 'top-row' },
                { keys: ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'], class: 'home-row' },
                { keys: ['z', 'x', 'c', 'v', 'b', 'n', 'm'], class: 'bottom-row' }
            ],
            shiftMap: {
                'a': 'A', 'i': 'I', 'u': 'U', 'e': 'E', 'o': 'O',
                'n': 'N', 'd': 'D', 't': 'T', 's': 'S', 'h': 'H',
                'k': 'K', 'g': 'G', 'c': 'C', 'j': 'J', 'p': 'P', 'b': 'B',
                'l': 'L', 'r': 'R', 'm': 'M', 'y': 'Y'
            }
        },
        hindi: {
            name: 'Hindi (हिंदी)',
            rows: [
                { keys: ['१', '२', '३', '४', '५', '६', '७', '८', '९', '०'], class: 'number-row' },
                { keys: ['क', 'ख', 'ग', 'घ', 'ङ', 'च', 'छ', 'ज', 'झ', 'ञ'], class: 'top-row' },
                { keys: ['ट', 'ठ', 'ड', 'ढ', 'ण', 'त', 'थ', 'द', 'ध', 'न'], class: 'middle-row' },
                { keys: ['प', 'फ', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श'], class: 'home-row' },
                { keys: ['ष', 'स', 'ह', 'क्ष', 'त्र', 'ज्ञ', 'श्र'], class: 'bottom-row' }
            ],
            vowels: ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ऋ', 'ए', 'ऐ', 'ओ', 'औ'],
            matras: ['ा', 'ि', 'ी', 'ु', 'ू', 'ृ', 'े', 'ै', 'ो', 'ौ', '्', 'ं', 'ः']
        },
        gondi: {
            name: 'Gondi (𑴦𑴺𑴎𑴲)',
            rows: [
                { keys: ['𑵐', '𑵑', '𑵒', '𑵓', '𑵔', '𑵕', '𑵖', '𑵗', '𑵘', '𑵙'], class: 'number-row' },
                { keys: ['𑴌', '𑴍', '𑴎', '𑴏', '𑴐', '𑴑', '𑴒', '𑴓', '𑴔', '𑴕'], class: 'top-row' },
                { keys: ['𑴖', '𑴗', '𑴘', '𑴙', '𑴚', '𑴛', '𑴜', '𑴝', '𑴞', '𑴟'], class: 'middle-row' },
                { keys: ['𑴠', '𑴡', '𑴢', '𑴣', '𑴤', '𑴥', '𑴦', '𑴧', '𑴨', '𑴭'], class: 'home-row' },
                { keys: ['𑴩', '𑴪', '𑴫', '𑴬', '𑴮', '𑴯', '𑴰'], class: 'bottom-row' }
            ],
            vowels: ['𑴀', '𑴁', '𑴂', '𑴃', '𑴄', '𑴅', '𑴇', '𑴆', '𑴈', '𑴉', '𑴋'],
            matras: ['𑴱', '𑴲', '𑴳', '𑴴', '𑴵', '𑴶', '𑴺', '𑴼', '𑴽', '𑴿'],
            marks: ['𑵅', '𑵄', '𑵀', '𑵁', '𑵃', '𑵆', '𑵇']
        }
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Match longest sequence from map
     */
    function matchFromMap(word, start, map, maxLen) {
        maxLen = maxLen || 4;
        for (let len = Math.min(maxLen, word.length - start); len >= 1; len--) {
            const substr = word.substring(start, start + len);
            if (map[substr] !== undefined) {
                return [map[substr], len];
            }
        }
        return [null, 0];
    }

    /**
     * Check if position has consonant
     */
    function isConsonantAt(word, pos) {
        if (pos >= word.length) return false;
        for (let len = 4; len >= 1; len--) {
            if (pos + len <= word.length) {
                const substr = word.substring(pos, pos + len);
                if (EN_CONSONANTS[substr]) return true;
            }
        }
        return false;
    }

    /**
     * Check for Repha (र् before consonant)
     */
    function isRepha(word, pos, hasVowel) {
        if (pos >= word.length || word[pos] !== 'r' || !hasVowel) return false;
        return pos + 1 < word.length && isConsonantAt(word, pos + 1);
    }

    /**
     * Check for Rakar (्र after consonant)
     */
    function isRakar(word, pos, hasConsonant, hasVowel) {
        return pos < word.length && word[pos] === 'r' && hasConsonant && !hasVowel;
    }

    /**
     * Check for Vocalic R (uppercase R patterns)
     */
    function isVocalicR(word, pos) {
        if (pos >= word.length) return false;
        const r = word.substring(pos);
        if (r[0] !== 'R' && !r.startsWith('.r') && r[0] !== 'ṛ') return false;
        return r.startsWith('R^i') || r.startsWith('R^I') ||
            r.startsWith('RRi') || r.startsWith('RRI') ||
            r.startsWith('Ri') || r.startsWith('.r') || r[0] === 'ṛ';
    }

    /**
     * Get Vocalic R length
     */
    function getVocalicRLength(word, pos) {
        const r = word.substring(pos);
        if (r.startsWith('R^i') || r.startsWith('R^I') ||
            r.startsWith('RRi') || r.startsWith('RRI')) return 3;
        if (r.startsWith('Ri') || r.startsWith('.r')) return 2;
        if (r[0] === 'ṛ') return 1;
        return 0;
    }

    /**
     * Check if character is Hindi
     */
    function isHindiChar(char) {
        const code = char.charCodeAt(0);
        return (code >= 0x0900 && code <= 0x097F) || // Devanagari
            (code >= 0xA8E0 && code <= 0xA8FF);   // Devanagari Extended
    }

    /**
     * Check if text contains Hindi
     */
    function containsHindi(text) {
        for (let i = 0; i < text.length; i++) {
            if (isHindiChar(text[i])) return true;
        }
        return false;
    }

    /**
     * Debounce utility
     */
    function debounce(func, wait) {
        let timeout;
        return function (...args) {
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(this, args), wait);
        };
    }

    /**
     * Storage helper with fallback
     */
    const Storage = {
        prefix: 'mgd_',

        set: function (key, value) {
            try {
                localStorage.setItem(this.prefix + key, JSON.stringify(value));
                return true;
            } catch (e) {
                console.warn('MasaramGondi: localStorage not available');
                return false;
            }
        },

        get: function (key, defaultValue) {
            try {
                const item = localStorage.getItem(this.prefix + key);
                return item ? JSON.parse(item) : defaultValue;
            } catch (e) {
                return defaultValue;
            }
        },

        remove: function (key) {
            try {
                localStorage.removeItem(this.prefix + key);
            } catch (e) { }
        }
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // ENGLISH TO GONDI TRANSLITERATION
    // ═══════════════════════════════════════════════════════════════════════════

    function englishToGondi(word) {
        if (!word) return '';

        let buffer = '';
        let i = 0;
        let hasConsonant = false;
        let hasVowel = false;

        while (i < word.length) {
            const char = word[i];
            const remaining = word.substring(i);

            // Numbers
            if (EN_NUMBERS[char]) {
                if (hasConsonant && !hasVowel) buffer += MARKS.halanta;
                buffer += EN_NUMBERS[char];
                hasConsonant = false;
                hasVowel = false;
                i++;
                continue;
            }

            // Punctuation (not special patterns)
            if (char === '.' && !remaining.startsWith('.r') && !remaining.startsWith('.D') &&
                !remaining.startsWith('.n') && !remaining.startsWith('.m') &&
                !remaining.startsWith('.h') && !remaining.startsWith('.N')) {
                if (hasConsonant && !hasVowel) buffer += MARKS.halanta;
                let dotCount = 1;
                while (i + dotCount < word.length && word[i + dotCount] === '.') dotCount++;
                buffer += dotCount >= 2 ? '॥' : '।';
                i += dotCount >= 2 ? Math.min(dotCount, 3) : 1;
                hasConsonant = false;
                hasVowel = false;
                continue;
            }

            // Whitespace
            if (char === ' ' || char === '\n' || char === '\t') {
                if (hasConsonant && !hasVowel) buffer += MARKS.halanta;
                buffer += char;
                hasConsonant = false;
                hasVowel = false;
                i++;
                continue;
            }

            // Chandrabindu
            if (remaining.startsWith('.N') || remaining.startsWith('MM')) {
                buffer += MARKS.chandrabindu;
                i += 2;
                continue;
            }

            // Anusvara
            if (remaining.startsWith('.n') || remaining.startsWith('.m')) {
                buffer += MARKS.anusvara;
                i += 2;
                continue;
            }

            if ((char === 'M' && hasVowel) || char === 'ṃ' || char === 'ṁ') {
                buffer += MARKS.anusvara;
                hasConsonant = false;
                hasVowel = false;
                i++;
                continue;
            }

            // Visarga
            if (remaining.startsWith('.h')) {
                buffer += MARKS.visarga;
                i += 2;
                continue;
            }

            if ((char === 'H' && hasVowel) || char === 'ḥ') {
                buffer += MARKS.visarga;
                hasConsonant = false;
                hasVowel = false;
                i++;
                continue;
            }

            // Repha
            if (isRepha(word, i, hasVowel)) {
                buffer += MARKS.repha;
                hasConsonant = false;
                hasVowel = false;
                i++;
                continue;
            }

            // Rakar
            if (isRakar(word, i, hasConsonant, hasVowel)) {
                const nextPos = i + 1;
                if (nextPos < word.length) {
                    const afterR = word.substring(nextPos);

                    // Check 'ra' combinations
                    if (afterR[0] === 'a') {
                        const afterA = nextPos + 1;
                        if (afterA < word.length) {
                            const afterAChar = word[afterA];
                            if (afterAChar === 'a' || afterAChar === 'A') {
                                buffer += MARKS.rakar + EN_MATRAS['aa'];
                                i = afterA + 1;
                                hasVowel = true;
                                hasConsonant = false;
                                continue;
                            }
                            if (afterAChar === 'i' || afterAChar === 'I') {
                                buffer += MARKS.rakar + EN_MATRAS['ai'];
                                i = afterA + 1;
                                hasVowel = true;
                                hasConsonant = false;
                                continue;
                            }
                            if (afterAChar === 'u' || afterAChar === 'U') {
                                buffer += MARKS.rakar + EN_MATRAS['au'];
                                i = afterA + 1;
                                hasVowel = true;
                                hasConsonant = false;
                                continue;
                            }
                        }
                        buffer += MARKS.rakar;
                        i = nextPos + 1;
                        hasVowel = true;
                        hasConsonant = false;
                        continue;
                    }

                    // Other matras after r
                    const [matra, matraLen] = matchFromMap(word, nextPos, EN_MATRAS, 4);
                    if (matra) {
                        buffer += MARKS.rakar + matra;
                        i = nextPos + matraLen;
                        hasVowel = true;
                        hasConsonant = false;
                        continue;
                    }

                    // r before consonant = conjunct
                    if (isConsonantAt(word, nextPos)) {
                        buffer += MARKS.virama + EN_CONSONANTS['r'];
                        i++;
                        hasConsonant = true;
                        hasVowel = false;
                        continue;
                    }
                }

                buffer += MARKS.rakar;
                i++;
                hasVowel = true;
                hasConsonant = false;
                continue;
            }

            // Consonants
            const [consonant, consLen] = matchFromMap(word, i, EN_CONSONANTS, 4);
            if (consonant) {
                if (hasConsonant && !hasVowel) buffer += MARKS.virama;
                buffer += consonant;
                i += consLen;
                hasConsonant = true;
                hasVowel = false;

                if (i < word.length) {
                    // Vocalic R
                    if (isVocalicR(word, i)) {
                        buffer += EN_MATRAS['RRi'];
                        i += getVocalicRLength(word, i);
                        hasVowel = true;
                        continue;
                    }

                    // Check 'a' and combinations
                    if (word[i] === 'a') {
                        const afterA = i + 1;
                        if (afterA < word.length) {
                            const afterAChar = word[afterA];
                            if (afterAChar === 'a' || afterAChar === 'A') {
                                buffer += EN_MATRAS['aa'];
                                i = afterA + 1;
                                hasVowel = true;
                                continue;
                            }
                            if (afterAChar === 'i' || afterAChar === 'I') {
                                buffer += EN_MATRAS['ai'];
                                i = afterA + 1;
                                hasVowel = true;
                                continue;
                            }
                            if (afterAChar === 'u' || afterAChar === 'U') {
                                buffer += EN_MATRAS['au'];
                                i = afterA + 1;
                                hasVowel = true;
                                continue;
                            }
                        }
                        i++;
                        hasVowel = true;
                        continue;
                    }

                    // Other matras (not 'r' - handled as rakar)
                    if (word[i] !== 'r') {
                        const [matra, matraLen] = matchFromMap(word, i, EN_MATRAS, 4);
                        if (matra) {
                            buffer += matra;
                            i += matraLen;
                            hasVowel = true;
                            continue;
                        }
                    }
                }
                continue;
            }

            // Independent vowels
            if (!hasConsonant || hasVowel) {
                const [vowel, vowelLen] = matchFromMap(word, i, EN_VOWELS, 4);
                if (vowel) {
                    if (hasConsonant && !hasVowel) buffer += MARKS.halanta;
                    buffer += vowel;
                    i += vowelLen;
                    hasConsonant = false;
                    hasVowel = true;
                    continue;
                }
            }

            // Skip special chars
            if (char === '^' || char === '~') {
                i++;
                continue;
            }

            // Pass through unrecognized
            if (hasConsonant && !hasVowel) buffer += MARKS.halanta;
            buffer += char;
            hasConsonant = false;
            hasVowel = false;
            i++;
        }

        // Final halanta
        if (hasConsonant && !hasVowel) buffer += MARKS.halanta;

        return buffer;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HINDI TO GONDI TRANSLITERATION - COMPLETE REWRITE
    // ═══════════════════════════════════════════════════════════════════════════

    function hindiToGondi(text) {
        if (!text) return '';

        let result = '';
        let i = 0;

        while (i < text.length) {
            const char = text[i];
            const next = i + 1 < text.length ? text[i + 1] : '';
            const nextNext = i + 2 < text.length ? text[i + 2] : '';

            // ─────────────────────────────────────────────────────────────
            // NUKTA COMBINATIONS (check first)
            // ─────────────────────────────────────────────────────────────
            if (next === '़') {
                const combined = char + '़';
                if (HI_CONSONANTS[combined]) {
                    result += HI_CONSONANTS[combined];
                    i += 2;
                    continue;
                }
            }

            // ─────────────────────────────────────────────────────────────
            // SPECIAL CONJUNCTS (क्ष, त्र, ज्ञ, श्र)
            // ─────────────────────────────────────────────────────────────
            if (char === 'क' && next === '्' && nextNext === 'ष') {
                result += '𑴮'; // ksha
                i += 3;
                continue;
            }
            if (char === 'त' && next === '्' && nextNext === 'र') {
                result += '𑴰'; // tra
                i += 3;
                continue;
            }
            if (char === 'ज' && next === '्' && nextNext === 'ञ') {
                result += '𑴯'; // gya/dnya
                i += 3;
                continue;
            }
            if (char === 'श' && next === '्' && nextNext === 'र') {
                result += '𑴩' + MARKS.rakar; // shra
                i += 3;
                continue;
            }

            // ─────────────────────────────────────────────────────────────
            // NUMBERS
            // ─────────────────────────────────────────────────────────────
            if (HI_NUMBERS[char]) {
                result += HI_NUMBERS[char];
                i++;
                continue;
            }

            // ─────────────────────────────────────────────────────────────
            // CONSONANTS
            // ─────────────────────────────────────────────────────────────
            if (HI_CONSONANTS[char]) {
                result += HI_CONSONANTS[char];
                i++;

                // Check for following marks/matras
                while (i < text.length) {
                    const nextChar = text[i];

                    // Virama (halant) - check for conjunct or final
                    if (nextChar === '्') {
                        // Check if followed by consonant (conjunct)
                        const afterVirama = i + 1 < text.length ? text[i + 1] : '';

                        // Special case: र after virama = rakar
                        if (afterVirama === 'र') {
                            result += MARKS.rakar;
                            i += 2;
                            continue;
                        }

                        // Regular conjunct or final
                        if (HI_CONSONANTS[afterVirama]) {
                            result += MARKS.virama;
                            i++;
                            break; // Next iteration handles the consonant
                        } else {
                            // Final virama
                            result += MARKS.halanta;
                            i++;
                            continue;
                        }
                    }

                    // Matras
                    if (HI_MATRAS[nextChar]) {
                        result += HI_MATRAS[nextChar];
                        i++;
                        continue;
                    }

                    // Anusvara, Visarga, Chandrabindu
                    if (nextChar === 'ं') {
                        result += MARKS.anusvara;
                        i++;
                        continue;
                    }
                    if (nextChar === 'ः') {
                        result += MARKS.visarga;
                        i++;
                        continue;
                    }
                    if (nextChar === 'ँ') {
                        result += MARKS.chandrabindu;
                        i++;
                        continue;
                    }

                    // Nukta after consonant
                    if (nextChar === '़') {
                        result += MARKS.sukun;
                        i++;
                        continue;
                    }

                    // No more modifiers
                    break;
                }
                continue;
            }

            // ─────────────────────────────────────────────────────────────
            // INDEPENDENT VOWELS
            // ─────────────────────────────────────────────────────────────
            if (HI_VOWELS[char]) {
                result += HI_VOWELS[char];
                i++;

                // Check for following anusvara/visarga/chandrabindu
                while (i < text.length) {
                    const nextChar = text[i];
                    if (nextChar === 'ं') {
                        result += MARKS.anusvara;
                        i++;
                        continue;
                    }
                    if (nextChar === 'ः') {
                        result += MARKS.visarga;
                        i++;
                        continue;
                    }
                    if (nextChar === 'ँ') {
                        result += MARKS.chandrabindu;
                        i++;
                        continue;
                    }
                    break;
                }
                continue;
            }

            // ─────────────────────────────────────────────────────────────
            // STANDALONE MARKS
            // ─────────────────────────────────────────────────────────────
            if (HI_MARKS[char] !== undefined) {
                result += HI_MARKS[char];
                i++;
                continue;
            }

            // ─────────────────────────────────────────────────────────────
            // ASCII CHARACTERS (for mixed input)
            // ─────────────────────────────────────────────────────────────
            if (!isHindiChar(char)) {
                // Pass through spaces and punctuation
                if (char === ' ' || char === '\n' || char === '\t' ||
                    char === ',' || char === '!' || char === '?' ||
                    char === '-' || char === '(' || char === ')') {
                    result += char;
                    i++;
                    continue;
                }

                // Numbers
                if (EN_NUMBERS[char]) {
                    result += EN_NUMBERS[char];
                    i++;
                    continue;
                }

                // Other ASCII - pass through
                result += char;
                i++;
                continue;
            }

            // ─────────────────────────────────────────────────────────────
            // UNRECOGNIZED - pass through
            // ─────────────────────────────────────────────────────────────
            result += char;
            i++;
        }

        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MAIN TRANSLITERATE FUNCTION
    // ═══════════════════════════════════════════════════════════════════════════

    function transliterate(text, mode) {
        if (!text) {
            return '';
        }

        mode = mode || 'en';

        // Auto-detect Hindi if mode is 'hi' or text contains Hindi
        if (mode === 'hi' || mode === 'hindi') {
            // Only use hindiToGondi if text actually contains Hindi/Devanagari characters
            // This allows typing English romanization even in Hindi mode
            if (containsHindi(text)) {
                return hindiToGondi(text);
            }
            // If no Hindi characters found but mode is 'hi', fall back to English mode
            // This handles the case where user types English letters in Hindi mode
        }

        // Check if input contains Hindi characters (for auto mode)
        if (mode === 'auto' && containsHindi(text)) {
            return hindiToGondi(text);
        }

        const result = text.split(/(\s+)/).map(function (part) {
            if (!part.trim()) return part;
            const gondiPart = englishToGondi(part);
            return gondiPart;
        }).join('');
        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GONDI TO IPA FUNCTION
    // ═══════════════════════════════════════════════════════════════════════════

    function gondiToIPA(text) {
        if (!text) {
            return '';
        }

        let result = '';
        let i = 0;

        while (i < text.length) {
            let char = text[i];
            let nextChar = text[i + 1] || '';

            // Check for two-character combinations first (nukta, conjuncts)
            let twoChar = char + nextChar;
            if (GONDI_TO_IPA[twoChar] !== undefined) {
                result += GONDI_TO_IPA[twoChar];
                i += 2;
                continue;
            }

            // Single character mapping
            if (GONDI_TO_IPA[char] !== undefined) {
                let ipa = GONDI_TO_IPA[char];
                result += ipa;
                i++;

                // If this is halanta, remove 'a' from the end of the result
                if (char === '𑵄' && result.endsWith('a')) {
                    result = result.slice(0, -1);
                }
                continue;
            }

            result += char;
            i++;
        }

        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEFAULTS
    // ═══════════════════════════════════════════════════════════════════════════

    const DEFAULTS = {
        // Mode
        mode: 'en',                    // 'en', 'hi', 'auto'

        // Target element
        target: null,

        // Input settings
        placeholder: '',
        maxLength: null,

        // Keyboard
        keyboard: false,               // Enable keyboard
        keyboardLayout: 'itrans',      // 'itrans', 'hindi', 'gondi'
        keyboardPosition: 'bottom',    // 'top', 'bottom'
        keyboardAutoShow: true,        // Show on focus when enabled
        keyboardAutoHide: true,        // Hide on blur

        // Popup menu
        popup: true,
        popupItems: [
            'copy', 'cut', 'paste', 'divider',
            'selectAll', 'divider',
            'mode', 'keyboard', 'suggestions', 'translate', 'divider',
            'clear'
        ],

        // Suggestions
        suggestions: true,
        suggestionsData: {},
        suggestionsApi: null,
        suggestionsApiMethod: 'GET',
        suggestionsApiParam: 'q',
        suggestionsApiDebounce: 300,
        suggestionsApiTransform: null,
        minSuggestionLength: 2,
        maxSuggestions: 8,

        // Translate panel
        translate: false,              // Show translate panel
        translateApi: null,            // API for translation
        translateAutoShow: false,      // Auto show on input

        // Edit mode
        initialValue: '',
        preserveExisting: true,

        // Persistence
        persistState: true,            // Save toggle states to localStorage
        persistKey: 'default',         // Key for localStorage

        // IPA
        ipa: false,                    // Generate IPA pronunciation
        ipaTarget: null,               // Target element for IPA output

        // Callbacks
        onInput: null,
        onChange: null,
        onReady: null,
        onModeChange: null,
        onSuggestionSelect: null,
        onKeyboardToggle: null,
        onTranslate: null
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPORT TO GLOBAL
    // ═══════════════════════════════════════════════════════════════════════════

    // Store in jQuery namespace
    $.masaramGondiCore = {
        version: '5.7.0',

        // Constants
        MARKS: MARKS,
        EN_VOWELS: EN_VOWELS,
        EN_MATRAS: EN_MATRAS,
        EN_CONSONANTS: EN_CONSONANTS,
        EN_NUMBERS: EN_NUMBERS,
        HI_VOWELS: HI_VOWELS,
        HI_MATRAS: HI_MATRAS,
        HI_CONSONANTS: HI_CONSONANTS,
        HI_NUMBERS: HI_NUMBERS,
        HI_MARKS: HI_MARKS,

        // Mappings (combined for compatibility)
        mappings: {
            marks: MARKS,
            vowels: EN_VOWELS,
            matras: EN_MATRAS,
            consonants: EN_CONSONANTS,
            numbers: EN_NUMBERS,
            hindi: {
                vowels: HI_VOWELS,
                matras: HI_MATRAS,
                consonants: HI_CONSONANTS,
                numbers: HI_NUMBERS,
                marks: HI_MARKS
            }
        },

        // Layouts
        keyboards: KEYBOARD_LAYOUTS,

        // Suggestions
        suggestions: DEFAULT_SUGGESTIONS,

        // Defaults
        defaults: DEFAULTS,

        // Functions
        transliterate: transliterate,
        t: transliterate,
        englishToGondi: englishToGondi,
        hindiToGondi: hindiToGondi,
        gondiToIPA: gondiToIPA,

        // Helpers
        helpers: {
            matchFromMap: matchFromMap,
            isHindiChar: isHindiChar,
            containsHindi: containsHindi,
            debounce: debounce,
            Storage: Storage
        }
    };

    // Global shorthand
    window.transliterate = transliterate;
    window.t2g = transliterate; // Shorthand: text to gondi

})(jQuery);