import 'package:flutter/material.dart';
import '../models/custom_word.dart';
import '../models/keyboard_theme.dart';

class SuggestionBar extends StatelessWidget {
  final List<CustomWord> suggestions;
  final List<String> transliteratedSuggestions;
  final Function(String) onSuggestionTap;
  final KeyboardTheme theme;
  final String fontFamily;

  const SuggestionBar({
    super.key,
    required this.suggestions,
    required this.transliteratedSuggestions,
    required this.onSuggestionTap,
    required this.theme,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty && transliteratedSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32, // Compact fixed height
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        itemCount: suggestions.length + transliteratedSuggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index < suggestions.length) {
            final suggestion = suggestions[index];
            return _buildChip(
              text: suggestion.translatedWord,
              english: suggestion.englishWord,
              isPinned: suggestion.isPinned,
            );
          } else {
            final tIndex = index - suggestions.length;
            final word = transliteratedSuggestions[tIndex];
            return _buildChip(text: word, english: word, isPinned: false);
          }
        },
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required String english,
    required bool isPinned,
  }) {
    return Center(
      child: Material(
        color: theme.keyColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        child: InkWell(
          onTap: () => onSuggestionTap(english),
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.keyPressedColor.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPinned)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.push_pin,
                      size: 10,
                      color: theme.accentColor,
                    ),
                  ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: fontFamily,
                    color: theme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
