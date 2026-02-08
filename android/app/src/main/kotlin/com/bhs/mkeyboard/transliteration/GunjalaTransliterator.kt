package com.bhs.mkeyboard.transliteration

class GunjalaTransliterator : Transliterator {
    override val languageName: String = "Gunjala Gondi"

    companion object {
        // Gunjala Gondi combining marks
        const val VIRAMA = "𑶗"     // U+11D97 - Virama
        const val HALANTA = "𑶗"    // U+11D97 - Using Virama as Halanta equivalence
        const val ANUSVARA = "◌𑶕"   // U+11D95 - Anusvara
        const val VISARGA = "𑶖"    // U+11D96 - Visarga
        const val OM = "𑶘"         // U+11D98 - Om

        // Independent Vowels: U+11D60–U+11D6B
        private val independentVowels = mapOf(
            "aa" to "𑵡", "A" to "𑵡", "ā" to "𑵡",
            "i" to "𑵢",
            "ii" to "𑵣", "I" to "𑵣", "ee" to "𑵣", "ī" to "𑵣",
            "u" to "𑵤",
            "uu" to "𑵥", "oo" to "𑵥", "U" to "𑵥", "ū" to "𑵥",
            "e" to "𑵧", "E" to "𑵧", // Ee (U+11D67)
            "ai" to "𑵨", "aI" to "𑵨", "ei" to "𑵨",
            "o" to "𑵪", "O" to "𑵪", // Oo (U+11D6A)
            "au" to "𑵫", "aU" to "𑵫", "ou" to "𑵫",
            "a" to "𑵠"
        )

        // Vowel Signs (Matras): U+11D8A–U+11D94
        private val vowelSigns = mapOf(
            "aa" to "𑶊", "A" to "𑶊", "ā" to "𑶊",
            "i" to "𑶋",
            "ii" to "𑶌", "I" to "𑶌", "ee" to "𑶌", "ī" to "𑶌",
            "u" to "𑶍",
            "uu" to "𑶎", "oo" to "𑶎", "U" to "𑶎", "ū" to "𑶎",
            "e" to "◌𑶐", "E" to "◌𑶐", // Ee (U+11D90)
            "ai" to "◌𑶑", "aI" to "◌𑶑", "ei" to "◌𑶑",
            "o" to "𑶓", "O" to "𑶓", // Oo (U+11D93)
            "au" to "𑶔", "aU" to "𑶔", "ou" to "𑶔"
        )

        // Consonants: U+11D6C–U+11D89
        private val consonants = mapOf(
            "ka" to "𑵱", "k" to "𑵱",
            "kha" to "𑵲", "kh" to "𑵲", "K" to "𑵲",
            "ga" to "𑵶", "g" to "𑵶",
            "gha" to "𑵷", "gh" to "𑵷", "G" to "𑵷",
            "nga" to "𑶄", "ng" to "𑶄", "~N" to "𑶄", "N^" to "𑶄",

            "cha" to "𑵻", "ch" to "𑵻", "c" to "𑵻",
            "chha" to "𑵼", "chh" to "𑵼", "C" to "𑵼", "Ch" to "𑵼",
            "ja" to "𑶀", "j" to "𑶀",
            "jha" to "𑶁", "jh" to "𑶁", "J" to "𑶁",
            "nya" to "◌𑶕", "~n" to "◌𑶕", "ñ" to "◌𑶕", // Using Anusvara

            "Ta" to "𑵽", "T" to "𑵽", "ṭ" to "𑵽",
            "Tha" to "𑵾", "Th" to "𑵾", "ṭh" to "𑵾",
            "Da" to "𑶂", "D" to "𑶂", "ḍ" to "𑶂",
            "Dha" to "𑶃", "Dh" to "𑶃", "ḍh" to "𑶃",
            "Na" to "𑵺", "N" to "𑵺", "ṇ" to "𑵺", 

            "ta" to "𑵳", "t" to "𑵳",
            "tha" to "𑵴", "th" to "𑵴",
            "da" to "𑵸", "d" to "𑵸",
            "dha" to "𑵹", "dh" to "𑵹",
            "na" to "𑵺", "n" to "𑵺",

            "pa" to "𑶅", "p" to "𑶅",
            "pha" to "𑶆", "ph" to "𑶆", "f" to "𑶆", "P" to "𑶆",
            "ba" to "𑵮", "b" to "𑵮",
            "bha" to "𑵯", "bh" to "𑵯", "B" to "𑵯",
            "ma" to "𑵰", "m" to "𑵰",

            "ya" to "𑵬", "y" to "𑵬",
            "ra" to "𑶈", "r" to "𑶈",
            "la" to "𑵵", "l" to "𑵵",
            "va" to "𑵭", "v" to "𑵭", "w" to "𑵭",
            "sha" to "𑶉", "sh" to "𑶉", "S" to "𑶉", "s" to "𑶉",
            "ha" to "𑶇", "h" to "𑶇", "H" to "𑶇",
            "lla" to "𑵿", "L" to "𑵿", "ḷ" to "𑵿",

            // Missing QWERTY mappings to prevent English fallback
            "q" to "𑵱", "Q" to "𑵱", // Maps to ka
            "z" to "𑶀", "Z" to "𑶀", // Maps to ja
            "x" to "𑵱𑶗𑶉", "X" to "𑵱𑶗𑶉" // Maps to ksha (ka + virama + sa)
        )

        // Gunjala Gondi Digits: U+11DA0–U+11DA9
        private val numbers = mapOf(
            "0" to "𑶠", "1" to "𑶡", "2" to "𑶢",
            "3" to "𑶣", "4" to "𑶤", "5" to "𑶥",
            "6" to "𑶦", "7" to "𑶧", "8" to "𑶨",
            "9" to "𑶩"
        )

        private val maxConsonantLen = consonants.keys.maxOf { it.length }
        private val maxVowelSignLen = vowelSigns.keys.maxOf { it.length }
        private val maxIndVowelLen = independentVowels.keys.maxOf { it.length }
    }

