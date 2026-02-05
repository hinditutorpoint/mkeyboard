package com.bhs.mkeyboard.keyboard

import android.content.Context
import android.content.SharedPreferences

/**
 * Keyboard settings - reads from SharedPreferences (synced from Flutter app)
 */
class KeyboardSettings(context: Context) {
    
    private val prefs: SharedPreferences = context.getSharedPreferences(
        "FlutterSharedPreferences", Context.MODE_PRIVATE
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
}
