import 'package:flutter/material.dart';
import '../models/keyboard_theme.dart';

class KeyboardPreview extends StatelessWidget {
  final KeyboardTheme theme;

  const KeyboardPreview({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // First row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: 'qwertyuiop'.split('').map((key) {
              return _buildPreviewKey(key);
            }).toList(),
          ),
          const SizedBox(height: 4),

          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: 'asdfghjkl'.split('').map((key) {
              return _buildPreviewKey(key);
            }).toList(),
          ),
          const SizedBox(height: 4),

          // Third row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPreviewKey('⇧', isSpecial: true, width: 36),
              ...'zxcvbnm'.split('').map((key) {
                return _buildPreviewKey(key);
              }),
              _buildPreviewKey('⌫', isSpecial: true, width: 36),
            ],
          ),
          const SizedBox(height: 4),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPreviewKey('EN', isSpecial: true, width: 40),
              const SizedBox(width: 4),
              _buildPreviewKey('Space', width: 120),
              const SizedBox(width: 4),
              _buildPreviewKey('↵', isSpecial: false, width: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewKey(
    String label, {
    bool isSpecial = false,
    double width = 26,
  }) {
    return Container(
      width: width,
      height: 32,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSpecial ? theme.specialKeyColor : theme.keyColor,
        borderRadius: BorderRadius.circular(theme.keyRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: label.length > 3 ? 8 : 12,
            color: theme.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