    private val cache = java.util.Collections.synchronizedMap(
        object : LinkedHashMap<String, String>(128, 0.75f, true) {
            override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, String>?) =
                size > 500
        }
    )

    override fun transliterate(input: String): String {
        return transliterate(input, isComposing = false)
    }

    override fun transliterate(input: String, isComposing: Boolean): String {
        if (input.isEmpty()) return ""
        val cacheKey = "$input|$isComposing"
        cache[cacheKey]?.let { return it }

        val parts = input.split(Regex("(?<=\\s)|(?=\\s)"))
        val result = StringBuilder(input.length * 2)
        for (part in parts) {
            if (part.isBlank()) result.append(part)
            else result.append(transliterateWord(part, isComposing))
        }
        val output = result.toString()
        cache[cacheKey] = output
        return output
    }

    private fun transliterateWord(word: String, isComposing: Boolean): String {
        if (word.isEmpty()) return ""
        val buf = StringBuilder(word.length * 2)
        var i = 0
        var hasConsonant = false
        var hasVowel = false

        while (i < word.length) {
            val ch = word[i]
            val charStr = ch.toString()

            // NUMBERS
            if (numbers.containsKey(charStr)) {
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
                buf.append(numbers[charStr])
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // PUNCTUATION
            if (ch == '.' && !startsSpecialDot(word, i)) {
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
                when {
                    i + 2 < word.length && word[i + 1] == '.' && word[i + 2] == '.' -> {
                        buf.append("॥"); i += 3
                    }
                    i + 1 < word.length && word[i + 1] == '.' -> {
                        buf.append("।"); i += 2
                    }
                    else -> {
                        buf.append("।"); i++
                    }
                }
                hasConsonant = false
                hasVowel = false
                continue
            }

            // WHITESPACE
            if (ch == ' ' || ch == '\n' || ch == '\t') {
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
                buf.append(ch)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // CHANDRABINDU / ANUSVARA
            if (matchesAt(word, i, ".N") || matchesAt(word, i, "MM")) {
                buf.append(ANUSVARA)
                i += 2
                continue
            }
            if (matchesAt(word, i, ".n") || matchesAt(word, i, ".m")) {
                buf.append(ANUSVARA)
                i += 2
                continue
            }
            if (ch == 'M' || ch == 'ṃ' || ch == 'ṁ') {
                buf.append(ANUSVARA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // VISARGA
            if (matchesAt(word, i, ".h")) {
                buf.append(VISARGA)
                i += 2
                continue
            }
            if (ch == 'H' && hasVowel) {
                buf.append(VISARGA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }
            if (ch == 'ḥ') {
                buf.append(VISARGA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // CONSONANTS
            val consMatch = matchMap(word, i, consonants, maxConsonantLen)
            if (consMatch != null) {
                if (hasConsonant && !hasVowel) buf.append(VIRAMA)
                buf.append(consMatch.first)
                i += consMatch.second
                hasConsonant = true
                hasVowel = false
                // Consume following vowel
                if (i < word.length && word[i] == 'a') {
                    val next = i + 1
                    if (next < word.length) {
                        when (word[next]) {
                            'a', 'A' -> { buf.append(vowelSigns["aa"]!!); i = next + 1; hasVowel = true; continue }
                            'i', 'I' -> { buf.append(vowelSigns["ai"]!!); i = next + 1; hasVowel = true; continue }
                            'u', 'U' -> { buf.append(vowelSigns["au"]!!); i = next + 1; hasVowel = true; continue }
                        }
                    }
                    i++
                    hasVowel = true
                    continue
                }
                val vi = consumeVowel(word, i, buf)
                if (vi > i) hasVowel = true
                i = vi
                continue
            }

            // INDEPENDENT VOWELS
            val indMatch = matchMap(word, i, independentVowels, maxIndVowelLen)
            if (indMatch != null) {
                if (hasConsonant && !hasVowel) buf.append(VIRAMA)
                buf.append(indMatch.first)
                i += indMatch.second
                hasConsonant = false
                hasVowel = true
                continue
            }

            // SKIP
            if (ch == '^' || ch == '~') {
                i++
                continue
            }

            // UNMATCHED
            if (hasConsonant && !hasVowel) buf.append(VIRAMA)
            buf.append(ch)
            hasConsonant = false
            hasVowel = false
            i++
        }

        // Only add halanta for truly final consonants when not composing
        if (hasConsonant && !hasVowel && !isComposing) {
            buf.append(HALANTA)
        }

        return buf.toString()
    }

    private fun consumeVowel(word: String, start: Int, buf: StringBuilder): Int {
        if (start >= word.length) return start
        val vs = matchMap(word, start, vowelSigns, maxVowelSignLen)
        if (vs != null) {
            buf.append(vs.first)
            return start + vs.second
        }
        return start
    }

    private fun matchMap(
        word: String, start: Int, map: Map<String, String>, maxLen: Int
    ): Pair<String, Int>? {
        val limit = minOf(maxLen, word.length - start)
        for (len in limit downTo 1) {
            val key = word.substring(start, start + len)
            map[key]?.let { return it to len }
        }
        return null
    }

    private fun matchesAt(word: String, index: Int, seq: String): Boolean {
        if (index + seq.length > word.length) return false
        for (j in seq.indices) {
            if (word[index + j] != seq[j]) return false
        }
        return true
    }

    private fun startsSpecialDot(word: String, i: Int): Boolean =
        matchesAt(word, i, ".r") || matchesAt(word, i, ".Dh") || matchesAt(word, i, ".D") ||
                matchesAt(word, i, ".n") || matchesAt(word, i, ".m") ||
                matchesAt(word, i, ".h") || matchesAt(word, i, ".N")

    override fun getSuggestions(input: String, limit: Int): List<String> = emptyList()
}