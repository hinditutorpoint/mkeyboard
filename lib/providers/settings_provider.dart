import 'package:flutter/foundation.dart';
import '../models/keyboard_settings.dart';
import '../models/custom_word.dart';
import '../services/hive_service.dart';

class SettingsProvider extends ChangeNotifier {
  KeyboardSettings _settings = KeyboardSettings();
  List<CustomWord> _allCustomWords = [];

  KeyboardSettings get settings => _settings;
  int get customWordsCount => _allCustomWords.length;

  SettingsProvider() {
    _loadData();
  }

  void _loadData() {
    _settings = HiveService.getSettings();
    _allCustomWords = HiveService.getAllCustomWords();
    notifyListeners();
  }

  // Settings methods
  Future<void> setHapticFeedback(bool value) async {
    _settings = _settings.copyWith(hapticFeedback: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSoundOnKeyPress(bool value) async {
    _settings = _settings.copyWith(soundOnKeyPress: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowSuggestions(bool value) async {
    _settings = _settings.copyWith(showSuggestions: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAutoCapitalize(bool value) async {
    _settings = _settings.copyWith(autoCapitalize: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowNumberRow(bool value) async {
    _settings = _settings.copyWith(showNumberRow: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setKeyHeight(double value) async {
    _settings = _settings.copyWith(keyHeight: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _settings = _settings.copyWith(fontSize: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeName(String value) async {
    _settings = _settings.copyWith(themeName: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setDefaultLanguage(int value) async {
    _settings = _settings.copyWith(defaultLanguageIndex: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSwipeToDelete(bool value) async {
    _settings = _settings.copyWith(swipeToDelete: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setLongPressForSymbols(bool value) async {
    _settings = _settings.copyWith(longPressForSymbols: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSuggestionCount(int value) async {
    _settings = _settings.copyWith(suggestionCount: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowPreview(bool value) async {
    _settings = _settings.copyWith(showPreview: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setKeySpacing(double value) async {
    _settings = _settings.copyWith(keySpacing: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setEnableGlideTyping(bool value) async {
    _settings = _settings.copyWith(enableGlideTyping: value);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _settings = KeyboardSettings();
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  // Custom Words methods
  List<CustomWord> getAllCustomWords() {
    return HiveService.getAllCustomWords();
  }

  List<CustomWord> getCustomWordsByLanguage(int languageIndex) {
    return HiveService.getAllCustomWords(languageIndex: languageIndex);
  }

  List<CustomWord> searchCustomWords(String query, {int? languageIndex}) {
    return HiveService.searchCustomWords(query, languageIndex: languageIndex);
  }

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
      _allCustomWords = HiveService.getAllCustomWords();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateCustomWord(
    CustomWord word,
    String newEnglish,
    String newTranslated,
  ) async {
    final index = _allCustomWords.indexOf(word);
    if (index != -1) {
      await HiveService.updateCustomWord(
        index,
        word.copyWith(
          englishWord: newEnglish.trim().toLowerCase(),
          translatedWord: newTranslated.trim(),
        ),
      );
      _allCustomWords = HiveService.getAllCustomWords();
      notifyListeners();
    }
  }

  Future<void> deleteCustomWord(CustomWord word) async {
    final index = _allCustomWords.indexOf(word);
    if (index != -1) {
      await HiveService.deleteCustomWord(index);
      _allCustomWords = HiveService.getAllCustomWords();
      notifyListeners();
    }
  }

  Future<void> togglePinned(CustomWord word) async {
    await HiveService.togglePinned(word);
    _allCustomWords = HiveService.getAllCustomWords();
    notifyListeners();
  }

  Future<void> clearAllCustomWords() async {
    await HiveService.clearAllCustomWords();
    _allCustomWords = HiveService.getAllCustomWords();
    notifyListeners();
  }
}
