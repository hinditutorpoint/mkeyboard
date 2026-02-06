package com.bhs.mkeyboard.keyboard

import android.content.Context
import android.content.SharedPreferences

class KeyboardSettings(context: Context) {

    private val prefs: SharedPreferences = context.getSharedPreferences(
        "FlutterSharedPreferences", Context.MODE_PRIVATE
    )

    private val nativePrefs: SharedPreferences = context.getSharedPreferences(
        "keyboard_native_prefs", Context.MODE_PRIVATE
    )

    val hapticFeedback: Boolean
        get() = prefs.getBoolean("flutter.hapticFeedback", true)

    val soundOnKeyPress: Boolean
        get() = prefs.getBoolean("flutter.soundOnKeyPress", false)

    val showSuggestions: Boolean
        get() = prefs.getBoolean("flutter.showSuggestions", true)

    val autoCapitalize: Boolean
        get() = prefs.getBoolean("flutter.autoCapitalize", true)

    val showNumberRow: Boolean
        get() = prefs.getBoolean("flutter.showNumberRow", true)

    val keyHeight: Float
        get() = prefs.getFloat("flutter.keyHeight", 48f)

    val fontSize: Float
        get() = prefs.getFloat("flutter.fontSize", 18f)

    val themeName: String
        get() = prefs.getString("flutter.themeName", "Light") ?: "Light"

    val defaultLanguageIndex: Int
        get() = prefs.getInt("flutter.defaultLanguageIndex", 0)

    val keySpacing: Float
        get() = prefs.getFloat("flutter.keySpacing", 4f)

    val theme: KeyboardTheme
        get() = KeyboardTheme.fromName(themeName)

    val wallpaperUrl: String?
        get() = prefs.getString("flutter.wallpaperUrl", null)

    fun setWallpaperUrl(url: String?) {
        prefs.edit().apply {
            if (url != null) {
                putString("flutter.wallpaperUrl", url)
            } else {
                remove("flutter.wallpaperUrl")
            }
            apply()
        }
    }

    /** Last used language index — persists across keyboard opens */
    var lastLanguageIndex: Int
        get() = nativePrefs.getInt("last_language_index", defaultLanguageIndex)
        set(value) {
            nativePrefs.edit().putInt("last_language_index", value).apply()
        }

    /** Whether to remember last language or always start with default */
    val rememberLastLanguage: Boolean
        get() = prefs.getBoolean("flutter.rememberLastLanguage", true)

    /** Get the language to use when keyboard opens */
    fun getStartupLanguageIndex(): Int {
        return if (rememberLastLanguage) {
            lastLanguageIndex.coerceIn(0, KeyboardLanguage.entries.size - 1)
        } else {
            defaultLanguageIndex.coerceIn(0, KeyboardLanguage.entries.size - 1)
        }
    }
}