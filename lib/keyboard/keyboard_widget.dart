import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../providers/settings_provider.dart';
import 'keyboard_layouts.dart';

class KeyboardWidget extends ConsumerStatefulWidget {
  const KeyboardWidget({super.key});

  @override
  ConsumerState<KeyboardWidget> createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends ConsumerState<KeyboardWidget> {
  KeyboardLanguage _currentLanguage = KeyboardLanguage.english;
  bool _isShift = false;
  bool _isCaps = false;
  bool _showSymbols = false;

  String _inputBuffer = '';
  List<CustomWord> _customSuggestions = [];
  List<String> _transliteratedSuggestions = [];

  Timer? _suggestionDebounce;
  Timer? _hiveDebounce;
  final List<String> _pendingKeyPresses = [];
  final Map<String, String> _transliterationCache = {};

  @override
  void initState() {
    super.initState();
    KeyboardController.init();

    KeyboardController.onStartInput = (info) {
      final settings = ref.read(settingsProvider);
      setState(() {
        _currentLanguage = settings.defaultLanguage;
        _isShift = false;
        _isCaps = false;
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

  List<Widget> _withGap(List<Widget> children, double gap) {
    if (children.isEmpty) return const [];
    final out = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i != children.length - 1) out.add(SizedBox(width: gap));
    }
    return out;
  }

  void _onKeyTap(String key, KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _recordKeyPressAsync(key);

    if (_showSymbols) {
      KeyboardController.inputText(key);
      return;
    }

    if (_currentLanguage == KeyboardLanguage.english) {
      final char = (_isShift || _isCaps) ? key.toUpperCase() : key;
      KeyboardController.inputText(char);

      if (_isShift && !_isCaps) {
        setState(() => _isShift = false);
      }
    } else {
      final char = _isShift ? key.toUpperCase() : key;

      setState(() {
        _inputBuffer += char;
      });

      KeyboardController.inputText(char);

      if (_isShift && !_isCaps) {
        setState(() => _isShift = false);
      }

      _updateSuggestionsDebounced(settings);
    }
  }

  void _recordKeyPressAsync(String key) {
    _pendingKeyPresses.add(key);
    _hiveDebounce?.cancel();

    _hiveDebounce = Timer(const Duration(milliseconds: 1000), () async {
      if (_pendingKeyPresses.isEmpty) return;

      final keys = List<String>.from(_pendingKeyPresses);
      _pendingKeyPresses.clear();

      try {
        for (final k in keys) {
          await HiveService.recordKeyPress(k);
        }
      } catch (e) {
        debugPrint('Error recording key press: $e');
      }
    });
  }

  void _updateSuggestionsDebounced(KeyboardSettings settings) {
    _suggestionDebounce?.cancel();
    _suggestionDebounce = Timer(const Duration(milliseconds: 50), () {
      _updateSuggestions(settings);
    });
  }

  void _updateSuggestions(KeyboardSettings settings) {
    if (_inputBuffer.isEmpty) {
      setState(() {
        _customSuggestions = [];
        _transliteratedSuggestions = [];
      });
      return;
    }

    try {
      final customSuggestions = HiveService.getSuggestions(
        _inputBuffer,
        _currentLanguage == KeyboardLanguage.hindi ? 1 : 2,
        limit: settings.suggestionCount,
      );

      final transliterator = TransliteratorFactory.getTransliterator(
        _currentLanguage,
      );

      final transliteratedSuggestions =
          transliterator?.getSuggestions(
            _inputBuffer,
            limit: settings.suggestionCount - customSuggestions.length,
          ) ??
          [];

      if (!mounted) return;
      setState(() {
        _customSuggestions = customSuggestions;
        _transliteratedSuggestions = transliteratedSuggestions;
      });
    } catch (e) {
      debugPrint('Error updating suggestions: $e');
    }
  }

  void _commitBuffer() {
    if (_inputBuffer.isEmpty) return;

    try {
      final cacheKey = _inputBuffer;

      final transliterator = TransliteratorFactory.getTransliterator(
        _currentLanguage,
      );
      final translated =
          _transliterationCache[cacheKey] ??
          (transliterator?.transliterate(_inputBuffer) ?? _inputBuffer);

      _transliterationCache[cacheKey] = translated;

      for (int i = 0; i < _inputBuffer.length; i++) {
        KeyboardController.deleteBackward();
      }
      KeyboardController.inputText(translated);

      setState(() {
        _inputBuffer = '';
        _customSuggestions = [];
        _transliteratedSuggestions = [];
      });
    } catch (e) {
      debugPrint('Error committing buffer: $e');
    }
  }

  void _onSuggestionTap(String suggestion, KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    try {
      CustomWord? customWord;
      for (final w in _customSuggestions) {
        if (w.englishWord == suggestion) {
          customWord = w;
          break;
        }
      }

      for (int i = 0; i < _inputBuffer.length; i++) {
        KeyboardController.deleteBackward();
      }

      if (customWord != null) {
        HiveService.incrementWordUsage(customWord);
        KeyboardController.inputText('${customWord.translatedWord} ');
      } else {
        final transliterator = TransliteratorFactory.getTransliterator(
          _currentLanguage,
        );
        final translated =
            _transliterationCache[suggestion] ??
            (transliterator?.transliterate(suggestion) ?? suggestion);
        _transliterationCache[suggestion] = translated;

        KeyboardController.inputText('$translated ');
      }

      setState(() {
        _inputBuffer = '';
        _customSuggestions = [];
        _transliteratedSuggestions = [];
      });
    } catch (e) {
      debugPrint('Error in onSuggestionTap: $e');
    }
  }

  void _onSpaceTap(KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }
    _commitBuffer();
    KeyboardController.inputText(' ');
  }

  void _onBackspaceTap(KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    if (_inputBuffer.isNotEmpty) {
      setState(() {
        _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
      });
      KeyboardController.deleteBackward();
      _updateSuggestionsDebounced(settings);
    } else {
      KeyboardController.deleteBackward();
    }
  }

  void _onEnterTap(KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }
    _commitBuffer();
    KeyboardController.sendKeyEvent(66);
  }

  void _onShiftTap(KeyboardSettings settings) {
    if (settings.hapticFeedback) {
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

  void _toggleLanguage(KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _commitBuffer();

    setState(() {
      final nextIndex =
          (_currentLanguage.index + 1) % KeyboardLanguage.values.length;
      _currentLanguage = KeyboardLanguage.values[nextIndex];
      _showSymbols = false;
    });
  }

  void _toggleSymbols(KeyboardSettings settings) {
    if (settings.hapticFeedback) {
      KeyboardController.vibrate();
    }

    _commitBuffer();

    setState(() {
      _showSymbols = !_showSymbols;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Watch settings from Riverpod (rebuilds on change)
    final settings = ref.watch(settingsProvider);

    // ✅ Get theme from current settings
    final theme = KeyboardTheme.fromName(settings.themeName);

    final fontFamily = _currentLanguage.fontFamily;

    final hasPreview =
        _inputBuffer.isNotEmpty && _currentLanguage != KeyboardLanguage.english;
    final hasSuggestions =
        settings.showSuggestions &&
        (_customSuggestions.isNotEmpty ||
            _transliteratedSuggestions.isNotEmpty);
    final hasNumberRow = settings.showNumberRow && !_showSymbols;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0 ? constraints.maxWidth : 360.0;

        final gap = settings.keySpacing;
        const horizontalPadding = 4.0;
        const maxKeys = 10;

        final keyWidth =
            ((width - (horizontalPadding * 2) - (gap * (maxKeys - 1))) /
                    maxKeys)
                .clamp(24.0, 80.0);

        final isLandscape =
            MediaQuery.of(context).size.width >
            MediaQuery.of(context).size.height;
        final baseKeyHeight = isLandscape
            ? settings.keyHeight * 0.85
            : settings.keyHeight;

        final screenHeight = MediaQuery.of(context).size.height;
        final adjustedKeyHeight = _getAdjustedKeyHeight(
          screenHeight: screenHeight,
          baseHeight: baseKeyHeight,
          hasPreview: hasPreview,
          hasSuggestions: hasSuggestions,
          hasNumberRow: hasNumberRow,
        );

        return Container(
          color: theme.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasPreview) _buildPreviewBar(theme, fontFamily),
              if (hasSuggestions)
                _buildSuggestionBar(settings, theme, fontFamily),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 2),
                    if (hasNumberRow)
                      _buildNumberRow(
                        settings,
                        theme,
                        keyWidth,
                        adjustedKeyHeight,
                      ),
                    ..._buildKeyRows(
                      settings,
                      theme,
                      keyWidth,
                      adjustedKeyHeight,
                      fontFamily,
                    ),
                    _buildBottomRow(
                      settings,
                      theme,
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
        );
      },
    );
  }

  double _getAdjustedKeyHeight({
    required double screenHeight,
    required double baseHeight,
    required bool hasPreview,
    required bool hasSuggestions,
    required bool hasNumberRow,
  }) {
    final maxKeyboardHeight = screenHeight * 0.40;

    double usedHeight = 0;
    if (hasPreview) usedHeight += 28;
    if (hasSuggestions) usedHeight += 32;

    final numRows = hasNumberRow ? 5 : 4;
    final spacing = numRows * 4 + 8;

    final availableForKeys = maxKeyboardHeight - usedHeight - spacing;
    final calculatedHeight = availableForKeys / numRows;

    final lower = 36.0;
    final upper = baseHeight;
    final lo = lower < upper ? lower : upper;
    final hi = upper > lower ? upper : lower;

    return calculatedHeight.clamp(lo, hi);
  }

  Widget _buildPreviewBar(KeyboardTheme theme, String? fontFamily) {
    final transliterator = TransliteratorFactory.getTransliterator(
      _currentLanguage,
    );
    final preview =
        _transliterationCache[_inputBuffer] ??
        transliterator?.transliterate(_inputBuffer) ??
        '';

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: theme.keyColor,
      child: Row(
        children: [
          Text(
            _inputBuffer,
            style: TextStyle(
              color: theme.textColor.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('→', style: TextStyle(fontSize: 10)),
          ),
          Expanded(
            child: Text(
              preview,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: fontFamily,
                color: theme.textColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionBar(
    KeyboardSettings settings,
    KeyboardTheme theme,
    String? fontFamily,
  ) {
    return SuggestionBar(
      suggestions: _customSuggestions,
      transliteratedSuggestions: _transliteratedSuggestions,
      onSuggestionTap: (s) => _onSuggestionTap(s, settings),
      theme: theme,
      fontFamily: fontFamily ?? '',
    );
  }

  Widget _buildNumberRow(
    KeyboardSettings settings,
    KeyboardTheme theme,
    double keyWidth,
    double keyHeight,
  ) {
    final gap = settings.keySpacing;

    final keys = KeyboardLayouts.numbers[0].map((key) {
      return KeyButton(
        label: key,
        onTap: () => _onKeyTap(key, settings),
        width: keyWidth,
        height: keyHeight,
        theme: theme,
        fontSize: settings.fontSize,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withGap(keys, gap),
      ),
    );
  }

  List<Widget> _buildKeyRows(
    KeyboardSettings settings,
    KeyboardTheme theme,
    double keyWidth,
    double keyHeight,
    String? fontFamily,
  ) {
    final rows = _showSymbols
        ? KeyboardLayouts.symbols
        : KeyboardLayouts.englishLetters;
    final gap = settings.keySpacing;

    return rows.asMap().entries.map((entry) {
      final rowIndex = entry.key;
      final row = entry.value;

      final children = <Widget>[
        if (!_showSymbols && rowIndex == 2)
          KeyButton(
            label: '',
            icon: _isCaps ? Icons.keyboard_capslock : Icons.arrow_upward,
            onTap: () => _onShiftTap(settings),
            width: keyWidth * 1.5,
            height: keyHeight,
            theme: theme,
            isSpecial: true,
          ),
        ...row.map((key) {
          final displayKey = (_isShift || _isCaps) && !_showSymbols
              ? key.toUpperCase()
              : key;
          return KeyButton(
            label: displayKey,
            onTap: () => _onKeyTap(key, settings),
            width: keyWidth,
            height: keyHeight,
            theme: theme,
            fontSize: settings.fontSize,
            fontFamily: _showSymbols ? null : fontFamily,
          );
        }),
        if (rowIndex == 2)
          KeyButton(
            label: '',
            icon: Icons.backspace_outlined,
            onTap: () => _onBackspaceTap(settings),
            onLongPress: () {
              for (int i = 0; i < 5; i++) {
                _onBackspaceTap(settings);
              }
            },
            width: keyWidth * 1.5,
            height: keyHeight,
            theme: theme,
            isSpecial: true,
          ),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _withGap(children, gap),
        ),
      );
    }).toList();
  }

  Widget _buildBottomRow(
    KeyboardSettings settings,
    KeyboardTheme theme,
    double keyWidth,
    double keyHeight,
    String? fontFamily,
  ) {
    final gap = settings.keySpacing;

    final children = <Widget>[
      KeyButton(
        label: _showSymbols ? 'ABC' : '123',
        onTap: () => _toggleSymbols(settings),
        width: keyWidth * 1.5,
        height: keyHeight,
        theme: theme,
        isSpecial: true,
        fontSize: 12,
      ),
      KeyButton(
        label: _currentLanguage.shortName,
        onTap: () => _toggleLanguage(settings),
        width: keyWidth * 1.2,
        height: keyHeight,
        theme: theme,
        isSpecial: true,
        fontFamily: fontFamily,
        fontSize: 12,
      ),
      KeyButton(
        label: ',',
        onTap: () => _onKeyTap(',', settings),
        width: keyWidth * 0.8,
        height: keyHeight,
        theme: theme,
      ),
      KeyButton(
        label: _currentLanguage.displayName.split(' ').last,
        onTap: () => _onSpaceTap(settings),
        width: keyWidth * 4,
        height: keyHeight,
        theme: theme,
        fontFamily: fontFamily,
        fontSize: 10,
      ),
      KeyButton(
        label: '.',
        onTap: () => _onKeyTap('.', settings),
        width: keyWidth * 0.8,
        height: keyHeight,
        theme: theme,
      ),
      KeyButton(
        label: '',
        icon: Icons.keyboard_return,
        onTap: () => _onEnterTap(settings),
        width: keyWidth * 1.5,
        height: keyHeight,
        theme: theme,
        isSpecial: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withGap(children, gap),
      ),
    );
  }
}
