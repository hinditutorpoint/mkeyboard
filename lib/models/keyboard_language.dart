enum KeyboardLanguage {
  english,
  hindi,
  gondi;

  String get displayName {
    switch (this) {
      case KeyboardLanguage.english:
        return 'English';
      case KeyboardLanguage.hindi:
        return 'हिंदी (Hindi)';
      case KeyboardLanguage.gondi:
        return '𑴎𑴟𑴤𑴦 𑴎𑴽𑴠𑴛𑴳 (Gondi)';
    }
  }

  String get shortName {
    switch (this) {
      case KeyboardLanguage.english:
        return 'EN';
      case KeyboardLanguage.hindi:
        return 'हि';
      case KeyboardLanguage.gondi:
        return '𑴎𑴟';
    }
  }

  String get fontFamily {
    switch (this) {
      case KeyboardLanguage.hindi:
        return 'NotoSansDevanagari';
      case KeyboardLanguage.gondi:
        return 'NotoSansMasaramGondi';
      default:
        return 'Roboto';
    }
  }
}
