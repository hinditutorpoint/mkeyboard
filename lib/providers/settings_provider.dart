import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/keyboard_settings.dart';
import '../models/custom_word.dart';
import '../services/hive_service.dart';

/// Starts Hive init when someone watches this provider.
/// Do NOT await it in IME startup (keep IME fast), just let it run.
final hiveReadyProvider = FutureProvider<void>((ref) async {
  await HiveService.ensureInitialized();
});

// ============================
// Settings Notifier
// ============================
class SettingsNotifier extends StateNotifier<KeyboardSettings> {
  bool _alive = true;

  SettingsNotifier() : super(KeyboardSettings()) {
    // SAFE immediate read (must not crash even if Hive not ready)
    state = HiveService.getSettings();

    // Refresh once Hive is actually ready
    HiveService.ensureInitialized()
        .then((_) {
          if (_alive) {
            state = HiveService.getSettings();
          }
        })
        .catchError((e) {
          debugPrint('SettingsNotifier: Hive init failed: $e');
        });
  }

  @override
  void dispose() {
    _alive = false;
    super.dispose();
  }

  Future<void> reloadFromHive() async {
    if (!_alive) return;
    state = HiveService.getSettings();
  }

  Future<void> setHapticFeedback(bool value) async {
    final s = state.copyWith(hapticFeedback: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setSoundOnKeyPress(bool value) async {
    final s = state.copyWith(soundOnKeyPress: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setShowSuggestions(bool value) async {
    final s = state.copyWith(showSuggestions: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setAutoCapitalize(bool value) async {
    final s = state.copyWith(autoCapitalize: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setShowNumberRow(bool value) async {
    final s = state.copyWith(showNumberRow: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setKeyHeight(double value) async {
    final s = state.copyWith(keyHeight: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setFontSize(double value) async {
    final s = state.copyWith(fontSize: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setThemeName(String value) async {
    final s = state.copyWith(themeName: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setDefaultLanguage(int value) async {
    final s = state.copyWith(defaultLanguageIndex: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setSwipeToDelete(bool value) async {
    final s = state.copyWith(swipeToDelete: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setLongPressForSymbols(bool value) async {
    final s = state.copyWith(longPressForSymbols: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setSuggestionCount(int value) async {
    final s = state.copyWith(suggestionCount: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setShowPreview(bool value) async {
    final s = state.copyWith(showPreview: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setKeySpacing(double value) async {
    final s = state.copyWith(keySpacing: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> setEnableGlideTyping(bool value) async {
    final s = state.copyWith(enableGlideTyping: value);
    state = s;
    await HiveService.saveSettings(s);
  }

  Future<void> resetSettings() async {
    final s = KeyboardSettings();
    state = s;
    await HiveService.saveSettings(s);
  }
}

// Settings provider (also triggers hiveReadyProvider so init starts)
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, KeyboardSettings>((ref) {
      ref.watch(hiveReadyProvider); // kick init
      return SettingsNotifier();
    });

// ============================
// Custom Words Notifier
// ============================
class CustomWordsNotifier extends StateNotifier<AsyncValue<List<CustomWord>>> {
  bool _alive = true;

  CustomWordsNotifier() : super(const AsyncValue.loading()) {
    // Load once Hive is ready
    HiveService.ensureInitialized()
        .then((_) {
          if (_alive) {
            _loadCustomWords();
          }
        })
        .catchError((e) {
          if (_alive) {
            state = AsyncValue.error(e, StackTrace.current);
          }
        });
  }

  @override
  void dispose() {
    _alive = false;
    super.dispose();
  }

  Future<void> _loadCustomWords() async {
    try {
      final words = HiveService.getAllCustomWords();
      if (_alive) state = AsyncValue.data(words);
    } catch (e, st) {
      if (_alive) state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => _loadCustomWords();

  Future<bool> addCustomWord(
    String english,
    String translated,
    int languageIndex,
  ) async {
    try {
      await HiveService.addCustomWord(
        CustomWord(
          englishWord: english.trim().toLowerCase(),
          translatedWord: translated.trim(),
          languageIndex: languageIndex,
          createdAt: DateTime.now(),
        ),
      );
      await _loadCustomWords();
      return true;
    } catch (e) {
      debugPrint('Error adding custom word: $e');
      return false;
    }
  }

  Future<void> updateCustomWord(
    CustomWord word,
    String newEnglish,
    String newTranslated,
  ) async {
    try {
      final words = state.maybeWhen(
        data: (w) => w,
        orElse: () => <CustomWord>[],
      );
      final index = words.indexOf(word);
      if (index != -1) {
        await HiveService.updateCustomWord(
          index,
          word.copyWith(
            englishWord: newEnglish.trim().toLowerCase(),
            translatedWord: newTranslated.trim(),
          ),
        );
        await _loadCustomWords();
      }
    } catch (e) {
      debugPrint('Error updating custom word: $e');
    }
  }

  Future<void> deleteCustomWord(CustomWord word) async {
    try {
      final words = state.maybeWhen(
        data: (w) => w,
        orElse: () => <CustomWord>[],
      );
      final index = words.indexOf(word);
      if (index != -1) {
        await HiveService.deleteCustomWord(index);
        await _loadCustomWords();
      }
    } catch (e) {
      debugPrint('Error deleting custom word: $e');
    }
  }

  Future<void> togglePinned(CustomWord word) async {
    try {
      await HiveService.togglePinned(word);
      await _loadCustomWords();
    } catch (e) {
      debugPrint('Error toggling pinned: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await HiveService.clearAllCustomWords();
      await _loadCustomWords();
    } catch (e) {
      debugPrint('Error clearing all: $e');
    }
  }

  List<CustomWord> getAllWords() {
    try {
      return state.maybeWhen(data: (w) => w, orElse: () => []);
    } catch (_) {
      return [];
    }
  }
}

// Custom words provider (also triggers hiveReadyProvider so init starts)
final customWordsProvider =
    StateNotifierProvider<CustomWordsNotifier, AsyncValue<List<CustomWord>>>((
      ref,
    ) {
      ref.watch(hiveReadyProvider); // kick init
      return CustomWordsNotifier();
    });

// Derived providers
final allCustomWordsProvider = Provider<List<CustomWord>>((ref) {
  final customWords = ref.watch(customWordsProvider);
  return customWords.maybeWhen(data: (w) => w, orElse: () => const []);
});

final customWordsByLanguageProvider = Provider.family<List<CustomWord>, int>((
  ref,
  languageIndex,
) {
  final words = ref.watch(allCustomWordsProvider);
  return words.where((w) => w.languageIndex == languageIndex).toList();
});

final searchCustomWordsProvider =
    Provider.family<List<CustomWord>, (String, int?)>((ref, params) {
      final query = params.$1;
      final languageIndex = params.$2;
      final words = ref.watch(allCustomWordsProvider);

      if (query.isEmpty) {
        return languageIndex == null
            ? words
            : words.where((w) => w.languageIndex == languageIndex).toList();
      }

      final q = query.toLowerCase();
      return words.where((w) {
        final matchesLanguage =
            languageIndex == null || w.languageIndex == languageIndex;
        final matchesQuery =
            w.englishWord.toLowerCase().contains(q) ||
            w.translatedWord.contains(query);
        return matchesLanguage && matchesQuery;
      }).toList();
    });
