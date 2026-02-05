import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeyboardController {
  static const MethodChannel _channel = MethodChannel(
    'com.bhs.mkeyboard/keyboard',
  );

  static const MethodChannel _settingsChannel = MethodChannel(
    'com.bhs.mkeyboard/settings',
  );

  // Callbacks
  static void Function(Map<String, dynamic>)? onStartInput;
  static void Function()? onFinishInput;
  static void Function(int start, int end)? onSelectionChanged;

  static void init() {
    _channel.setMethodCallHandler((call) async {
      try {
        switch (call.method) {
          case 'onStartInput':
            final args = Map<String, dynamic>.from(call.arguments ?? {});
            onStartInput?.call(args);
            break;
          case 'onFinishInput':
            onFinishInput?.call();
            break;
          case 'onSelectionChanged':
            final args = Map<String, dynamic>.from(call.arguments ?? {});
            final start = args['start'] as int? ?? 0;
            final end = args['end'] as int? ?? 0;
            onSelectionChanged?.call(start, end);
            break;
        }
      } catch (e) {
        debugPrint('Error handling method call: $e');
      }
      return null;
    });
  }

  // Input methods
  static Future<void> inputText(String text) async {
    try {
      await _channel.invokeMethod('inputText', {'text': text});
    } catch (e) {
      debugPrint('Error inputting text: $e');
    }
  }

  static Future<void> deleteBackward() async {
    try {
      await _channel.invokeMethod('deleteBackward');
    } catch (e) {
      debugPrint('Error deleting backward: $e');
    }
  }

  static Future<void> deleteForward() async {
    try {
      await _channel.invokeMethod('deleteForward');
    } catch (e) {
      debugPrint('Error deleting forward: $e');
    }
  }

  static Future<void> sendKeyEvent(int keyCode) async {
    try {
      await _channel.invokeMethod('sendKeyEvent', {'keyCode': keyCode});
    } catch (e) {
      debugPrint('Error sending key event: $e');
    }
  }

  static Future<void> vibrate({int duration = 50}) async {
    try {
      await _channel.invokeMethod('vibrate', {'duration': duration});
    } catch (e) {
      debugPrint('Error vibrating: $e');
    }
  }

  static Future<void> hideKeyboard() async {
    try {
      await _channel.invokeMethod('hideKeyboard');
    } catch (e) {
      debugPrint('Error hiding keyboard: $e');
    }
  }

  static Future<void> switchLanguage() async {
    try {
      await _channel.invokeMethod('switchLanguage');
    } catch (e) {
      debugPrint('Error switching language: $e');
    }
  }

  static Future<String> getInputText() async {
    try {
      return await _channel.invokeMethod('getInputText') ?? '';
    } catch (e) {
      debugPrint('Error getting input text: $e');
      return '';
    }
  }

  static Future<void> selectAll() async {
    try {
      await _channel.invokeMethod('selectAll');
    } catch (e) {
      debugPrint('Error selecting all: $e');
    }
  }

  static Future<void> moveCursor(int offset) async {
    try {
      await _channel.invokeMethod('moveCursor', {'offset': offset});
    } catch (e) {
      debugPrint('Error moving cursor: $e');
    }
  }

  // Settings methods
  static Future<void> openKeyboardSettings() async {
    try {
      await _settingsChannel.invokeMethod('openKeyboardSettings');
    } catch (e) {
      debugPrint('Error opening keyboard settings: $e');
    }
  }

  static Future<void> openInputMethodPicker() async {
    try {
      await _settingsChannel.invokeMethod('openInputMethodPicker');
    } catch (e) {
      debugPrint('Error opening input method picker: $e');
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

  static Future<void> startVoiceInput() async {
    try {
      await _channel.invokeMethod('startVoiceInput');
    } catch (e) {
      debugPrint('Error starting voice input: $e');
    }
  }
}
