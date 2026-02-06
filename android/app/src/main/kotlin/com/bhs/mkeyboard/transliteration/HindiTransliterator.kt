package com.bhs.mkeyboard.transliteration

class HindiTransliterator : Transliterator {
    override val languageName: String = "Hindi"

    companion object {
        const val HALANTA = "्"
        const val ANUSVARA = "ं"
        const val VISARGA = "ः"
        const val NUKTA = "़"
        const val CHANDRABINDU = "ँ"

        private val independentVowels = mapOf(
            "RRi" to "ऋ", "R^i" to "ऋ",
            "aa" to "आ", "ee" to "ई", "oo" to "ऊ",
            "ai" to "ऐ", "aI" to "ऐ", "ei" to "ऐ",
            "au" to "औ", "aU" to "औ", "ou" to "औ",
            "A" to "आ", "I" to "ई", "U" to "ऊ",
            "E" to "ऐ", "O" to "औ",
            "Ri" to "ऋ", ".r" to "ऋ",
            "a" to "अ", "i" to "इ", "u" to "उ",
            "e" to "ए", "o" to "ओ",
            "ā" to "आ", "ī" to "ई", "ū" to "ऊ",
            "ē" to "ए", "ō" to "ओ", "ṛ" to "ऋ"
        )

        private val vowelSigns = mapOf(
            "RRi" to "ृ", "R^i" to "ृ",
            "aa" to "ा", "ee" to "ी", "oo" to "ू",
            "ai" to "ै", "aI" to "ै", "ei" to "ै",
            "au" to "ौ", "aU" to "ौ", "ou" to "ौ",
            "A" to "ा", "I" to "ी", "U" to "ू",
            "E" to "ै", "O" to "ौ",
            "Ri" to "ृ", ".r" to "ृ",
            "i" to "ि", "u" to "ु",
            "e" to "े", "o" to "ो",
            "ā" to "ा", "ī" to "ी", "ū" to "ू",
            "ē" to "े", "ō" to "ो", "ṛ" to "ृ"
        )

        private val consonants = mapOf(
            "GY" to "ज्ञ", "dny" to "ज्ञ", "jny" to "ज्ञ",
            "shh" to "ष", "chh" to "छ",
            "kh" to "ख", "Kh" to "ख",
            "gh" to "घ", "Gh" to "घ",
            "ng" to "ङ", "~N" to "ङ", "N^" to "ङ",
            "k" to "क", "K" to "क",
            "g" to "ग", "G" to "ग",
            "Ch" to "छ",
            "ch" to "च",
            "jh" to "झ", "Jh" to "झ",
            "ny" to "ञ", "JN" to "ञ", "~n" to "ञ",
            "c" to "च", "C" to "छ",
            "j" to "ज", "J" to "ज",
            "Th" to "ठ", "ṭh" to "ठ",
            "Dh" to "ढ", "ḍh" to "ढ",
            "T" to "ट", "ṭ" to "ट",
            "D" to "ड", "ḍ" to "ड",
            "N" to "ण", "ṇ" to "ण",
            "th" to "थ", "dh" to "ध",
            "t" to "त", "d" to "द", "n" to "न",
            "ph" to "फ", "bh" to "भ", "Bh" to "भ",
            "p" to "प", "P" to "फ", "f" to "फ",
            "b" to "ब", "B" to "ब",
            "m" to "म",
            "y" to "य", "r" to "र",
            "l" to "ल", "L" to "ल", "ḷ" to "ल",
            "v" to "व", "w" to "व", "W" to "व", "V" to "व",
            "Sh" to "ष", "sh" to "श",
            "S" to "ष", "ss" to "ष",
            "s" to "स",
            "ś" to "श", "ṣ" to "ष",
            "h" to "ह",
            "x" to "क्ष", "X" to "क्ष",
            "Z" to "त्र",
            "ñ" to "ञ", "ṅ" to "ङ"
        )

        private val nuktaConsonants = mapOf(
            ".Dh" to "ढ$NUKTA",
            ".D" to "ड$NUKTA",
            ".f" to "फ$NUKTA",
            "q" to "क$NUKTA", "Q" to "क$NUKTA",
            "z" to "ज$NUKTA"
        )

        private val numbers = mapOf(
            "0" to "०", "1" to "१", "2" to "२", "3" to "३", "4" to "४",
            "5" to "५", "6" to "६", "7" to "७", "8" to "८", "9" to "९"
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
        if (input.isEmpty()) return ""
        cache[input]?.let { return it }

        val parts = input.split(Regex("(?<=\\s)|(?=\\s)"))
        val result = StringBuilder(input.length * 2)
        for (part in parts) {
            if (part.isBlank()) result.append(part)
            else result.append(transliterateWord(part))
        }
        val output = result.toString()
        cache[input] = output
        return output
    }

    private fun transliterateWord(word: String): String {
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
                if (i + 1 < word.length && word[i + 1] == '.') {
                    buf.append("॥")
                    i += 2
                } else {
                    buf.append("।")
                    i++
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

            // CHANDRABINDU (.N or MM)
            if (matchesAt(word, i, ".N") || matchesAt(word, i, "MM")) {
                buf.append(CHANDRABINDU)
                i += 2
                continue
            }

            // ANUSVARA (.n .m or M-after-vowel)
            if (matchesAt(word, i, ".n") || matchesAt(word, i, ".m")) {
                buf.append(ANUSVARA)
                i += 2
                continue
            }
            if (ch == 'M' && hasVowel) {
                buf.append(ANUSVARA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }
            if (ch == 'ṃ' || ch == 'ṁ') {
                buf.append(ANUSVARA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // VISARGA (.h or H-after-vowel)
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

            // NUKTA CONSONANTS
            val nuktaMatch = matchMap(word, i, nuktaConsonants, maxNuktaLen)
            if (nuktaMatch != null) {
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
                buf.append(nuktaMatch.first)
                i += nuktaMatch.second
                hasConsonant = true
                hasVowel = false
                val vi = consumeVowel(word, i, buf)
                if (vi > i) hasVowel = true
                i = vi
                continue
            }

            // CONSONANTS
            val consMatch = matchMap(word, i, consonants, maxConsonantLen)
            if (consMatch != null) {
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
                buf.append(consMatch.first)
                i += consMatch.second
                hasConsonant = true
                hasVowel = false
                val vi = consumeVowel(word, i, buf)
                if (vi > i) hasVowel = true
                i = vi
                continue
            }

            // INDEPENDENT VOWELS
            val indMatch = matchMap(word, i, independentVowels, maxIndVowelLen)
            if (indMatch != null) {
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
                buf.append(indMatch.first)
                i += indMatch.second
                hasConsonant = false
                hasVowel = true
                continue
            }

            // SKIP MODIFIERS
            if (ch == '^' || ch == '~') {
                i++
                continue
            }

            // UNMATCHED
            if (hasConsonant && !hasVowel) buf.append(HALANTA)
            buf.append(ch)
            hasConsonant = false
            hasVowel = false
            i++
        }

        if (hasConsonant && !hasVowel) buf.append(HALANTA)
        return buf.toString()
    }

    private fun consumeVowel(word: String, start: Int, buf: StringBuilder): Int {
        if (start >= word.length) return start
        if (word[start] == 'a') {
            val next = start + 1
            if (next < word.length) {
                when (word[next]) {
                    'a', 'A' -> { buf.append("ा"); return next + 1 }
                    'i', 'I' -> { buf.append("ै"); return next + 1 }
                    'u', 'U' -> { buf.append("ौ"); return next + 1 }
                }
            }
            return start + 1
        }
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
        matchesAt(word, i, ".r") || matchesAt(word, i, ".D") ||
        matchesAt(word, i, ".n") || matchesAt(word, i, ".m") ||
        matchesAt(word, i, ".h") || matchesAt(word, i, ".N") ||
        matchesAt(word, i, ".f")

    override fun getSuggestions(input: String, limit: Int): List<String> = emptyList()
}