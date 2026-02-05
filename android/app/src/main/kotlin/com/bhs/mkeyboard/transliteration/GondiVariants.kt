package com.bhs.mkeyboard.transliteration

object GondiVariants {
    
    // Matras (Dependent Vowel Signs)
    private val matras = mapOf(
        "a" to "",        // Inherent
        "ā" to "𑴱",      // aa
        "i" to "𑴲",      // i
        "ī" to "𑴳",      // ii
        "u" to "𑴴",      // u
        "ū" to "𑴵",      // uu
        "ṛ" to "𑴶",      // ri
        "e" to "𑴺",      // e
        "ai" to "𑴼",     // ai
        "o" to "𑴽",      // o
        "au" to "𑴿",     // au
        "ṃ" to "𑵀",      // anusvara
        "ḥ" to "𑵁"       // visarga
    )
    
    // Common conjunct formers
    private val conjuncts = listOf(
        "k", "g", "c", "j", "t", "d", "n", "p", "b", "m", "y", "r", "l", "v", "s", "h", "ṣ"
    )

    fun getVariants(baseChar: String): List<String> {
        // Map input char to Gondi script if needed, but assuming input is already English transliteration key like "k"
        // But the key labels in layout are "k", "g", etc.
        // Wait, layout keys are English chars "k", "g".
        // The output should be Gondi text.
        
        // We need the transliterator to convert the combinations.
        // But since we are in separate package, we can just use the characters directly if we know the mapping.
        // Or better: reuse GondiTransliterator instance?
        val transliterator = GondiTransliterator()
        val gondiBase = transliterator.transliterate(baseChar)
        
        if (gondiBase.isEmpty()) return emptyList()

        val variants = mutableListOf<String>()
        
        // 1. CV Syllables (Base + Matras)
        // Order: ka, kā, ki, kī, ku, kū, kṛ, ke, kai, ko, kau, kaṃ, kaḥ
        
        // ka (inherent)
        variants.add(gondiBase)
        
        // Matras
        val matraKeys = listOf("ā", "i", "ī", "u", "ū", "ṛ", "e", "ai", "o", "au")
        for (m in matraKeys) {
            variants.add(gondiBase + (matras[m] ?: ""))
        }
        
        // Anusvara/Visarga on inherent 'a'
        variants.add(gondiBase + GondiTransliterator.ANUSVARA) // kaṃ
        variants.add(gondiBase + GondiTransliterator.VISARGA) // kaḥ
        
        // 2. Conjuncts
        // Format: Base + Virama + Other
        // Special: Repha (r + Base), Rakar (Base + r)
        
        // Rakar (kra) -> Base + Rakar
        variants.add(gondiBase + GondiTransliterator.RAKAR)
        
        // Repha (arka) -> Repha + Base (Display might be tricky, usually displayed combined)
        // Actually Repha usually comes *before* but visually on top.
        // Let's add it: Repha + Base
        variants.add(GondiTransliterator.REPHA + gondiBase)
        
        // Ksha (k + sha), Tra, Gya are special but user wants general conjuncts list "kka, kkha..."
        // Generating all possible conjuncts is too many (30+).
        // User list examples: kka, kkha, kga, ... kcha ... kpa ... kma ... kya, kra, kla, kva, ksha.
        // So essentially Base + Virama + [All Consonants]
        
        // Let's iterate over a standard set of consonants to form conjuncts
        // We need internal mapping of English -> Gondi char to construct these
        // Since we don't have that map publicly exposed, we can rely on transliterator
        // by passing strings like "kka", "kkha".
        
        val suffixes = listOf(
            "k", "kh", "g", "gh", "ng",
            "c", "ch", "j", "jh", "ny",
            "T", "Th", "D", "Dh", "N",
            "t", "th", "d", "dh", "n",
            "p", "ph", "b", "bh", "m",
            "y", "r", "l", "v",
            "sh", "shh", "s", "h",
            "x" // ksha
        )
        
        for (s in suffixes) {
            if (s == "r") continue // handled by Rakar logic separately above (kra)
            
            // Construct input string "k" + "k" + "a" -> "kka"
            // Transliterate it
            val combo = baseChar + s + "a" 
            val trans = transliterator.transliterate(combo)
            variants.add(trans)
        }
        
        return variants
    }
}
