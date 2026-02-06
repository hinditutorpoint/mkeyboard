import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SystemService {
  static const MethodChannel _settingsChannel = MethodChannel(
    'com.bhs.mkeyboard/settings',
  );

  static Future<void> openKeyboardSettings() async {
    try {
      await _settingsChannel.invokeMethod('openKeyboardSettings');
    } catch (e) {
      debugPrint('Error opening keyboard settings: $e');
    }
  }

  static Future<void> showInputMethodPicker() async {
    try {
      // MainActivity listens for 'showInputMethodPicker'
      await _settingsChannel.invokeMethod('showInputMethodPicker');
    } catch (e) {
      debugPrint('Error showing input method picker: $e');
    }
  }

  static Future<bool> isKeyboardEnabled() async {
    try {
      final result = await _settingsChannel.invokeMethod('isKeyboardEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking if keyboard enabled: $e');
      return false;
    }
  }

  static Future<bool> isKeyboardSelected() async {
    try {
      final result = await _settingsChannel.invokeMethod('isKeyboardSelected');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking if keyboard selected: $e');
      return false;
    }
  }
}
