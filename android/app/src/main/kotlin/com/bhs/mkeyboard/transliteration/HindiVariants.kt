package com.bhs.mkeyboard.transliteration

object HindiVariants {

    private val transliterator = HindiTransliterator()

    private val matraSuffixes = listOf(
        "aa", "i", "ee", "u", "oo", "Ri", "e", "ai", "o", "au"
    )

    private val nuktaForms = mapOf(
        "k" to "q", "g" to "G", "j" to "z",
        "D" to ".D", "Dh" to ".Dh", "f" to ".f"
    )

    fun getVariants(baseChar: String): List<String> {
        val inherent = safeTransliterate(baseChar + "a") ?: return emptyList()

        val seen = linkedSetOf<String>()

        // Inherent form (ka, ga, etc.)
        seen += inherent

        // Matra forms (kaa, ki, kee, ku, koo, kRi, ke, kai, ko, kau)
        for (suffix in matraSuffixes) {
            safeTransliterate(baseChar + suffix)?.let { seen += it }
        }

        // Anusvara (kaM -> कं)
        safeTransliterate(baseChar + "a.n")?.let { seen += it }

        // Chandrabindu (ka.N -> कँ)
        safeTransliterate(baseChar + "a.N")?.let { seen += it }

        // Visarga (ka.h -> कः)
        safeTransliterate(baseChar + "a.h")?.let { seen += it }

        // Halant form (k -> क्)
        safeTransliterate(baseChar)?.let { seen += it }

        // Nukta form if applicable (k -> q -> क़)
        nuktaForms[baseChar]?.let { nuktaKey ->
            safeTransliterate(nuktaKey + "a")?.let { seen += it }
        }

        return seen.toList()
    }

    private fun safeTransliterate(raw: String): String? {
        val result = transliterator.transliterate(raw)
        return result.takeIf { it.isNotBlank() && it != raw }
    }
}