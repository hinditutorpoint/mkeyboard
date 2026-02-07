package com.bhs.mkeyboard.transliteration

class ChikiTransliterator : Transliterator {
    override val languageName: String = "Ol Chiki"

    companion object {
        // Ol Chiki is an ALPHABETIC script (not abugida)
        // No virama/halanta needed — each letter stands alone
        // Unicode range: U+1C50–U+1C7F

        // Ol Chiki Digits: U+1C50–U+1C59
        private val numbers = mapOf(
            "0" to "᱐", "1" to "᱑", "2" to "᱒", "3" to "᱓", "4" to "᱔",
            "5" to "᱕", "6" to "᱖", "7" to "᱗", "8" to "᱘", "9" to "᱙"
        )

        // Ol Chiki Letters: U+1C5A–U+1C77
        // Mapping based on standard Santali romanization
        private val consonants = mapOf(
            "NGG" to "ᱝ",             // AHAD (ng voiced)
            "ngg" to "ᱝ",
            "kh" to "ᱛ",              // ATTE (aspirated k) — using LA position
            "gh" to "ᱜ",              // PHAARKAA
            "ng" to "ᱶ",              // MU GAAHLAA (nasal)
            "chh" to "ᱡ",             // LICH
            "ch" to "ᱪ",              // LICH (unaspirated)
            "jh" to "ᱡ",              // LICH (aspirated j)
            "ny" to "ᱧ",              // INYA
            "th" to "ᱛ",              // LA (dental aspirated)
            "Th" to "ᱴ",              // AT (retroflex aspirated)
            "dh" to "ᱫ",              // UD (aspirated d)
            "Dh" to "ᱰ",              // ODD (retroflex aspirated)
            "ph" to "ᱯ",              // EP (aspirated p)
            "bh" to "ᱵ",              // UCH (aspirated b)
            "sh" to "ᱥ",              // IS
            "k" to "ᱠ",               // KO
            "K" to "ᱠ",
            "g" to "ᱜ",               // PHAARKAA
            "G" to "ᱜ",
            "c" to "ᱪ",               // LICH
            "C" to "ᱪ",
            "j" to "ᱡ",               // LICH
            "J" to "ᱡ",
            "T" to "ᱴ",               // AT (retroflex)
            "ṭ" to "ᱴ",
            "D" to "ᱰ",               // ODD (retroflex)
            "ḍ" to "ᱰ",
            "N" to "ᱬ",               // UUNN (retroflex n)
            "ṇ" to "ᱬ",
            "t" to "ᱛ",               // LA
            "d" to "ᱫ",               // UD
            "n" to "ᱱ",               // ENN
            "p" to "ᱯ",               // EP
            "P" to "ᱯ",
            "f" to "ᱯ",               // EP (used for f)
            "b" to "ᱵ",               // UCH
            "B" to "ᱵ",
            "m" to "ᱢ",               // AM
            "y" to "ᱭ",               // AY
            "Y" to "ᱭ",
            "r" to "ᱨ",               // IR
            "l" to "ᱞ",               // AL
            "L" to "ᱞ",
            "ḷ" to "ᱞ",
            "v" to "ᱣ",               // AAW
            "w" to "ᱣ",               // AAW
            "W" to "ᱣ",
            "V" to "ᱣ",
            "s" to "ᱥ",               // IS
            "S" to "ᱥ",
            "h" to "ᱦ",               // AH
            "H" to "ᱦ",
            "R" to "ᱨ",               // IR
            "ñ" to "ᱧ",               // INYA
            "ṅ" to "ᱶ",               // MU GAAHLAA
            "ś" to "ᱥ",               // IS
            "ṣ" to "ᱥ"                // IS
        )

        // Ol Chiki vowels — standalone letters (not combining marks)
        private val vowels = mapOf(
            "aa" to "ᱟ",              // LA (long a)
            "ee" to "ᱤ",              // IH (long i)
            "oo" to "ᱩ",              // UUH (long u)
            "ai" to "ᱮ",              // OLE (ai diphthong)
            "aI" to "ᱮ",
            "ei" to "ᱮ",              // OLE
            "au" to "ᱳ",              // OH (au diphthong)
            "aU" to "ᱳ",
            "ou" to "ᱳ",              // OH
            "A" to "ᱟ",               // LA (long a)
            "I" to "ᱤ",               // IH (long i)
            "U" to "ᱩ",               // UUH (long u)
            "E" to "ᱮ",               // OLE
            "O" to "ᱳ",               // OH
            "a" to "ᱟ",               // LA
            "i" to "ᱤ",               // IH
            "u" to "ᱩ",               // UUH
            "e" to "ᱮ",               // OLE
            "o" to "ᱳ",               // OH
            "ā" to "ᱟ",
            "ī" to "ᱤ",
            "ū" to "ᱩ",
            "ē" to "ᱮ",
            "ō" to "ᱳ"
        )

        // Ol Chiki punctuation
        const val MUCAAD = "᱾"        // U+1C7E - Full stop
        const val DOUBLE_MUCAAD = "᱿" // U+1C7F - Section mark
        const val RELAA = "ᱹ"         // U+1C79 - Mid-low vowel
        const val PHAARKAA = "ᱺ"      // U+1C7A - Mark
        const val AHAD = "ᱽ"          // U+1C7D - Separator
        const val MU_TTUDDAG = "ᱻ"    // U+1C7B
        const val GAAHLAA_TTUDDAAG = "ᱼ" // U+1C7C

        private val maxConsonantLen = consonants.keys.maxOf { it.length }
        private val maxVowelLen = vowels.keys.maxOf { it.length }
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
            else result.append(transliterateWord(part))
        }
        val output = result.toString()
        cache[cacheKey] = output
        return output
    }

    private fun transliterateWord(word: String): String {
        if (word.isEmpty()) return ""
        val buf = StringBuilder(word.length * 2)
        var i = 0

        while (i < word.length) {
            val ch = word[i]
            val charStr = ch.toString()

            // NUMBERS
            if (numbers.containsKey(charStr)) {
                buf.append(numbers[charStr])
                i++
                continue
            }

            // PUNCTUATION
            if (ch == '.' && !startsSpecialDot(word, i)) {
                when {
                    i + 2 < word.length && word[i + 1] == '.' && word[i + 2] == '.' -> {
                        buf.append(DOUBLE_MUCAAD); i += 3
                    }
                    i + 1 < word.length && word[i + 1] == '.' -> {
                        buf.append(MUCAAD); i += 2
                    }
                    else -> {
                        buf.append(MUCAAD); i++
                    }
                }
                continue
            }

            // WHITESPACE
            if (ch == ' ' || ch == '\n' || ch == '\t') {
                buf.append(ch)
                i++
                continue
            }

            // NASALIZATION markers
            if (matchesAt(word, i, ".N") || matchesAt(word, i, "MM")) {
                buf.append(GAAHLAA_TTUDDAAG)
                i += 2
                continue
            }
            if (matchesAt(word, i, ".n") || matchesAt(word, i, ".m")) {
                buf.append(MU_TTUDDAG)
                i += 2
                continue
            }
            if (ch == 'M' || ch == 'ṃ' || ch == 'ṁ') {
                buf.append(MU_TTUDDAG)
                i++
                continue
            }

            // VISARGA
            if (matchesAt(word, i, ".h")) {
                buf.append(AHAD)
                i += 2
                continue
            }
            if (ch == 'ḥ') {
                buf.append(AHAD)
                i++
                continue
            }

            // CONSONANTS — try longest match first
            val consMatch = matchMap(word, i, consonants, maxConsonantLen)
            if (consMatch != null) {
                buf.append(consMatch.first)
                i += consMatch.second

                // Ol Chiki is alphabetic: consonant followed by vowel = separate letter
                // Skip inherent 'a' — Ol Chiki has no inherent vowel concept
                // If next char is 'a' followed by another vowel, consume the combo
                if (i < word.length && word[i] == 'a') {
                    val next = i + 1
                    if (next < word.length) {
                        when (word[next]) {
                            'a', 'A' -> { buf.append(vowels["aa"]!!); i = next + 1; continue }
                            'i', 'I' -> { buf.append(vowels["ai"]!!); i = next + 1; continue }
                            'u', 'U' -> { buf.append(vowels["au"]!!); i = next + 1; continue }
                        }
                    }
                    // Plain 'a' after consonant → write the vowel
                    buf.append(vowels["a"]!!)
                    i++
                    continue
                }

                // Try consuming other vowels
                val vi = consumeVowel(word, i, buf)
                if (vi > i) {
                    i = vi
                    continue
                }

                // No vowel after consonant — that's fine in Ol Chiki (no halanta needed)
                continue
            }

            // STANDALONE VOWELS
            val vowelMatch = matchMap(word, i, vowels, maxVowelLen)
            if (vowelMatch != null) {
                buf.append(vowelMatch.first)
                i += vowelMatch.second
                continue
            }

            // SKIP
            if (ch == '^' || ch == '~') {
                i++
                continue
            }

            // UNMATCHED
            buf.append(ch)
            i++
        }

        // No halanta/virama needed — Ol Chiki is alphabetic
        return buf.toString()
    }

    private fun consumeVowel(word: String, start: Int, buf: StringBuilder): Int {
        if (start >= word.length) return start
        val vs = matchMap(word, start, vowels, maxVowelLen)
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
        matchesAt(word, i, ".D") || matchesAt(word, i, ".Dh") ||
                matchesAt(word, i, ".n") || matchesAt(word, i, ".m") ||
                matchesAt(word, i, ".h") || matchesAt(word, i, ".N")

    override fun getSuggestions(input: String, limit: Int): List<String> = emptyList()
}