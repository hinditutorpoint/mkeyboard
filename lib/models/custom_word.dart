import 'package:hive/hive.dart';

part 'custom_word.g.dart';

@HiveType(typeId: 1)
class CustomWord extends HiveObject {
  @HiveField(0)
  final String englishWord;

  @HiveField(1)
  final String translatedWord;

  @HiveField(2)
  final int languageIndex; // 1: Hindi, 2: Gondi

  @HiveField(3)
  final int usageCount;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? lastUsed;

  @HiveField(6)
  final bool isPinned;

  CustomWord({
    required this.englishWord,
    required this.translatedWord,
    required this.languageIndex,
    this.usageCount = 0,
    required this.createdAt,
    this.lastUsed,
    this.isPinned = false,
  });

  CustomWord copyWith({
    String? englishWord,
    String? translatedWord,
    int? languageIndex,
    int? usageCount,
    DateTime? createdAt,
    DateTime? lastUsed,
    bool? isPinned,
  }) {
    return CustomWord(
      englishWord: englishWord ?? this.englishWord,
      translatedWord: translatedWord ?? this.translatedWord,
      languageIndex: languageIndex ?? this.languageIndex,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
