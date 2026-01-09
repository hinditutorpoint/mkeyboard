import 'package:flutter_riverpod/legacy.dart';
import '../models/keyboard_language.dart';
import '../models/custom_word.dart';

// Keyboard state
class KeyboardState {
  final KeyboardLanguage currentLanguage;
  final bool isShift;
  final bool isCaps;
  final bool showSymbols;
  final String inputBuffer;
  final List<CustomWord> customSuggestions;
  final List<String> transliteratedSuggestions;

  const KeyboardState({
    this.currentLanguage = KeyboardLanguage.english,
    this.isShift = false,
    this.isCaps = false,
    this.showSymbols = false,
    this.inputBuffer = '',
    this.customSuggestions = const [],
    this.transliteratedSuggestions = const [],
  });

  KeyboardState copyWith({
    KeyboardLanguage? currentLanguage,
    bool? isShift,
    bool? isCaps,
    bool? showSymbols,
    String? inputBuffer,
    List<CustomWord>? customSuggestions,
    List<String>? transliteratedSuggestions,
  }) {
    return KeyboardState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isShift: isShift ?? this.isShift,
      isCaps: isCaps ?? this.isCaps,
      showSymbols: showSymbols ?? this.showSymbols,
      inputBuffer: inputBuffer ?? this.inputBuffer,
      customSuggestions: customSuggestions ?? this.customSuggestions,
      transliteratedSuggestions:
          transliteratedSuggestions ?? this.transliteratedSuggestions,
    );
  }
}

// Keyboard state notifier
class KeyboardStateNotifier extends StateNotifier<KeyboardState> {
  KeyboardStateNotifier() : super(const KeyboardState());

  void setLanguage(KeyboardLanguage language) {
    state = state.copyWith(
      currentLanguage: language,
      showSymbols: false,
      inputBuffer: '',
      customSuggestions: [],
      transliteratedSuggestions: [],
    );
  }

  void toggleShift() {
    if (state.isShift) {
      state = state.copyWith(isCaps: true, isShift: false);
    } else if (state.isCaps) {
      state = state.copyWith(isCaps: false);
    } else {
      state = state.copyWith(isShift: true);
    }
  }

  void resetShift() {
    if (state.isShift && !state.isCaps) {
      state = state.copyWith(isShift: false);
    }
  }

  void toggleSymbols() {
    state = state.copyWith(showSymbols: !state.showSymbols);
  }

  void updateBuffer(String buffer) {
    state = state.copyWith(inputBuffer: buffer);
  }

  void clearBuffer() {
    state = state.copyWith(
      inputBuffer: '',
      customSuggestions: [],
      transliteratedSuggestions: [],
    );
  }

  void updateSuggestions({
    List<CustomWord>? custom,
    List<String>? transliterated,
  }) {
    state = state.copyWith(
      customSuggestions: custom,
      transliteratedSuggestions: transliterated,
    );
  }

  void reset() {
    state = const KeyboardState();
  }
}

// Provider
final keyboardStateProvider =
    StateNotifierProvider<KeyboardStateNotifier, KeyboardState>((ref) {
      return KeyboardStateNotifier();
    });
