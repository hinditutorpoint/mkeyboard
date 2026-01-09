import '../models/custom_word.dart';
import '../models/keyboard_language.dart';
import '../services/hive_service.dart';

class SuggestionLoader {
  static final Map<String, List<CustomWord>> _searchCache = {};

  /// Fast prefix search from Hive (NO JSON)
  static List<CustomWord> search(
    String query,
    KeyboardLanguage language, {
    int limit = 5,
  }) {
    if (query.isEmpty) return [];

    final cacheKey = '${language.index}:$query:$limit';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final lowerQuery = query.toLowerCase();

    // Get from Hive
    final allWords = HiveService.getAllCustomWords(
      languageIndex: language == KeyboardLanguage.hindi ? 1 : 2,
    );

    // Prefix match
    final matches = allWords
        .where(
          (word) =>
              word.englishWord.toLowerCase().startsWith(lowerQuery) ||
              word.translatedWord.toLowerCase().startsWith(lowerQuery),
        )
        .toList();

    // Sort by usage
    matches.sort((a, b) => b.usageCount.compareTo(a.usageCount));

    final results = matches.take(limit).toList();

    // Cache
    _searchCache[cacheKey] = results;

    // Limit cache
    if (_searchCache.length > 200) {
      _searchCache.clear();
    }

    return results;
  }

  /// Pre-load nothing - it's already in Hive
  static Future<void> preloadAll() async {
    // No-op: Data already in Hive from init
    print('✓ Suggestions ready (using Hive)');
  }

  /// Check if loaded
  static bool isLoaded(KeyboardLanguage language) {
    return true; // Always loaded from Hive
  }

  /// Clear cache only
  static void clearCache() {
    _searchCache.clear();
  }
}
