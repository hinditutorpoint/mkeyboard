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

  // Check if device supports Gunjala Gondi rendering
  static Future<bool> supportsGunjalaGondi() async {
    try {
      // Test character: 𑴀 (Gunjala Gondi Letter A)
      const testChar = '\u{11D60}';

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: testChar,
          style: const TextStyle(
            fontFamily: 'NotoSansGunjalaGondi',
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

  // Check if device supports Ol Chiki rendering
  static Future<bool> supportsOlChiki() async {
    try {
      // Test character: ᱚ (Ol Chiki Letter O)
      const testChar = '\u{1C50}';

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: testChar,
          style: const TextStyle(fontFamily: 'NotoSansOlChiki', fontSize: 20),
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

  // Check if text contains Gunjala Gondi characters
  static bool containsGunjalaGondiCharacters(String text) {
    // Gunjala Gondi Unicode range: U+11D60–U+11DFF
    final gunjalaRegex = RegExp(r'[\u{11D60}-\u{11DFF}]', unicode: true);
    return gunjalaRegex.hasMatch(text);
  }

  // Check if text contains Ol Chiki (Santali) characters
  static bool containsOlChikiCharacters(String text) {
    // Ol Chiki Unicode range: U+1C50–U+1C7F
    final olChikiRegex = RegExp(r'[\u{1C50}-\u{1C7F}]', unicode: true);
    return olChikiRegex.hasMatch(text);
  }

  // Check if text contains Hindi characters
  static bool containsHindiCharacters(String text) {
    // Devanagari Unicode range: U+0900–U+097F
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    return hindiRegex.hasMatch(text);
  }
}
