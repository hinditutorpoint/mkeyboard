package com.bhs.mkeyboard.keyboard

import androidx.compose.ui.graphics.Color

/**
 * Keyboard theme data class - mirrors Flutter KeyboardTheme
 */
data class KeyboardTheme(
    val name: String,
    val backgroundColor: Color,
    val keyColor: Color,
    val keyPressedColor: Color,
    val textColor: Color,
    val specialKeyColor: Color,
    val accentColor: Color,
    val keyElevation: Float = 2f,
    val keyRadius: Float = 5f
) {
    companion object {
        val Light = KeyboardTheme(
            name = "Light",
            backgroundColor = Color(0xFFECEFF1),
            keyColor = Color.White,
            keyPressedColor = Color(0xFFE0E0E0),
            textColor = Color(0xFF212121),
            specialKeyColor = Color(0xFFBDBDBD),
            accentColor = Color(0xFF2196F3)
        )

        val Dark = KeyboardTheme(
            name = "Dark",
            backgroundColor = Color(0xFF212121),
            keyColor = Color(0xFF424242),
            keyPressedColor = Color(0xFF616161),
            textColor = Color.White,
            specialKeyColor = Color(0xFF757575),
            accentColor = Color(0xFF64B5F6)
        )

        val Ocean = KeyboardTheme(
            name = "Ocean",
            backgroundColor = Color(0xFF006064),
            keyColor = Color(0xFF00838F),
            keyPressedColor = Color(0xFF0097A7),
            textColor = Color.White,
            specialKeyColor = Color(0xFF00ACC1),
            accentColor = Color(0xFF26C6DA)
        )

        val Forest = KeyboardTheme(
            name = "Forest",
            backgroundColor = Color(0xFF1B5E20),
            keyColor = Color(0xFF2E7D32),
            keyPressedColor = Color(0xFF388E3C),
            textColor = Color.White,
            specialKeyColor = Color(0xFF43A047),
            accentColor = Color(0xFF66BB6A)
        )

        val Sunset = KeyboardTheme(
            name = "Sunset",
            backgroundColor = Color(0xFFBF360C),
            keyColor = Color(0xFFD84315),
            keyPressedColor = Color(0xFFE64A19),
            textColor = Color.White,
            specialKeyColor = Color(0xFFFF5722),
            accentColor = Color(0xFFFF7043)
        )

        val Purple = KeyboardTheme(
            name = "Purple",
            backgroundColor = Color(0xFF4A148C),
            keyColor = Color(0xFF6A1B9A),
            keyPressedColor = Color(0xFF7B1FA2),
            textColor = Color.White,
            specialKeyColor = Color(0xFF8E24AA),
            accentColor = Color(0xFFAB47BC)
        )

        val Tribal = KeyboardTheme(
            name = "Tribal",
            backgroundColor = Color(0xFF3E2723), // Dark Brown
            keyColor = Color(0xFF4E342E), // Brown
            keyPressedColor = Color(0xFF5D4037),
            textColor = Color(0xFFFFB74D), // Tribal Gold/Orange
            specialKeyColor = Color(0xFF6D4C41),
            accentColor = Color(0xFFFFCC80)
        )

        val allThemes = listOf(Light, Dark, Ocean, Forest, Sunset, Purple, Tribal)

        fun fromName(name: String): KeyboardTheme {
            return allThemes.find { it.name == name } ?: Light
        }
    }
}
