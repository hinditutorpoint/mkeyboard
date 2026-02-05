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

        const val VOWEL_CHARS = "aāiīuūeēoōAIUEO"
    }

    private val independentVowels = mapOf(
        "a" to "𑴀",
        "aa" to "𑴁", "A" to "𑴁", "ā" to "𑴁",
        "i" to "𑴂",
        "ii" to "𑴃", "I" to "𑴃", "ī" to "𑴃", "ee" to "𑴃",
        "u" to "𑴄",
        "uu" to "𑴅", "U" to "𑴅", "ū" to "𑴅", "oo" to "𑴅",
        "RRi" to "𑴇", "R^i" to "𑴇", "Ri" to "𑴇", ".r" to "𑴇", "ṛ" to "𑴇",
        "RRI" to "𑴇", "R^I" to "𑴇",
        "e" to "𑴆", "E" to "𑴆", "ē" to "𑴆",
        "ai" to "𑴈", "aI" to "𑴈", "ei" to "𑴈",
        "o" to "𑴉", "O" to "𑴉", "ō" to "𑴉",
        "au" to "𑴋", "aU" to "𑴋", "ou" to "𑴋"
    )

    private val vowelSigns = mapOf(
        "aa" to "𑴱", "A" to "𑴱", "ā" to "𑴱",
        "i" to "𑴲",
        "ii" to "𑴳", "I" to "𑴳", "ī" to "𑴳", "ee" to "𑴳",
        "u" to "𑴴",
        "uu" to "𑴵", "U" to "𑴵", "ū" to "𑴵", "oo" to "𑴵",
        "e" to "𑴺", "ē" to "𑴺",
        "ai" to "𑴼", "aI" to "𑴼", "ei" to "𑴼",
        "o" to "𑴽", "ō" to "𑴽",
        "au" to "𑴿", "aU" to "𑴿", "ou" to "𑴿",
        "R" to "𑴶", "ṛ" to "𑴶", "RRi" to "𑴶", "R^i" to "𑴶", "Ri" to "𑴶",
        "RRI" to "𑴶", "R^I" to "𑴶", ".r" to "𑴶"
    )

    private val consonants = mapOf(
        // Velars
        "k" to "𑴌", "K" to "𑴍", "kh" to "𑴍",
        "g" to "𑴎", "G" to "𑴏", "gh" to "𑴏",
        "F" to "𑴐", "ng" to "𑴐", "ṅ" to "𑴐", "~N" to "𑴐", "N^" to "𑴐",

        // Palatals
        "c" to "𑴑", "ch" to "𑴑",
        "C" to "𑴒", "chh" to "𑴒", "Ch" to "𑴒",
        "j" to "𑴓", "J" to "𑴔", "jh" to "𑴔",
        "Y" to "𑴕", "ny" to "𑴕", "ñ" to "𑴕", "JN" to "𑴕", "~n" to "𑴕",

        // Retroflexes
        "T" to "𑴖", "ṭ" to "𑴖",
        "Th" to "𑴗", "ṭh" to "𑴗",
        "D" to "𑴘", "ḍ" to "𑴘",
        "Dh" to "𑴙", "ḍh" to "𑴙",
        "N" to "𑴚", "ṇ" to "𑴚",

        // Dentals
        "t" to "𑴛", "th" to "𑴜",
        "d" to "𑴝", "dh" to "𑴞",
        "n" to "𑴟",

        // Labials
        "p" to "𑴠", "P" to "𑴡", "ph" to "𑴡",
        "b" to "𑴢", "B" to "𑴣", "bh" to "𑴣",
        "m" to "𑴤",

        // Semivowels
        "y" to "𑴥",
        "r" to "𑴦",
        "l" to "𑴧", "L" to "𑴭", "ḷ" to "𑴭",
        "v" to "𑴨", "w" to "𑴨", "W" to "𑴨",

        // Sibilants
        "sh" to "𑴩", "ś" to "𑴩",
        "S" to "𑴪", "ss" to "𑴪", "ṣ" to "𑴪", "Sh" to "𑴪", "shh" to "𑴪",
        "s" to "𑴫",
        "h" to "𑴬",

        // Special ligatures
        "x" to "𑴮", // ksha
        "X" to "𑴯", // gya
        "GY" to "𑴯", "dny" to "𑴯", "jny" to "𑴯",
        "Z" to "𑴰" // tra
    )

    private val nuktaConsonants = mapOf(
        "q" to "𑴌$SUKUN",
        "z" to "𑴓$SUKUN",
        "f" to "𑴡$SUKUN",
        ".D" to "𑴘$SUKUN",
        ".Dh" to "𑴙$SUKUN"
    )

    private val numbers = mapOf(
        "0" to "𑵐", "1" to "𑵑", "2" to "𑵒", "3" to "𑵓", "4" to "𑵔",
        "5" to "𑵕", "6" to "𑵖", "7" to "𑵗", "8" to "𑵘", "9" to "𑵙"
    )
    
    // Cache for transliteration results
    private val cache = LruCache<String, String>(500)

    override fun transliterate(input: String): String {
        if (input.isEmpty()) return ""
        
        cache[input]?.let { return it }

        // Split by whitespace but preserve delimiters to maintain structure
        val parts = input.split(Regex("(?<=\\s)|(?=\\s)"))
        val result = StringBuilder()
        
        for (part in parts) {
            if (part.isBlank()) {
                result.append(part)
            } else {
                result.append(transliterateWord(part))
            }
        }
        
        val output = result.toString()
        cache.put(input, output)
        return output
    }

    private fun transliterateWord(word: String): String {
        if (word.isEmpty()) return ""

        val buffer = StringBuilder()
        var i = 0

        // Track state
        var hasConsonant = false // Have unconsumed consonant
        var hasVowel = false // Current syllable has vowel

        while (i < word.length) {
            val char = word[i]
            val charStr = char.toString()
            val remaining = word.substring(i)

            // ─────────────────────────────────────────────────────────────────────
            // NUMBERS
            // ─────────────────────────────────────────────────────────────────────
            if (numbers.containsKey(charStr)) {
                if (hasConsonant && !hasVowel) {
                    buffer.append(HALANTA)
                }
                buffer.append(numbers[charStr])
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // PUNCTUATION
            // ─────────────────────────────────────────────────────────────────────
            if (char == '.') {
                // Special check: if '.' starts a special sequence, skip punctuation handling
                if (remaining.startsWith(".r") ||
                    remaining.startsWith(".D") ||
                    remaining.startsWith(".n") ||
                    remaining.startsWith(".m") ||
                    remaining.startsWith(".h") ||
                    remaining.startsWith(".N")
                ) {
                    // Fall through to regular matching
                } else {
                    if (hasConsonant && !hasVowel) {
                        buffer.append(HALANTA)
                    }

                    // Count dots
                    var dotCount = 1
                    while (i + dotCount < word.length && word[i + dotCount] == '.') {
                        dotCount++
                    }

                    if (dotCount >= 3) {
                        buffer.append("॥")
                        i += 3
                    } else if (dotCount >= 2) {
                        buffer.append("।")
                        i += 2
                    } else {
                        buffer.append("।")
                        i++
                    }

                    hasConsonant = false
                    hasVowel = false
                    continue
                }
            }

            // ─────────────────────────────────────────────────────────────────────
            // WHITESPACE (Pass through)
            // ─────────────────────────────────────────────────────────────────────
            if (char == ' ' || char == '\n' || char == '\t') {
                if (hasConsonant && !hasVowel) {
                    buffer.append(HALANTA)
                }
                buffer.append(char)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // CHANDRABINDU (MM or .N)
            // ─────────────────────────────────────────────────────────────────────
            if (remaining.startsWith(".N") || remaining.startsWith("MM")) {
                buffer.append(CHANDRABINDU)
                i += 2
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // ANUSVARA (M after vowel, or ṃ, or .n, .m)
            // ─────────────────────────────────────────────────────────────────────
            if (remaining.startsWith(".n") || remaining.startsWith(".m")) {
                buffer.append(ANUSVARA)
                i += 2
                continue
            }

            if ((char == 'M' && hasVowel) || char == 'ṃ' || char == 'ṁ') {
                buffer.append(ANUSVARA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // VISARGA (H after vowel, or ḥ, or .h)
            // ─────────────────────────────────────────────────────────────────────
            if (remaining.startsWith(".h")) {
                buffer.append(VISARGA)
                i += 2
                continue
            }

            if ((char == 'H' && hasVowel) || char == 'ḥ') {
                buffer.append(VISARGA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // REPHA: 'r' after vowel, before consonant (V + r + C)
            // Example: mArkA → maa + repha + kaa
            // ─────────────────────────────────────────────────────────────────────
            if (char == 'r' && hasVowel && isRepha(word, i)) {
                buffer.append(REPHA)
                hasConsonant = false
                hasVowel = false
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // RAKAR: 'r' after consonant, before vowel (C + r + V)
            // Example: kro → ka + rakar + o
            // ─────────────────────────────────────────────────────────────────────
            if (char == 'r' && hasConsonant && !hasVowel) {
                var nextPos = i + 1

                // Check what comes after 'r'
                if (nextPos < word.length) {
                    val next = word[nextPos]

                    // r + a = rakar with inherent vowel
                    if (next == 'a') {
                        // Check if it's just 'a' (inherent) or 'aa', 'ai', 'au'
                        val afterA = nextPos + 1
                        if (afterA < word.length) {
                            val afterAChar = word[afterA]
                            if (afterAChar == 'a' || afterAChar == 'A') {
                                // 'raa' = rakar + aa sign
                                buffer.append(RAKAR)
                                buffer.append("𑴱")
                                i = afterA + 1
                                hasVowel = true
                                continue
                            } else if (afterAChar == 'i' || afterAChar == 'I') {
                                // 'rai' = rakar + ai sign
                                buffer.append(RAKAR)
                                buffer.append("𑴼")
                                i = afterA + 1
                                hasVowel = true
                                continue
                            } else if (afterAChar == 'u' || afterAChar == 'U') {
                                // 'rau' = rakar + au sign
                                buffer.append(RAKAR)
                                buffer.append("𑴿")
                                i = afterA + 1
                                hasVowel = true
                                continue
                            }
                        }
                        // Just 'ra' = rakar with inherent a
                        buffer.append(RAKAR)
                        i = nextPos + 1
                        hasVowel = true
                        continue
                    }

                    // r + other vowel = rakar + vowel sign
                    val vowelMatch = matchVowelSign(word, nextPos)
                    if (vowelMatch.first != null) {
                        buffer.append(RAKAR)
                        buffer.append(vowelMatch.first)
                        i = nextPos + vowelMatch.second
                        hasVowel = true
                        continue
                    }

                    // r + consonant = conjunct (not rakar)
                    if (isConsonantStart(word, nextPos)) {
                        // This is r as part of conjunct, use virama
                        buffer.append(VIRAMA)
                        buffer.append("𑴦") // ra
                        hasConsonant = true
                        hasVowel = false
                        i++
                        continue
                    }
                }

                // 'r' at end = rakar with inherent a
                buffer.append(RAKAR)
                hasVowel = true
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // CONSONANTS
            // ─────────────────────────────────────────────────────────────────────
            val consonantMatch = matchConsonant(word, i)
            if (consonantMatch.first != null) {
                // If previous consonant has no vowel, add virama for conjunct
                if (hasConsonant && !hasVowel) {
                    buffer.append(VIRAMA)
                }

                buffer.append(consonantMatch.first)
                i += consonantMatch.second
                hasConsonant = true
                hasVowel = false

                // Check for following vowel
                if (i < word.length) {
                    // Handle 'a' specially
                    if (word[i] == 'a') {
                        var nextPos = i + 1
                        // Check for 'aa', 'ai', 'au'
                        if (nextPos < word.length) {
                            val next = word[nextPos]
                            if (next == 'a' || next == 'A') {
                                buffer.append("𑴱") // aa
                                i = nextPos + 1
                                hasVowel = true
                                continue
                            } else if (next == 'i' || next == 'I') {
                                buffer.append("𑴼") // ai
                                i = nextPos + 1
                                hasVowel = true
                                continue
                            } else if (next == 'u' || next == 'U') {
                                buffer.append("𑴿") // au
                                i = nextPos + 1
                                hasVowel = true
                                continue
                            } else if (next == 'e') {
                                buffer.append("𑵃") // ae (chandrabindu variant/special)
                                i = nextPos + 1
                                hasVowel = true
                                continue
                            }
                        }
                        // Just 'a' = inherent vowel, no matra needed
                        i++
                        hasVowel = true
                        continue
                    }

                    // Try matching other vowel signs
                    val vowelMatch = matchVowelSign(word, i)
                    if (vowelMatch.first != null) {
                        buffer.append(vowelMatch.first)
                        i += vowelMatch.second
                        hasVowel = true
                        continue
                    }
                }
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // INDEPENDENT VOWELS
            // ─────────────────────────────────────────────────────────────────────
            if (!hasConsonant || hasVowel) {
                val vowelMatch = matchIndependentVowel(word, i)
                if (vowelMatch.first != null) {
                    if (hasConsonant && !hasVowel) {
                        buffer.append(HALANTA)
                    }
                    buffer.append(vowelMatch.first)
                    i += vowelMatch.second
                    hasConsonant = false
                    hasVowel = true
                    continue
                }
            }

            // ─────────────────────────────────────────────────────────────────────
            // SKIP SPECIAL CHARS
            // ─────────────────────────────────────────────────────────────────────
            if (char == '^' || char == '~') {
                i++
                continue
            }

            // ─────────────────────────────────────────────────────────────────────
            // UNMATCHED - pass through
            // ─────────────────────────────────────────────────────────────────────
            if (hasConsonant && !hasVowel) {
                buffer.append(HALANTA)
            }
            buffer.append(char)
            hasConsonant = false
            hasVowel = false
            i++
        }

        // Handle final state - consonant without vowel gets halanta
        if (hasConsonant && !hasVowel) {
            buffer.append(HALANTA)
        }

        return buffer.toString()
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════
    
    // Simple LruCache implementation for Kotlin without Android dependency if needed, 
    // but we can use simple LinkedHashMap or just import LruCache. 
    // Android's LruCache is fine since this is an Android project.
    private class LruCache<K, V>(private val maxSize: Int) : java.util.LinkedHashMap<K, V>(maxSize, 0.75f, true) {
        override fun removeEldestEntry(eldest: Map.Entry<K, V>?): Boolean {
            return size > maxSize
        }
    }

    private fun isVowel(c: Char): Boolean {
        return VOWEL_CHARS.contains(c) || c == 'a'
    }

    private fun isConsonantStart(word: String, pos: Int): Boolean {
        if (pos >= word.length) return false

        // Try matching consonant at position
        for (len in 3 downTo 1) {
            if (pos + len <= word.length) {
                val substr = word.substring(pos, pos + len)
                if (consonants.containsKey(substr) ||
                    nuktaConsonants.containsKey(substr)
                ) {
                    return true
                }
            }
        }
        return false
    }

    // Check if 'r' at position is for repha (V + r + C)
    private fun isRepha(word: String, pos: Int): Boolean {
        if (pos >= word.length) return false
        if (word[pos] != 'r') return false

        // Must have consonant after 'r'
        val nextPos = pos + 1
        return if (nextPos < word.length) {
            isConsonantStart(word, nextPos)
        } else false
    }

    private fun matchConsonant(word: String, start: Int): Pair<String?, Int> {
        // Check nukta consonants first
        for (len in 2 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (nuktaConsonants.containsKey(substr)) {
                    return Pair(nuktaConsonants[substr], len)
                }
            }
        }

        // Then regular consonants (try longer matches first)
        for (len in 3 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (consonants.containsKey(substr)) {
                    return Pair(consonants[substr], len)
                }
            }
        }
        return Pair(null, 0)
    }

    private fun matchVowelSign(word: String, start: Int): Pair<String?, Int> {
        for (len in 3 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (vowelSigns.containsKey(substr)) {
                    return Pair(vowelSigns[substr], len)
                }
            }
        }
        return Pair(null, 0)
    }

    private fun matchIndependentVowel(word: String, start: Int): Pair<String?, Int> {
        for (len in 3 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (independentVowels.containsKey(substr)) {
                    return Pair(independentVowels[substr], len)
                }
            }
        }
        return Pair(null, 0)
    }

    override fun getSuggestions(input: String, limit: Int): List<String> = emptyList()
}
