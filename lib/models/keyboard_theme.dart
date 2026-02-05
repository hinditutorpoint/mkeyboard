import 'package:flutter/material.dart';

class KeyboardTheme {
  final String name;
  final Color backgroundColor;
  final Color keyColor;
  final Color keyPressedColor;
  final Color textColor;
  final Color specialKeyColor;
  final Color accentColor;
  final double keyElevation;
  final double keyRadius;

  const KeyboardTheme({
    required this.name,
    required this.backgroundColor,
    required this.keyColor,
    required this.keyPressedColor,
    required this.textColor,
    required this.specialKeyColor,
    required this.accentColor,
    this.keyElevation = 2.0,
    this.keyRadius = 5.0,
  });

  static const KeyboardTheme light = KeyboardTheme(
    name: 'Light',
    backgroundColor: Color(0xFFECEFF1),
    keyColor: Colors.white,
    keyPressedColor: Color(0xFFE0E0E0),
    textColor: Colors.black87,
    specialKeyColor: Color(0xFFBDBDBD),
    accentColor: Color(0xFF2196F3),
  );

  static const KeyboardTheme dark = KeyboardTheme(
    name: 'Dark',
    backgroundColor: Color(0xFF212121),
    keyColor: Color(0xFF424242),
    keyPressedColor: Color(0xFF616161),
    textColor: Colors.white,
    specialKeyColor: Color(0xFF757575),
    accentColor: Color(0xFF64B5F6),
  );

  static const KeyboardTheme ocean = KeyboardTheme(
    name: 'Ocean',
    backgroundColor: Color(0xFF006064),
    keyColor: Color(0xFF00838F),
    keyPressedColor: Color(0xFF0097A7),
    textColor: Colors.white,
    specialKeyColor: Color(0xFF00ACC1),
    accentColor: Color(0xFF26C6DA),
  );

  static const KeyboardTheme forest = KeyboardTheme(
    name: 'Forest',
    backgroundColor: Color(0xFF1B5E20),
    keyColor: Color(0xFF2E7D32),
    keyPressedColor: Color(0xFF388E3C),
    textColor: Colors.white,
    specialKeyColor: Color(0xFF43A047),
    accentColor: Color(0xFF66BB6A),
  );

  static const KeyboardTheme sunset = KeyboardTheme(
    name: 'Sunset',
    backgroundColor: Color(0xFFBF360C),
    keyColor: Color(0xFFD84315),
    keyPressedColor: Color(0xFFE64A19),
    textColor: Colors.white,
    specialKeyColor: Color(0xFFFF5722),
    accentColor: Color(0xFFFF7043),
  );

  static const KeyboardTheme purple = KeyboardTheme(
    name: 'Purple',
    backgroundColor: Color(0xFF4A148C),
    keyColor: Color(0xFF6A1B9A),
    keyPressedColor: Color(0xFF7B1FA2),
    textColor: Colors.white,
    specialKeyColor: Color(0xFF8E24AA),
    accentColor: Color(0xFFAB47BC),
  );

  static const KeyboardTheme gradient = KeyboardTheme(
    name: 'Gradient',
    backgroundColor: Color(0xFF1A237E),
    keyColor: Color(0xFF283593),
    keyPressedColor: Color(0xFF303F9F),
    textColor: Colors.white,
    specialKeyColor: Color(0xFF3949AB),
    accentColor: Color(0xFF5C6BC0),
  );

  static const KeyboardTheme tribal = KeyboardTheme(
    name: 'Tribal',
    backgroundColor: Color(0xFF3E2723), // Dark Brown
    keyColor: Color(0xFF4E342E), // Brown
    keyPressedColor: Color(0xFF5D4037),
    textColor: Color(0xFFFFB74D), // Tribal Gold/Orange
    specialKeyColor: Color(0xFF6D4C41),
    accentColor: Color(0xFFFFCC80),
  );

  static const List<KeyboardTheme> allThemes = [
    light,
    dark,
    ocean,
    forest,
    sunset,
    purple,
    gradient,
    tribal,
  ];

  static KeyboardTheme fromName(String name) {
    return allThemes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => light,
    );
  }
}
