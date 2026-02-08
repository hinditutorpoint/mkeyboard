package com.bhs.mkeyboard.keyboard

/**
 * Keyboard layouts for English, Hindi, Gondi, Gunjala Gondi, and Ol Chiki
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

    val gunjalaLetters = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("z", "x", "c", "v", "b", "n", "m")
    )

    val chikiLetters = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("z", "x", "c", "v", "b", "n", "m")
    )

    // ── NUMBER ROWS ─────────────────────────────────────────────
    val numbers = listOf(
        listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    )

    val gondiNumbers = listOf(
        listOf("𑵑", "𑵒", "𑵓", "𑵔", "𑵕", "𑵖", "𑵗", "𑵘", "𑵙", "𑵐")
    )

    // Gunjala Gondi Digits: U+11DA0–U+11DA9
    val gunjalaNumbers = listOf(
        listOf("𑶡", "𑶢", "𑶣", "𑶤", "𑶥", "𑶦", "𑶧", "𑶨", "𑶩", "𑶠")
    )

    // Ol Chiki Digits: U+1C50–U+1C59 (BMP - no surrogates needed)
    val chikiNumbers = listOf(
        listOf("᱑", "᱒", "᱓", "᱔", "᱕", "᱖", "᱗", "᱘", "᱙", "᱐")
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

    // ── SYMBOL PAGES ────────────────────────────────────────────
    // Page 1: Numbers + Common Symbols
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

    val gunjalaSymbols1 = listOf(
        listOf("𑶡", "𑶢", "𑶣", "𑶤", "𑶥", "𑶦", "𑶧", "𑶨", "𑶩", "𑶠"),
        listOf("@", "#", "₹", "_", "&", "-", "+", "(", ")", "/"),
        listOf("*", "\"", "'", ":", ";", "!", "?")
    )

    val chikiSymbols1 = listOf(
        listOf("᱑", "᱒", "᱓", "᱔", "᱕", "᱖", "᱗", "᱘", "᱙", "᱐"),
        listOf("@", "#", "₹", "_", "&", "-", "+", "(", ")", "/"),
        listOf("*", "\"", "'", ":", ";", "!", "?")
    )

    // Page 2: More Symbols (shared across all languages)
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
    GONDI("𑴌𑴽", "MasaramGondi"),
    GUNJALA("గొ", "GunjalaGondi"),
    CHIKI("ᱚᱞ", "OlChiki");

    fun next(): KeyboardLanguage {
        val values = entries
        val nextIndex = (ordinal + 1) % values.size
        return values[nextIndex]
    }
}