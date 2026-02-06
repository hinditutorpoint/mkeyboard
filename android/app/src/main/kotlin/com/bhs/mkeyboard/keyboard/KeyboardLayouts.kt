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

    val gondiNumbers = listOf(
        listOf("𑵑", "𑵒", "𑵓", "𑵔", "𑵕", "𑵖", "𑵗", "𑵘", "𑵙", "𑵐")
    )

    // ── NUMBER PAD LAYOUT (for number input fields) ─────────────
    val numberPad = listOf(
        listOf("1", "2", "3"),
        listOf("4", "5", "6"),
        listOf("7", "8", "9"),
        listOf("*", "0", "#")
    )

    // ── PHONE PAD LAYOUT (for phone number fields) ──────────────
    val phonePad = listOf(
        listOf("1", "2", "3"),
        listOf("4", "5", "6"),
        listOf("7", "8", "9"),
        listOf("+", "0", ",")
    )
    
    // Page 1: Numbers + Common Symbols (Gboard Style)
    val symbols1 = listOf(
        listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
        listOf("@", "#", "₹", "_", "&", "-", "+", "(", ")", "/"),
        listOf("*", "\"", "'", ":", ";", "!", "?")
    )

    val gondiSymbols1 = listOf(
        listOf("𑵑", "𑵒", "𑵓", "𑵔", "𑵕", "𑵖", "𑵗", "𑵘", "𑵙", "𑵐"),
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
