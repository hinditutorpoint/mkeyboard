package com.bhs.mkeyboard.transliteration

object ChikiVariants {

    private val transliterator = ChikiTransliterator()

    // Ol Chiki vowels to combine with consonants
    private val vowelSuffixes = listOf(
        "a", "aa", "i", "ee", "u", "oo", "e", "ai", "o", "au"
    )

    fun getVariants(baseChar: String): List<String> {
        // Ol Chiki is alphabetic — variants are consonant + vowel combinations
        val base = safeTransliterate(baseChar) ?: return emptyList()

        val seen = linkedSetOf<String>()

        // Base consonant alone
        seen += base

        // Consonant + each vowel (ka, kaa, ki, kee, ku, koo, ke, kai, ko, kau)
        for (suffix in vowelSuffixes) {
            safeTransliterate(baseChar + suffix)?.let { seen += it }
        }

        // Aspirated variant if exists (k → kh)
        safeTransliterate(baseChar + "h")?.let { variant ->
            // Only add if it's different from base + "h" vowel
            if (variant != base) seen += variant
        }

        // Nasalized form
        safeTransliterate(baseChar + "a.n")?.let { seen += it }

        return seen.toList()
    }

    private fun safeTransliterate(raw: String): String? {
        val result = transliterator.transliterate(raw, isComposing = false)
        return result.takeIf { it.isNotBlank() && it != raw }
    }
}