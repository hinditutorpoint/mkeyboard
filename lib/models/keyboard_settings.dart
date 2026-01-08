import 'package:hive/hive.dart';
import 'keyboard_language.dart';

part 'keyboard_settings.g.dart';

@HiveType(typeId: 0)
class KeyboardSettings extends HiveObject {
  @HiveField(0)
  final bool hapticFeedback;

  @HiveField(1)
  final bool soundOnKeyPress;

  @HiveField(2)
  final bool showSuggestions;

  @HiveField(3)
  final bool autoCapitalize;

  @HiveField(4)
  final bool showNumberRow;

  @HiveField(5)
  final double keyHeight;

  @HiveField(6)
  final double fontSize;

  @HiveField(7)
  final String themeName;

  @HiveField(8)
  final int defaultLanguageIndex; // 0: English, 1: Hindi, 2: Gondi

  @HiveField(9)
  final bool swipeToDelete;

  @HiveField(10)
  final bool longPressForSymbols;

  @HiveField(11)
  final int suggestionCount;

  @HiveField(12)
  final bool showPreview;

  @HiveField(13)
  final double keySpacing;

  @HiveField(14)
  final bool enableGlideTyping;

  KeyboardSettings({
    this.hapticFeedback = true,
    this.soundOnKeyPress = false,
    this.showSuggestions = true,
    this.autoCapitalize = true,
    this.showNumberRow = true,
    this.keyHeight = 42.0,
    this.fontSize = 16.0,
    this.themeName = 'Light',
    this.defaultLanguageIndex = 0,
    this.swipeToDelete = true,
    this.longPressForSymbols = true,
    this.suggestionCount = 5,
    this.showPreview = true,
    this.keySpacing = 4.0,
    this.enableGlideTyping = false,
  });

  KeyboardLanguage get defaultLanguage {
    return KeyboardLanguage.values[defaultLanguageIndex];
  }

  KeyboardSettings copyWith({
    bool? hapticFeedback,
    bool? soundOnKeyPress,
    bool? showSuggestions,
    bool? autoCapitalize,
    bool? showNumberRow,
    double? keyHeight,
    double? fontSize,
    String? themeName,
    int? defaultLanguageIndex,
    bool? swipeToDelete,
    bool? longPressForSymbols,
    int? suggestionCount,
    bool? showPreview,
    double? keySpacing,
    bool? enableGlideTyping,
  }) {
    return KeyboardSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundOnKeyPress: soundOnKeyPress ?? this.soundOnKeyPress,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      autoCapitalize: autoCapitalize ?? this.autoCapitalize,
      showNumberRow: showNumberRow ?? this.showNumberRow,
      keyHeight: keyHeight ?? this.keyHeight,
      fontSize: fontSize ?? this.fontSize,
      themeName: themeName ?? this.themeName,
      defaultLanguageIndex: defaultLanguageIndex ?? this.defaultLanguageIndex,
      swipeToDelete: swipeToDelete ?? this.swipeToDelete,
      longPressForSymbols: longPressForSymbols ?? this.longPressForSymbols,
      suggestionCount: suggestionCount ?? this.suggestionCount,
      showPreview: showPreview ?? this.showPreview,
      keySpacing: keySpacing ?? this.keySpacing,
      enableGlideTyping: enableGlideTyping ?? this.enableGlideTyping,
    );
  }
}
