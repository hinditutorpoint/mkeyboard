import 'package:flutter/material.dart';
import 'dart:async';
import 'keyboard_controller.dart';
import 'suggestion_bar.dart';
import 'key_button.dart';
import '../models/keyboard_language.dart';
import '../models/keyboard_theme.dart';
import '../models/keyboard_settings.dart';
import '../models/custom_word.dart';
import '../services/hive_service.dart';
import '../services/transliterator_factory.dart';
import 'keyboard_layouts.dart';

class KeyboardWidget extends StatefulWidget {
  const KeyboardWidget({super.key});

  @override
  State<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  KeyboardLanguage _currentLanguage = KeyboardLanguage.english;
  bool _isShift = false;
  bool _isCaps = false;
  bool _showSymbols = false;
  String _inputBuffer = '';
  List<CustomWord> _customSuggestions = [];
  List<String> _transliteratedSuggestions = [];

  KeyboardSettings _settings = KeyboardSettings();
  KeyboardTheme _theme = KeyboardTheme.light;

  // Debounce timer for suggestions
  Timer? _suggestionDebounce;

  // Debounce timer for Hive recording
  Timer? _hiveDebounce;
  final List<String> _pendingKeyPresses = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    KeyboardController.init();

    KeyboardController.onStartInput = (info) {
      _loadSettings();
      setState(() {
        _inputBuffer = '';
        _customSuggestions = [];
        _transliteratedSuggestions = [];
      });
    };
  }

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    _hiveDebounce?.cancel();
    super.dispose();
  }

  void _loadSettings() {
    _settings = HiveService.getSettings();
    _currentLanguage = _settings.defaultLanguage;
    _theme = KeyboardTheme.fromName(_settings.themeName);
    setState(() {});
  }

  void _onKeyTap(String key) {
    // Haptic feedback FIRST (instant response)
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    // Record key press asynchronously (batched)
    _recordKeyPressAsync(key);

    if (_showSymbols) {
      KeyboardController.inputText(key);
      return;
    }

    if (_currentLanguage == KeyboardLanguage.english) {
      String char = (_isShift || _isCaps) ? key.toUpperCase() : key;
      KeyboardController.inputText(char);

      if (_isShift && !_isCaps) {
        setState(() => _isShift = false);
      }
    } else {
      // TRANSLITERATION MODE
      String char = _isShift ? key.toUpperCase() : key;

      // Update buffer immediately (no setState yet)
      _inputBuffer += char;

      // Input to text field immediately for instant feedback
      KeyboardController.inputText(char);

      if (_isShift && !_isCaps) {
        _isShift = false;
      }

      // Update suggestions with debounce (non-blocking)
      _updateSuggestionsDebounced();
    }
  }

  // Batch Hive operations to reduce disk I/O
  void _recordKeyPressAsync(String key) {
    _pendingKeyPresses.add(key);

    _hiveDebounce?.cancel();
    _hiveDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (_pendingKeyPresses.isEmpty) return;

      final keys = List<String>.from(_pendingKeyPresses);
      _pendingKeyPresses.clear();

      // Run in background
      for (final k in keys) {
        await HiveService.recordKeyPress(k);
      }
    });
  }

  // Debounced suggestion update
  void _updateSuggestionsDebounced() {
    _suggestionDebounce?.cancel();
    _suggestionDebounce = Timer(const Duration(milliseconds: 150), () {
      _updateSuggestions();
    });
  }

  void _updateSuggestions() {
    if (_inputBuffer.isEmpty) {
      setState(() {
        _customSuggestions = [];
        _transliteratedSuggestions = [];
      });
      return;
    }

    // Run heavy computation in microtask (non-blocking)
    Future.microtask(() {
      final customSuggestions = HiveService.getSuggestions(
        _inputBuffer,
        _currentLanguage == KeyboardLanguage.hindi ? 1 : 2,
        limit: _settings.suggestionCount,
      );

      final transliterator = TransliteratorFactory.getTransliterator(
        _currentLanguage,
      );

      final transliteratedSuggestions =
          transliterator?.getSuggestions(
            _inputBuffer,
            limit: _settings.suggestionCount - customSuggestions.length,
          ) ??
          [];

      // Update UI only after computation
      if (mounted) {
        setState(() {
          _customSuggestions = customSuggestions;
          _transliteratedSuggestions = transliteratedSuggestions;
        });
      }
    });
  }

  void _commitBuffer() {
    if (_inputBuffer.isEmpty) return;

    final transliterator = TransliteratorFactory.getTransliterator(
      _currentLanguage,
    );
    if (transliterator != null) {
      final translated = transliterator.transliterate(_inputBuffer);

      // Delete the buffer characters we already typed
      for (int i = 0; i < _inputBuffer.length; i++) {
        KeyboardController.deleteBackward();
      }

      // Insert translated text
      KeyboardController.inputText(translated);
    }

    _inputBuffer = '';
    _customSuggestions = [];
    _transliteratedSuggestions = [];
    setState(() {});
  }

  void _onSuggestionTap(String suggestion) async {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    final customWord = _customSuggestions.firstWhere(
      (w) => w.englishWord == suggestion,
      orElse: () => CustomWord(
        englishWord: '',
        translatedWord: '',
        languageIndex: 0,
        createdAt: DateTime.now(),
      ),
    );

    if (customWord.englishWord.isNotEmpty) {
      // Delete buffer
      for (int i = 0; i < _inputBuffer.length; i++) {
        KeyboardController.deleteBackward();
      }

      // Increment usage async
      HiveService.incrementWordUsage(customWord);
      KeyboardController.inputText('${customWord.translatedWord} ');
    } else {
      final transliterator = TransliteratorFactory.getTransliterator(
        _currentLanguage,
      );
      if (transliterator != null) {
        // Delete buffer
        for (int i = 0; i < _inputBuffer.length; i++) {
          KeyboardController.deleteBackward();
        }

        final translated = transliterator.transliterate(suggestion);
        KeyboardController.inputText('$translated ');
      }
    }

    _inputBuffer = '';
    _customSuggestions = [];
    _transliteratedSuggestions = [];
    setState(() {});
  }

  void _onSpaceTap() {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _commitBuffer();
    KeyboardController.inputText(' ');
  }

  void _onBackspaceTap() {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    if (_inputBuffer.isNotEmpty) {
      _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
      KeyboardController.deleteBackward();
      _updateSuggestionsDebounced();

      // Only update preview, not entire keyboard
      setState(() {});
    } else {
      KeyboardController.deleteBackward();
    }
  }

  void _onEnterTap() {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _commitBuffer();
    KeyboardController.sendKeyEvent(66);
  }

  void _onShiftTap() {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    setState(() {
      if (_isShift) {
        _isCaps = true;
        _isShift = false;
      } else if (_isCaps) {
        _isCaps = false;
      } else {
        _isShift = true;
      }
    });
  }

  void _toggleLanguage() {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _commitBuffer();

    setState(() {
      final currentIndex = _currentLanguage.index;
      final nextIndex = (currentIndex + 1) % KeyboardLanguage.values.length;
      _currentLanguage = KeyboardLanguage.values[nextIndex];
      _showSymbols = false;
    });
  }

  void _toggleSymbols() {
    if (_settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _commitBuffer();

    setState(() {
      _showSymbols = !_showSymbols;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width > 0 ? size.width : 360.0;

    final horizontalPadding = 8.0;
    final keyPadding = 4.0;
    final maxKeysPerRow = 10.0;

    final keyWidth =
        (width - horizontalPadding - (maxKeysPerRow * keyPadding)) /
        maxKeysPerRow;
    final fontFamily = _currentLanguage.fontFamily;

    // Calculate what's visible
    final bool hasPreview =
        _inputBuffer.isNotEmpty && _currentLanguage != KeyboardLanguage.english;
    final bool hasSuggestions =
        _settings.showSuggestions &&
        (_customSuggestions.isNotEmpty ||
            _transliteratedSuggestions.isNotEmpty);
    final bool hasNumberRow = _settings.showNumberRow && !_showSymbols;

    // Dynamic key height calculation
    final double baseKeyHeight = _settings.keyHeight;
    final double adjustedKeyHeight = _getAdjustedKeyHeight(
      baseHeight: baseKeyHeight,
      hasPreview: hasPreview,
      hasSuggestions: hasSuggestions,
      hasNumberRow: hasNumberRow,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Container(
              color: _theme.backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Preview bar
                  if (hasPreview) _buildPreviewBar(fontFamily),

                  // Suggestion bar
                  if (hasSuggestions) _buildSuggestionBar(fontFamily),

                  // Keyboard content
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 2),

                        // Number row
                        if (hasNumberRow)
                          _buildNumberRow(keyWidth, adjustedKeyHeight),

                        // Letter/Symbol rows
                        ..._buildKeyRows(
                          keyWidth,
                          adjustedKeyHeight,
                          fontFamily,
                        ),

                        // Bottom row
                        _buildBottomRow(
                          keyWidth,
                          adjustedKeyHeight,
                          fontFamily,
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  double _getAdjustedKeyHeight({
    required double baseHeight,
    required bool hasPreview,
    required bool hasSuggestions,
    required bool hasNumberRow,
  }) {
    double reduction = 0;

    if (hasPreview) reduction += 6;
    if (hasSuggestions) reduction += 6;
    if (hasNumberRow) reduction += 2;

    // Clamp between 36 and 48
    return (baseHeight - reduction).clamp(36.0, 48.0);
  }

  Widget _buildPreviewBar(String? fontFamily) {
    return Container(
      width: double.infinity,
      height: 28, // Fixed compact height
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: _theme.keyColor,
      child: Row(
        children: [
          Text(
            _inputBuffer,
            style: TextStyle(
              color: _theme.textColor.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('→', style: TextStyle(fontSize: 10)),
          ),
          Expanded(
            child: Text(
              TransliteratorFactory.getTransliterator(
                    _currentLanguage,
                  )?.transliterate(_inputBuffer) ??
                  '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: fontFamily,
                color: _theme.textColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionBar(String? fontFamily) {
    return SuggestionBar(
      suggestions: _customSuggestions,
      transliteratedSuggestions: _transliteratedSuggestions,
      onSuggestionTap: _onSuggestionTap,
      theme: _theme,
      fontFamily: fontFamily ?? '',
    );
  }

  Widget _buildNumberRow(double keyWidth, double keyHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: KeyboardLayouts.numbers[0].map((key) {
          return KeyButton(
            label: key,
            onTap: () => _onKeyTap(key),
            width: keyWidth,
            height: keyHeight,
            theme: _theme,
            fontSize: _settings.fontSize,
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildKeyRows(
    double keyWidth,
    double keyHeight,
    String? fontFamily,
  ) {
    final rows = _showSymbols
        ? KeyboardLayouts.symbols
        : KeyboardLayouts.englishLetters;

    return rows.asMap().entries.map((entry) {
      int rowIndex = entry.key;
      List<String> row = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shift key on last row
            if (!_showSymbols && rowIndex == 2)
              KeyButton(
                label: '',
                icon: _isCaps ? Icons.keyboard_capslock : Icons.arrow_upward,
                onTap: _onShiftTap,
                width: keyWidth * 1.5,
                height: keyHeight,
                theme: _theme,
                isSpecial: true,
              ),

            // Letter keys
            ...row.map((key) {
              String displayKey = (_isShift || _isCaps) && !_showSymbols
                  ? key.toUpperCase()
                  : key;
              return KeyButton(
                label: displayKey,
                onTap: () => _onKeyTap(key),
                width: keyWidth,
                height: keyHeight,
                theme: _theme,
                fontSize: _settings.fontSize,
                fontFamily: _showSymbols ? null : fontFamily,
              );
            }),

            // Backspace on last row
            if (rowIndex == 2)
              KeyButton(
                label: '',
                icon: Icons.backspace_outlined,
                onTap: _onBackspaceTap,
                onLongPress: () {
                  for (int i = 0; i < 5; i++) {
                    _onBackspaceTap();
                  }
                },
                width: keyWidth * 1.5,
                height: keyHeight,
                theme: _theme,
                isSpecial: true,
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBottomRow(
    double keyWidth,
    double keyHeight,
    String? fontFamily,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KeyButton(
            label: _showSymbols ? 'ABC' : '123',
            onTap: _toggleSymbols,
            width: keyWidth * 1.5,
            height: keyHeight,
            theme: _theme,
            isSpecial: true,
            fontSize: 12,
          ),
          const SizedBox(width: 2),
          KeyButton(
            label: _currentLanguage.shortName,
            onTap: _toggleLanguage,
            width: keyWidth * 1.2,
            height: keyHeight,
            theme: _theme,
            isSpecial: true,
            fontFamily: fontFamily,
            fontSize: 12,
          ),
          const SizedBox(width: 2),
          KeyButton(
            label: ',',
            onTap: () => _onKeyTap(','),
            width: keyWidth * 0.8,
            height: keyHeight,
            theme: _theme,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: KeyButton(
              label: _currentLanguage.displayName.split(' ').last,
              onTap: _onSpaceTap,
              width: keyWidth * 4,
              height: keyHeight,
              theme: _theme,
              fontFamily: fontFamily,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 2),
          KeyButton(
            label: '.',
            onTap: () => _onKeyTap('.'),
            width: keyWidth * 0.8,
            height: keyHeight,
            theme: _theme,
          ),
          const SizedBox(width: 2),
          KeyButton(
            label: '',
            icon: Icons.keyboard_return,
            onTap: _onEnterTap,
            width: keyWidth * 1.5,
            height: keyHeight,
            theme: _theme,
            isSpecial: false,
          ),
        ],
      ),
    );
  }
}
