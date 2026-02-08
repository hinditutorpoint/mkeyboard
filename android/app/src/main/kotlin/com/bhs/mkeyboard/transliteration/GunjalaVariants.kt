package com.bhs.mkeyboard.transliteration

object GunjalaVariants {

    private val transliterator = GunjalaTransliterator()

    private val matraSuffixes = listOf(
        "aa", "i", "ee", "u", "oo", "Ri", "e", "ai", "o", "au"
    )

    fun getVariants(baseChar: String): List<String> {
        val inherent = safeTransliterate(baseChar + "a") ?: return emptyList()

        val seen = linkedSetOf<String>()

        // Inherent form
        seen += inherent

        // Matra forms (barakhadi)
        for (suffix in matraSuffixes) {
            safeTransliterate(baseChar + suffix)?.let { seen += it }
        }

        // Anusvara
        safeTransliterate(baseChar + "a.n")?.let { seen += it }

        // Visarga
        safeTransliterate(baseChar + "a.h")?.let { seen += it }

        // Halant form
        safeTransliterate(baseChar)?.let { seen += it }

        // Rakar form
        safeTransliterate(baseChar + "ra")?.let { seen += it }

        return seen.toList()
    }

    private fun safeTransliterate(raw: String): String? {
        val result = transliterator.transliterate(raw, isComposing = false)
        return result.takeIf { it.isNotBlank() && it != raw }
    }
}