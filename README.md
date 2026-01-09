# MKeyboard ⌨️

**MKeyboard** is a lightweight, privacy-focused, and highly customizable Flutter-based Android Input Method (IME). It supports seamless English-to-Hindi transliteration and includes specialized support for the Gondi language.

---

## ✨ Features

- **🚀 Smart Transliteration**: Type in English (Hinglish) and get instant Devanagari suggestions.
- **🗣️ Language Support**: Fully optimized for Hindi and Gondi languages.
- **🎨 Premium Themes**: Choose between sleek light and dark modes with glassmorphic effects.
- **💾 Custom Dictionary**: Save your frequent words and manage your own vocabulary.
- **📊 Usage Analytics**: Track your typing stats and most used keys (saved locally).
- **🔋 Performance Optimized**: Batched disk operations and debounced suggestions for a lag-free experience.
- **🔒 Privacy First**: All data (settings, custom words) remains on your device via Hive's encrypted storage.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **Database**: [Hive](https://pub.dev/packages/hive) (Process-safe local storage)
- **Native**: Kotlin (InputMethodService API)
- **Animation**: Flutter AnimatedBuilder for responsive key feedback

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / VS Code
- Android Device (API level 21+)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/mkeyboard.git
   cd mkeyboard
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Build and Run**:
   ```bash
   flutter run --release
   ```

### Enabling the Keyboard

1. Open the **MKeyboard** app.
2. Follow the setup wizard:
   - Click "Enable Keyboard" and toggle MKeyboard ON in System Settings.
   - Click "Switch Keyboard" and select MKeyboard as your default input method.

---

## 🍱 Support My Work

If you find this keyboard helpful, please consider supporting the project to help keep it ad-free and open-source!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hinditutorpoint)

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Developed with ❤️ by [Hindi Tutor Point](https://buymeacoffee.com/hinditutorpoint)
