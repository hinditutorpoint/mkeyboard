import 'package:hive_flutter/hive_flutter.dart';
import '../models/keyboard_settings.dart';
import '../models/custom_word.dart';

class HiveService {
  static const String settingsBoxName = 'keyboard_settings';
  static const String customWordsBoxName = 'custom_words';
  static const String usageStatsBoxName = 'usage_stats';

  static late Box<KeyboardSettings> _settingsBox;
  static late Box<CustomWord> _customWordsBox;
  static late Box<dynamic> _usageStatsBox;

  static Future<void>? _initFuture;

  static bool get isReady => true;

  /// Safe: can be called multiple times; will only init once.
  /// If init fails, it resets so you can retry.
  static Future<void> ensureInitialized() {
    final existing = _initFuture;
    if (existing != null) return existing;

    _initFuture = init().catchError((e, st) {
      _initFuture = null;
      throw e;
    });

    return _initFuture!;
  }

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters only once
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(KeyboardSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CustomWordAdapter());
    }

    _settingsBox = Hive.isBoxOpen(settingsBoxName)
        ? Hive.box<KeyboardSettings>(settingsBoxName)
        : await Hive.openBox<KeyboardSettings>(settingsBoxName);

    _customWordsBox = Hive.isBoxOpen(customWordsBoxName)
        ? Hive.box<CustomWord>(customWordsBoxName)
        : await Hive.openBox<CustomWord>(customWordsBoxName);

    _usageStatsBox = Hive.isBoxOpen(usageStatsBoxName)
        ? Hive.box(usageStatsBoxName)
        : await Hive.openBox(usageStatsBoxName);

    // Defaults
    if (_settingsBox.get('settings') == null) {
      await _settingsBox.put('settings', KeyboardSettings());
    }

    if (_customWordsBox.isEmpty) {
      await _addDefaultWords();
    }
  }

  static Future<void> _addDefaultWords() async {
    final box = _customWordsBox;

    // keep it small so IME boot stays fast
    final hindiWords = {
      'namaste': 'नमस्ते',
      'dhanyavaad': 'धन्यवाद',
      'kaise ho': 'कैसे हो',
      'mera naam': 'मेरा नाम',
    };

    for (final entry in hindiWords.entries) {
      await box.add(
        CustomWord(
          englishWord: entry.key,
          translatedWord: entry.value,
          languageIndex: 1,
          createdAt: DateTime.now(),
        ),
      );
    }

    final gondiWords = {
      'jokhar': '𑴕𑴽𑴎𑴦𑴢',
      'dhanyavaad': '𑴘𑴟𑴤𑴳𑴮𑴦𑴘',
      'naam': '𑴕𑴦𑴋',
    };

    for (final entry in gondiWords.entries) {
      await box.add(
        CustomWord(
          englishWord: entry.key,
          translatedWord: entry.value,
          languageIndex: 2,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // =========================
  // SAFE SYNC READS (no crash before init)
  // =========================

  static KeyboardSettings getSettings() {
    try {
      return _settingsBox.get('settings') ?? KeyboardSettings();
    } catch (_) {
      return KeyboardSettings();
    }
  }

  static List<CustomWord> getAllCustomWords({int? languageIndex}) {
    try {
      Iterable<CustomWord> words = _customWordsBox.values;
      if (languageIndex != null) {
        words = words.where((w) => w.languageIndex == languageIndex);
      }

      final list = words.toList()
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.usageCount.compareTo(a.usageCount);
        });

      return list;
    } catch (_) {
      return [];
    }
  }

  static List<CustomWord> searchCustomWords(
    String query, {
    int? languageIndex,
  }) {
    try {
      final all = getAllCustomWords(languageIndex: languageIndex);
      if (query.isEmpty) return all;

      final q = query.toLowerCase();
      final list =
          all
              .where(
                (w) =>
                    w.englishWord.toLowerCase().contains(q) ||
                    w.translatedWord.contains(query),
              )
              .toList()
            ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

      return list;
    } catch (_) {
      return [];
    }
  }

  static List<CustomWord> getSuggestions(
    String input,
    int languageIndex, {
    int limit = 5,
  }) {
    try {
      if (input.isEmpty) return [];
      final lastWord = input.split(' ').last.toLowerCase();
      if (lastWord.isEmpty) return [];

      final box = _customWordsBox;

      return box.values
          .where(
            (w) =>
                w.languageIndex == languageIndex &&
                w.englishWord.toLowerCase().startsWith(lastWord),
          )
          .take(limit)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static int getTotalKeyPresses() {
    try {
      final box = _usageStatsBox;

      int total = 0;
      for (final key in box.keys) {
        if (key.toString().startsWith('keypress_')) {
          total += (box.get(key) as int?) ?? 0;
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  static Map<String, int> getTopKeys({int limit = 10}) {
    try {
      final box = _usageStatsBox;

      final keyPresses = <String, int>{};
      for (final key in box.keys) {
        if (key.toString().startsWith('keypress_')) {
          final keyName = key.toString().replaceFirst('keypress_', '');
          keyPresses[keyName] = (box.get(key) as int?) ?? 0;
        }
      }

      final sorted = keyPresses.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Map.fromEntries(sorted.take(limit));
    } catch (_) {
      return {};
    }
  }

  // =========================
  // ASYNC WRITES (ensure init first)
  // =========================

  static Future<void> saveSettings(KeyboardSettings settings) async {
    await ensureInitialized();
    await _settingsBox.put('settings', settings);
  }

  static Future<int> addCustomWord(CustomWord word) async {
    await ensureInitialized();

    final existing = _customWordsBox.values.firstWhere(
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

    return _customWordsBox.add(word);
  }

  static Future<void> updateCustomWord(int index, CustomWord word) async {
    await ensureInitialized();
    await _customWordsBox.putAt(index, word);
  }

  static Future<void> deleteCustomWord(int index) async {
    await ensureInitialized();
    await _customWordsBox.deleteAt(index);
  }

  static Future<void> incrementWordUsage(CustomWord word) async {
    await ensureInitialized();
    final list = _customWordsBox.values.toList();
    final index = list.indexOf(word);
    if (index != -1) {
      await _customWordsBox.putAt(
        index,
        word.copyWith(
          usageCount: word.usageCount + 1,
          lastUsed: DateTime.now(),
        ),
      );
    }
  }

  static Future<void> togglePinned(CustomWord word) async {
    await ensureInitialized();
    final list = _customWordsBox.values.toList();
    final index = list.indexOf(word);
    if (index != -1) {
      await _customWordsBox.putAt(
        index,
        word.copyWith(isPinned: !word.isPinned),
      );
    }
  }

  static Future<void> clearAllCustomWords() async {
    await ensureInitialized();
    await _customWordsBox.clear();
    await _addDefaultWords();
  }

  static Future<void> recordKeyPress(String key) async {
    await ensureInitialized();
    final count = (_usageStatsBox.get('keypress_$key') as int?) ?? 0;
    await _usageStatsBox.put('keypress_$key', count + 1);
  }
}
