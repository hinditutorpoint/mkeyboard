import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class FontSupportChecker {
  // Check if device supports Masaram Gondi rendering
  static Future<bool> supportsMasaramGondi() async {
    try {
      // Test character: 𑴀 (Masaram Gondi Letter A)
      const testChar = '\u{11D00}';

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: testChar,
          style: const TextStyle(
            fontFamily: 'NotoSansMasaramGondi',
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset.zero);

      final picture = recorder.endRecording();
      final img = await picture.toImage(50, 50);
      final data = await img.toByteData();

      // If rendering worked, we have byte data
      return data != null && data.lengthInBytes > 0;
    } catch (e) {
      debugPrint('Font support check failed: $e');
      return false;
    }
  }

  // Check if text contains Gondi characters
  static bool containsGondiCharacters(String text) {
    // Masaram Gondi Unicode range: U+11D00–U+11D5F
    final gondiRegex = RegExp(r'[\u{11D00}-\u{11D5F}]', unicode: true);
    return gondiRegex.hasMatch(text);
  }

  // Check if text contains Hindi characters
  static bool containsHindiCharacters(String text) {
    // Devanagari Unicode range: U+0900–U+097F
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }
}
