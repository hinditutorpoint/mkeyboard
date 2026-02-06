package com.bhs.mkeyboard.transliteration

class GondiTransliterator : Transliterator {
    override val languageName: String = "Gondi"

    companion object {
        const val HALANTA = "𑵄" // U+11D44 - Final consonant marker
        const val VIRAMA = "𑵅" // U+11D45 - Conjunct marker (C+C)
        const val ANUSVARA = "𑵀" // U+11D40 - Nasalization (M)
        const val VISARGA = "𑵁" // U+11D41 - Aspiration (H)
        const val SUKUN = "𑵂" // U+11D42 - Nukta variant
        const val CHANDRABINDU = "𑵃" // U+11D43 - Chandrabindu (MM)
        const val REPHA = "𑵆" // U+11D46 - R before consonant
        const val RAKAR = "𑵇" // U+11D47 - R after consonant

        private val independentVowels = mapOf(
            "RRi" to "𑴇", "R^i" to "𑴇", "RRI" to "𑴇", "R^I" to "𑴇",
            "aa" to "𑴁", "ee" to "𑴃", "oo" to "𑴅",
            "ai" to "𑴈", "aI" to "𑴈", "ei" to "𑴈",
            "au" to "𑴋", "aU" to "𑴋", "ou" to "𑴋",
            "A" to "𑴁", "I" to "𑴃", "U" to "𑴅",
            "E" to "𑴈", "O" to "𑴉",
            "Ri" to "𑴇", ".r" to "𑴇",
            "a" to "𑴀", "i" to "𑴂", "u" to "𑴄",
            "e" to "𑴆", "o" to "𑴉",
            "ā" to "𑴁", "ī" to "𑴃", "ū" to "𑴅",
            "ē" to "𑴆", "ō" to "𑴉", "ṛ" to "𑴇",
            "R" to "𑴶"
        )

        private val vowelSigns = mapOf(
            "RRi" to "𑴶", "R^i" to "𑴶", "RRI" to "𑴶", "R^I" to "𑴶",
            "aa" to "𑴱", "ee" to "𑴳", "oo" to "𑴵",
            "ai" to "𑴼", "aI" to "𑴼", "ei" to "𑴼",
            "au" to "𑴿", "aU" to "𑴿", "ou" to "𑴿",
            "A" to "𑴱", "I" to "𑴳", "U" to "𑴵",
            "E" to "𑴼", "O" to "𑴽",
            "Ri" to "𑴶", ".r" to "𑴶",
            "i" to "𑴲", "u" to "𑴴",
            "e" to "𑴺", "o" to "𑴽",
            "ā" to "𑴱", "ī" to "𑴳", "ū" to "𑴵",
            "ē" to "𑴺", "ō" to "𑴽", "ṛ" to "𑴶",
            "R" to "𑴶"
        )

        private val consonants = mapOf(
            "GY" to "𑴯", "dny" to "𑴯", "jny" to "𑴯",
            "shh" to "𑴪", "chh" to "𑴒",
            "kh" to "𑴍", "gh" to "𑴏",
            "ng" to "𑴐", "~N" to "𑴐", "N^" to "𑴐",
            "k" to "𑴌", "K" to "𑴍",
            "g" to "𑴎", "G" to "𑴏",
            "F" to "𑴐",
            "Ch" to "𑴒",
            "ch" to "𑴑",
            "jh" to "𑴔",
            "ny" to "𑴕", "JN" to "𑴕", "~n" to "𑴕",
            "c" to "𑴑", "C" to "𑴒",
            "j" to "𑴓", "J" to "𑴔",
            "Y" to "𑴕",
            "Th" to "𑴗", "ṭh" to "𑴗",
            "Dh" to "𑴙", "ḍh" to "𑴙",
            "T" to "𑴖", "ṭ" to "𑴖",
            "D" to "𑴘", "ḍ" to "𑴘",
            "N" to "𑴚", "ṇ" to "𑴚",
            "th" to "𑴜", "dh" to "𑴞",
            "t" to "𑴛", "d" to "𑴝", "n" to "𑴟",
            "ph" to "𑴡", "bh" to "𑴣",
            "p" to "𑴠", "P" to "𑴡", "f" to "𑴡",
            "b" to "𑴢", "B" to "𑴣",
            "m" to "𑴤",
            "y" to "𑴥", "r" to "𑴦",
            "l" to "𑴧", "L" to "𑴭", "ḷ" to "𑴭",
            "v" to "𑴨", "w" to "𑴨", "W" to "𑴨", "V" to "𑴨",
            "Sh" to "𑴪", "sh" to "𑴩",
            "S" to "𑴪", "ss" to "𑴪",
            "s" to "𑴫",
            "ś" to "𑴩", "ṣ" to "𑴪",
            "h" to "𑴬",
            "x" to "𑴮", "X" to "𑴯", "Z" to "𑴰",
            "ñ" to "𑴕", "ṅ" to "𑴐"
        )

        private val nuktaConsonants = mapOf(
            ".Dh" to "𑴙$SUKUN",
            ".D" to "𑴘$SUKUN",
            "q" to "𑴌$SUKUN", "Q" to "𑴌$SUKUN",
            "z" to "𑴓$SUKUN"
        )

        private val numbers = mapOf(
            "0" to "𑵐", "1" to "𑵑", "2" to "𑵒", "3" to "𑵓", "4" to "𑵔",
            "5" to "𑵕", "6" to "𑵖", "7" to "𑵗", "8" to "𑵘", "9" to "𑵙"
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
                when {
                    i + 2 < word.length && word[i + 1] == '.' && word[i + 2] == '.' -> {
                        buf.append("॥")
                        i += 3
                    }
                    i + 1 < word.length && word[i + 1] == '.' -> {
                        buf.append("।")
                        i += 2
                    }
                    else -> {
                        buf.append("।")
                        i++
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

            // REPHA: r after vowel, before consonant
            if (ch == 'r' && hasVowel && isFollowedByConsonant(word, i + 1)) {
                buf.append(REPHA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // RAKAR: r after consonant without vowel
            if (ch == 'r' && hasConsonant && !hasVowel) {
                buf.append(RAKAR)
                i++
                // Consume vowel after rakar
                if (i < word.length && word[i] == 'a') {
                    val next = i + 1
                    if (next < word.length) {
                        when (word[next]) {
                            'a', 'A' -> { buf.append("𑴱"); i = next + 1; hasVowel = true; continue }
                            'i', 'I' -> { buf.append("𑴼"); i = next + 1; hasVowel = true; continue }
                            'u', 'U' -> { buf.append("𑴿"); i = next + 1; hasVowel = true; continue }
                        }
                    }
                    // Plain 'a' = inherent
                    i++
                    hasVowel = true
                    continue
                }
                val vi = consumeVowel(word, i, buf)
                if (vi > i) {
                    hasVowel = true
                    i = vi
                } else {
                    hasVowel = true // rakar alone has inherent a
                }
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
                            'a', 'A' -> { buf.append("𑴱"); i = next + 1; hasVowel = true; continue }
                            'i', 'I' -> { buf.append("𑴼"); i = next + 1; hasVowel = true; continue }
                            'u', 'U' -> { buf.append("𑴿"); i = next + 1; hasVowel = true; continue }
                        }
                    }
                    // Plain 'a' = inherent vowel
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
                if (hasConsonant && !hasVowel) buf.append(HALANTA)
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
        matchesAt(word, i, ".r") || matchesAt(word, i, ".D") ||
        matchesAt(word, i, ".n") || matchesAt(word, i, ".m") ||
        matchesAt(word, i, ".h") || matchesAt(word, i, ".N")

    override fun getSuggestions(input: String, limit: Int): List<String> = emptyList()
}