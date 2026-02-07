package com.bhs.mkeyboard.transliteration

class GunjalaTransliterator : Transliterator {
    override val languageName: String = "Gunjala Gondi"

    companion object {
        // Gunjala Gondi combining marks
        const val VIRAMA = "\uD806\uDE3A"     // U+1193A - Virama (conjunct)
        const val HALANTA = "\uD806\uDE3B"     // U+1193B - Final consonant marker
        const val ANUSVARA = "\uD806\uDE38"    // U+11938 - Nasalization
        const val VISARGA = "\uD806\uDE39"     // U+11939 - Aspiration
        const val NUKTA = "\uD806\uDE3C"       // U+1193C - Nukta
        const val REPHA = "\uD806\uDE3D"       // U+1193D - Repha
        const val OM = "\uD806\uDE3E"          // U+1193E - Om sign

        // Independent Vowels: U+11900–U+1190F
        private val independentVowels = mapOf(
            "RRi" to "\uD806\uDE07", "R^i" to "\uD806\uDE07",
            "RRI" to "\uD806\uDE07", "R^I" to "\uD806\uDE07",
            "aa" to "\uD806\uDE01", "ee" to "\uD806\uDE03", "oo" to "\uD806\uDE05",
            "ai" to "\uD806\uDE08", "aI" to "\uD806\uDE08", "ei" to "\uD806\uDE08",
            "au" to "\uD806\uDE0B", "aU" to "\uD806\uDE0B", "ou" to "\uD806\uDE0B",
            "A" to "\uD806\uDE01", "I" to "\uD806\uDE03", "U" to "\uD806\uDE05",
            "E" to "\uD806\uDE08", "O" to "\uD806\uDE09",
            "Ri" to "\uD806\uDE07", ".r" to "\uD806\uDE07",
            "a" to "\uD806\uDE00", "i" to "\uD806\uDE02", "u" to "\uD806\uDE04",
            "e" to "\uD806\uDE06", "o" to "\uD806\uDE09",
            "ā" to "\uD806\uDE01", "ī" to "\uD806\uDE03", "ū" to "\uD806\uDE05",
            "ē" to "\uD806\uDE06", "ō" to "\uD806\uDE09", "ṛ" to "\uD806\uDE07"
        )

        // Vowel Signs (Matras): U+11930–U+11937
        private val vowelSigns = mapOf(
            "RRi" to "\uD806\uDE37", "R^i" to "\uD806\uDE37",
            "RRI" to "\uD806\uDE37", "R^I" to "\uD806\uDE37",
            "aa" to "\uD806\uDE30", "ee" to "\uD806\uDE32", "oo" to "\uD806\uDE34",
            "ai" to "\uD806\uDE35", "aI" to "\uD806\uDE35", "ei" to "\uD806\uDE35",
            "au" to "\uD806\uDE36", "aU" to "\uD806\uDE36", "ou" to "\uD806\uDE36",
            "A" to "\uD806\uDE30", "I" to "\uD806\uDE32", "U" to "\uD806\uDE34",
            "E" to "\uD806\uDE35", "O" to "\uD806\uDE33",
            "Ri" to "\uD806\uDE37", ".r" to "\uD806\uDE37",
            "i" to "\uD806\uDE31", "u" to "\uD806\uDE33",
            "e" to "\uD806\uDE35", "o" to "\uD806\uDE33",
            "ā" to "\uD806\uDE30", "ī" to "\uD806\uDE32", "ū" to "\uD806\uDE34",
            "ē" to "\uD806\uDE35", "ō" to "\uD806\uDE33", "ṛ" to "\uD806\uDE37"
        )

        // Consonants: U+11910–U+1192F
        private val consonants = mapOf(
            "GY" to "\uD806\uDE2F", "dny" to "\uD806\uDE2F", "jny" to "\uD806\uDE2F",
            "shh" to "\uD806\uDE2A", "chh" to "\uD806\uDE12",
            "kh" to "\uD806\uDE11", "gh" to "\uD806\uDE13",
            "ng" to "\uD806\uDE14", "~N" to "\uD806\uDE14", "N^" to "\uD806\uDE14",
            "k" to "\uD806\uDE10", "K" to "\uD806\uDE11",
            "g" to "\uD806\uDE12", "G" to "\uD806\uDE13",
            "Ch" to "\uD806\uDE16",
            "ch" to "\uD806\uDE15",
            "jh" to "\uD806\uDE18",
            "ny" to "\uD806\uDE19", "JN" to "\uD806\uDE19", "~n" to "\uD806\uDE19",
            "c" to "\uD806\uDE15", "C" to "\uD806\uDE16",
            "j" to "\uD806\uDE17", "J" to "\uD806\uDE18",
            "Th" to "\uD806\uDE1B", "ṭh" to "\uD806\uDE1B",
            "Dh" to "\uD806\uDE1D", "ḍh" to "\uD806\uDE1D",
            "T" to "\uD806\uDE1A", "ṭ" to "\uD806\uDE1A",
            "D" to "\uD806\uDE1C", "ḍ" to "\uD806\uDE1C",
            "N" to "\uD806\uDE1E", "ṇ" to "\uD806\uDE1E",
            "th" to "\uD806\uDE20", "dh" to "\uD806\uDE22",
            "t" to "\uD806\uDE1F", "d" to "\uD806\uDE21", "n" to "\uD806\uDE23",
            "ph" to "\uD806\uDE25", "bh" to "\uD806\uDE27",
            "p" to "\uD806\uDE24", "P" to "\uD806\uDE25", "f" to "\uD806\uDE25",
            "b" to "\uD806\uDE26", "B" to "\uD806\uDE27",
            "m" to "\uD806\uDE28",
            "y" to "\uD806\uDE29", "r" to "\uD806\uDE2A",
            "l" to "\uD806\uDE2B", "L" to "\uD806\uDE2C", "ḷ" to "\uD806\uDE2C",
            "v" to "\uD806\uDE2D", "w" to "\uD806\uDE2D", "W" to "\uD806\uDE2D", "V" to "\uD806\uDE2D",
            "Sh" to "\uD806\uDE2F", "sh" to "\uD806\uDE2E",
            "S" to "\uD806\uDE2F", "ss" to "\uD806\uDE2F",
            "s" to "\uD806\uDE2E",
            "ś" to "\uD806\uDE2E", "ṣ" to "\uD806\uDE2F",
            "h" to "\uD806\uDE2C", "H" to "\uD806\uDE2C",
            "ñ" to "\uD806\uDE19", "ṅ" to "\uD806\uDE14"
        )

        private val nuktaConsonants = mapOf(
            ".Dh" to "\uD806\uDE1D$NUKTA",
            ".D" to "\uD806\uDE1C$NUKTA",
            "q" to "\uD806\uDE10$NUKTA", "Q" to "\uD806\uDE10$NUKTA",
            "z" to "\uD806\uDE17$NUKTA"
        )

        // Gunjala Gondi Digits: U+11950–U+11959
        private val numbers = mapOf(
            "0" to "\uD806\uDE50", "1" to "\uD806\uDE51", "2" to "\uD806\uDE52",
            "3" to "\uD806\uDE53", "4" to "\uD806\uDE54", "5" to "\uD806\uDE55",
            "6" to "\uD806\uDE56", "7" to "\uD806\uDE57", "8" to "\uD806\uDE58",
            "9" to "\uD806\uDE59"
        )

        private val maxConsonantLen = consonants.keys.maxOf { it.length }
        private val maxNuktaLen = nuktaConsonants.keys.maxOf { it.length }
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

            // REPHA: r after vowel, before consonant
            if (ch == 'r' && hasVowel && isFollowedByConsonant(word, i + 1)) {
                buf.append(REPHA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // NUKTA CONSONANTS
            val nuktaMatch = matchMap(word, i, nuktaConsonants, maxNuktaLen)
            if (nuktaMatch != null) {
                if (hasConsonant && !hasVowel) buf.append(VIRAMA)
                buf.append(nuktaMatch.first)
                i += nuktaMatch.second
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

    private fun isFollowedByConsonant(word: String, pos: Int): Boolean {
        if (pos >= word.length) return false
        return matchMap(word, pos, consonants, maxConsonantLen) != null ||
                matchMap(word, pos, nuktaConsonants, maxNuktaLen) != null
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