import 'package:hive_flutter/hive_flutter.dart';
import '../models/keyboard_settings.dart';
import '../models/custom_word.dart';

class HiveService {
  static const String settingsBoxName = 'keyboard_settings';
  static const String customWordsBoxName = 'custom_words';
  static const String usageStatsBoxName = 'usage_stats';

  static late Box<KeyboardSettings> settingsBox;
  static late Box<CustomWord> customWordsBox;
  static late Box<dynamic> usageStatsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(KeyboardSettingsAdapter());
    Hive.registerAdapter(CustomWordAdapter());

    // Open boxes
    settingsBox = await Hive.openBox<KeyboardSettings>(settingsBoxName);
    customWordsBox = await Hive.openBox<CustomWord>(customWordsBoxName);
    usageStatsBox = await Hive.openBox(usageStatsBoxName);

    // Initialize defaults
    if (settingsBox.isEmpty) {
      await settingsBox.put('settings', KeyboardSettings());
    }

    if (customWordsBox.isEmpty) {
      await _addDefaultWords();
    }
  }

  static Future<void> _addDefaultWords() async {
    // Hindi words
    final hindiWords = {
      'namaste': 'नमस्ते',
      'namaskar': 'नमस्कार',
      'dhanyavaad': 'धन्यवाद',
      'shukriya': 'शुक्रिया',
      'kaise ho': 'कैसे हो',
      'theek hoon': 'ठीक हूं',
      'aapka naam': 'आपका नाम',
      'mera naam': 'मेरा नाम',
      'shubh prabhat': 'शुभ प्रभात',
      'shubh ratri': 'शुभ रात्रि',
      'alvida': 'अलविदा',
      'phir milenge': 'फिर मिलेंगे',
    };

    for (var entry in hindiWords.entries) {
      await customWordsBox.add(
        CustomWord(
          englishWord: entry.key,
          translatedWord: entry.value,
          languageIndex: 1, // Hindi
          createdAt: DateTime.now(),
        ),
      );
    }

    // Gondi words (basic greetings)
    final gondiWords = {
      'jokhar': '𑴕𑴽𑴎𑴦𑴢', // Hello/Greetings
      'namaskar': '𑴕𑴽𑴎𑴦𑴢 𑴦𑴛𑴧𑴘𑴦𑴢',
      'dhanyavaad': '𑴘𑴟𑴤𑴳𑴮𑴦𑴘', // Thank you
      'aap': '𑴀𑴦𑴧', // You
      'main': '𑴋𑴦𑴤', // I
      'naam': '𑴕𑴦𑴋', // Name
    };

    for (var entry in gondiWords.entries) {
      await customWordsBox.add(
        CustomWord(
          englishWord: entry.key,
          translatedWord: entry.value,
          languageIndex: 2, // Gondi
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // Settings CRUD
  static KeyboardSettings getSettings() {
    return settingsBox.get('settings') ?? KeyboardSettings();
  }

  static Future<void> saveSettings(KeyboardSettings settings) async {
    await settingsBox.put('settings', settings);
  }

  // Custom Words CRUD
  static List<CustomWord> getAllCustomWords({int? languageIndex}) {
    if (languageIndex == null) {
      return customWordsBox.values.toList()..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.usageCount.compareTo(a.usageCount);
      });
    }

    return customWordsBox.values
        .where((word) => word.languageIndex == languageIndex)
        .toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.usageCount.compareTo(a.usageCount);
      });
  }

  static List<CustomWord> searchCustomWords(
    String query, {
    int? languageIndex,
  }) {
    if (query.isEmpty) return getAllCustomWords(languageIndex: languageIndex);

    return customWordsBox.values.where((word) {
      final matchesLanguage =
          languageIndex == null || word.languageIndex == languageIndex;
      final matchesQuery =
          word.englishWord.toLowerCase().contains(query.toLowerCase()) ||
          word.translatedWord.contains(query);
      return matchesLanguage && matchesQuery;
    }).toList()..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  static List<CustomWord> getSuggestions(
    String input,
    int languageIndex, {
    int limit = 5,
  }) {
    if (input.isEmpty) return [];

    final lastWord = input.split(' ').last.toLowerCase();
    if (lastWord.isEmpty) return [];

    return customWordsBox.values
        .where(
          (word) =>
              word.languageIndex == languageIndex &&
              word.englishWord.toLowerCase().startsWith(lastWord),
        )
        .take(limit)
        .toList();
  }

  static Future<int> addCustomWord(CustomWord word) async {
    // Check for duplicate
    final existing = customWordsBox.values.firstWhere(
      (w) =>
          w.englishWord.toLowerCase() == word.englishWord.toLowerCase() &&
          w.languageIndex == word.languageIndex,
      orElse: () => CustomWord(
        englishWord: '',
        translatedWord: '',
        languageIndex: 0,
        createdAt: DateTime.now(),
      ),
    );

    if (existing.englishWord.isNotEmpty) {
      throw Exception('Word already exists');
    }

    return await customWordsBox.add(word);
  }

  static Future<void> updateCustomWord(int index, CustomWord word) async {
    await customWordsBox.putAt(index, word);
  }

  static Future<void> deleteCustomWord(int index) async {
    await customWordsBox.deleteAt(index);
  }

  static Future<void> incrementWordUsage(CustomWord word) async {
    final index = customWordsBox.values.toList().indexOf(word);
    if (index != -1) {
      await customWordsBox.putAt(
        index,
        word.copyWith(
          usageCount: word.usageCount + 1,
          lastUsed: DateTime.now(),
        ),
      );
    }
  }

  static Future<void> togglePinned(CustomWord word) async {
    final index = customWordsBox.values.toList().indexOf(word);
    if (index != -1) {
      await customWordsBox.putAt(
        index,
        word.copyWith(isPinned: !word.isPinned),
      );
    }
  }

  static Future<void> clearAllCustomWords() async {
    await customWordsBox.clear();
    await _addDefaultWords();
  }

  // Usage Statistics
  static Future<void> recordKeyPress(String key) async {
    final count = usageStatsBox.get('keypress_$key', defaultValue: 0) as int;
    await usageStatsBox.put('keypress_$key', count + 1);
  }

  static int getTotalKeyPresses() {
    int total = 0;
    for (var key in usageStatsBox.keys) {
      if (key.toString().startsWith('keypress_')) {
        total += usageStatsBox.get(key) as int;
      }
    }
    return total;
  }

  static Map<String, int> getTopKeys({int limit = 10}) {
    final keyPresses = <String, int>{};

    for (var key in usageStatsBox.keys) {
      if (key.toString().startsWith('keypress_')) {
        final keyName = key.toString().replaceFirst('keypress_', '');
        keyPresses[keyName] = usageStatsBox.get(key) as int;
      }
    }

    final sorted = keyPresses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(limit));
  }
}
