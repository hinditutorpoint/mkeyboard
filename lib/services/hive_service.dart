import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      await Hive.initFlutter();

      // Register adapters only once
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(KeyboardSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CustomWordAdapter());
      }

      // Try opening boxes with error handling
      try {
        _settingsBox = await Hive.openBox<KeyboardSettings>(settingsBoxName);
      } catch (e) {
        debugPrint('Error opening settings box: $e');
        // Maybe try to delete lock file? For now just log.
      }

      try {
        _customWordsBox = await Hive.openBox<CustomWord>(customWordsBoxName);
      } catch (e) {
        debugPrint('Error opening custom words box: $e');
      }

      try {
        _usageStatsBox = await Hive.openBox(usageStatsBoxName);
      } catch (e) {
        debugPrint('Error opening usage stats box: $e');
      }

      // Defaults - check if box is open
      if (Hive.isBoxOpen(settingsBoxName)) {
        if (_settingsBox.get('settings') == null) {
          await _settingsBox.put('settings', KeyboardSettings());
        }
      }

      if (Hive.isBoxOpen(customWordsBoxName)) {
        if (_customWordsBox.isEmpty) {
          await _addDefaultWords();
        }
      }
    } catch (e) {
      debugPrint('Critical Hive init error: $e');
    }
  }

  static Future<void> _addDefaultWords() async {
    if (!Hive.isBoxOpen(customWordsBoxName)) return;

    try {
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
    } catch (e) {
      debugPrint('Error adding default words: $e');
    }
  }

  // =========================
  // SAFE SYNC READS (no crash before init)
  // =========================

  static KeyboardSettings getSettings() {
    try {
      if (!Hive.isBoxOpen(settingsBoxName)) return KeyboardSettings();
      return _settingsBox.get('settings') ?? KeyboardSettings();
    } catch (_) {
      return KeyboardSettings();
    }
  }

  static List<CustomWord> getAllCustomWords({int? languageIndex}) {
    try {
      if (!Hive.isBoxOpen(customWordsBoxName)) return [];

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
      if (!Hive.isBoxOpen(customWordsBoxName)) return [];

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
      if (!Hive.isBoxOpen(customWordsBoxName)) return [];

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
      if (!Hive.isBoxOpen(usageStatsBoxName)) return 0;
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
      if (!Hive.isBoxOpen(usageStatsBoxName)) return {};
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
    try {
      await ensureInitialized();
      if (Hive.isBoxOpen(settingsBoxName)) {
        await _settingsBox.put('settings', settings);
      }

      // Sync to SharedPreferences for native keyboard to read
      await _syncToSharedPreferences(settings);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Sync settings to SharedPreferences so native Kotlin keyboard can read them.
  /// Keys use 'flutter.' prefix which is what shared_preferences uses.
  static Future<void> _syncToSharedPreferences(
    KeyboardSettings settings,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('flutter.themeName', settings.themeName);
      await prefs.setBool('flutter.hapticFeedback', settings.hapticFeedback);
      await prefs.setBool('flutter.soundOnKeyPress', settings.soundOnKeyPress);
      await prefs.setBool('flutter.showSuggestions', settings.showSuggestions);
      await prefs.setBool('flutter.autoCapitalize', settings.autoCapitalize);
      await prefs.setBool('flutter.showNumberRow', settings.showNumberRow);
      await prefs.setDouble('flutter.keyHeight', settings.keyHeight);
      await prefs.setDouble('flutter.fontSize', settings.fontSize);
      await prefs.setInt(
        'flutter.defaultLanguageIndex',
        settings.defaultLanguageIndex,
      );
      await prefs.setDouble('flutter.keySpacing', settings.keySpacing);

      debugPrint('Settings synced to SharedPreferences');
    } catch (e) {
      debugPrint('Error syncing to SharedPreferences: $e');
    }
  }

  static Future<int> addCustomWord(CustomWord word) async {
    try {
      await ensureInitialized();
      if (!Hive.isBoxOpen(customWordsBoxName)) return -1;

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
    } catch (e) {
      debugPrint('Error adding custom word: $e');
      return -1;
    }
  }

  static Future<void> updateCustomWord(int index, CustomWord word) async {
    try {
      await ensureInitialized();
      if (Hive.isBoxOpen(customWordsBoxName)) {
        await _customWordsBox.putAt(index, word);
      }
    } catch (e) {
      debugPrint('Error updating custom word: $e');
    }
  }

  static Future<void> deleteCustomWord(int index) async {
    try {
      await ensureInitialized();
      if (Hive.isBoxOpen(customWordsBoxName)) {
        await _customWordsBox.deleteAt(index);
      }
    } catch (e) {
      debugPrint('Error deleting custom word: $e');
    }
  }

  static Future<void> incrementWordUsage(CustomWord word) async {
    try {
      await ensureInitialized();
      if (!Hive.isBoxOpen(customWordsBoxName)) return;

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
    } catch (e) {
      debugPrint('Error incrementing word usage: $e');
    }
  }

  static Future<void> togglePinned(CustomWord word) async {
    try {
      await ensureInitialized();
      if (!Hive.isBoxOpen(customWordsBoxName)) return;

      final list = _customWordsBox.values.toList();
      final index = list.indexOf(word);
      if (index != -1) {
        await _customWordsBox.putAt(
          index,
          word.copyWith(isPinned: !word.isPinned),
        );
      }
    } catch (e) {
      debugPrint('Error toggling pinned: $e');
    }
  }

  static Future<void> clearAllCustomWords() async {
    try {
      await ensureInitialized();
      if (!Hive.isBoxOpen(customWordsBoxName)) return;

      await _customWordsBox.clear();
      await _addDefaultWords();
    } catch (e) {
      debugPrint('Error clearing all custom words: $e');
    }
  }

  static Future<void> recordKeyPress(String key) async {
    try {
      await ensureInitialized();
      if (!Hive.isBoxOpen(usageStatsBoxName)) return;

      final count = (_usageStatsBox.get('keypress_$key') as int?) ?? 0;
      await _usageStatsBox.put('keypress_$key', count + 1);
    } catch (e) {
      debugPrint('Error recording key press: $e');
    }
  }
}
