package com.bhs.mkeyboard.keyboard

/**
 * Keyboard layouts for English, Hindi, and Gondi
 */
object KeyboardLayouts {
    
    val englishLetters = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("z", "x", "c", "v", "b", "n", "m")
    )
    
    val hindiLetters = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("z", "x", "c", "v", "b", "n", "m")
    )

    val gondiLetters = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("z", "x", "c", "v", "b", "n", "m")
    )
    
    val numbers = listOf(
        listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    )
    
    // Page 1: Numbers + Common Symbols (Gboard Style)
    val symbols1 = listOf(
        listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
        listOf("@", "#", "₹", "_", "&", "-", "+", "(", ")", "/"),
        listOf("*", "\"", "'", ":", ";", "!", "?")
    )

    // Page 2: More Symbols (Gboard Style)
    val symbols2 = listOf(
        listOf("~", "`", "|", "•", "√", "π", "÷", "×", "§", "∆"),
        listOf("£", "¢", "€", "¥", "^", "°", "=", "{", "}", "\\"),
        listOf("%", "©", "®", "™", "✓", "[", "]", "<", ">")
    )
}

/**
 * Keyboard language enum
 */
enum class KeyboardLanguage(val displayName: String, val fontFamily: String?) {
    ENGLISH("EN", null),
    HINDI("हिं", null),
    GONDI("𑴌𑴽", "MasaramGondi");
    
    fun next(): KeyboardLanguage {
        val values = entries
        val nextIndex = (ordinal + 1) % values.size
        return values[nextIndex]
    }
}
