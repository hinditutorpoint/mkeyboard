package com.bhs.mkeyboard.transliteration

class HindiTransliterator : Transliterator {
    override val languageName: String = "Hindi"

    companion object {
        const val VIRAMA = "्"
        const val ANUSVARA = "ं"
        const val VISARGA = "ः"
        const val NUKTA = "़"
        const val CHANDRABINDU = "ँ"
    }

    private val vowels = mapOf(
        "a" to "अ", "aa" to "आ", "A" to "आ",
        "i" to "इ", "ii" to "ई", "I" to "ई", "ee" to "ई",
        "u" to "उ", "uu" to "ऊ", "U" to "ऊ", "oo" to "ऊ",
        "ri" to "ऋ", "R" to "ऋ",
        "e" to "ए", "ai" to "ऐ", "E" to "ऐ",
        "o" to "ओ", "au" to "औ", "O" to "औ"
    )

    private val matras = mapOf(
        "a" to "", "aa" to "ा", "A" to "ा",
        "i" to "ि", "ii" to "ी", "I" to "ी", "ee" to "ी",
        "u" to "ु", "uu" to "ू", "U" to "ू", "oo" to "ू",
        "ri" to "ृ", "R" to "ृ",
        "e" to "े", "ai" to "ै", "E" to "ै",
        "o" to "ो", "au" to "ौ", "O" to "ौ"
    )

    private val consonants = mapOf(
        "ka" to "क", "k" to "क", "K" to "क",
        "kha" to "ख", "kh" to "ख", "Kh" to "ख",
        "ga" to "ग", "g" to "ग", "G" to "ग",
        "gha" to "घ", "gh" to "घ", "Gh" to "घ",
        "nga" to "ङ", "ng" to "ङ",
        "ca" to "च", "cha" to "च", "ch" to "च", "c" to "च",
        "chha" to "छ", "chh" to "छ", "Ch" to "छ",
        "ja" to "ज", "j" to "ज", "J" to "ज",
        "jha" to "झ", "jh" to "झ", "Jh" to "झ",
        "nya" to "ञ", "ny" to "ञ",
        "Ta" to "ट", "T" to "ट",
        "Tha" to "ठ", "Th" to "ठ",
        "Da" to "ड", "D" to "ड",
        "Dha" to "ढ", "Dh" to "ढ",
        "Na" to "ण", "N" to "ण",
        "ta" to "त", "t" to "त",
        "tha" to "थ", "th" to "थ",
        "da" to "द", "d" to "द",
        "dha" to "ध", "dh" to "ध",
        "na" to "न", "n" to "न",
        "pa" to "प", "p" to "प", "P" to "प",
        "pha" to "फ", "ph" to "फ", "Ph" to "फ",
        "ba" to "ब", "b" to "ब", "B" to "ब",
        "bha" to "भ", "bh" to "भ", "Bh" to "भ",
        "ma" to "म", "m" to "म", "M" to "म",
        "ya" to "य", "y" to "य", "Y" to "य",
        "ra" to "र", "r" to "र",
        "la" to "ल", "l" to "ल", "L" to "ल",
        "va" to "व", "v" to "व", "V" to "व", "wa" to "व", "w" to "व",
        "sha" to "श", "sh" to "श",
        "ssa" to "ष", "ss" to "ष",
        "sa" to "स", "s" to "स", "S" to "स",
        "ha" to "ह", "h" to "ह", "H" to "ह"
    )

    private val specialConjuncts = mapOf(
        "ksha" to "क्ष", "ksh" to "क्ष",
        "tra" to "त्र", "tr" to "त्र",
        "gya" to "ज्ञ", "gy" to "ज्ञ",
        "jna" to "ज्ञ", "jn" to "ज्ञ",
        "shra" to "श्र", "shr" to "श्र"
    )

    private val nuktaConsonants = mapOf(
        "qa" to "क$NUKTA", "q" to "क$NUKTA",
        "khha" to "ख$NUKTA", "x" to "ख$NUKTA",
        "gha_" to "ग$NUKTA",
        "za" to "ज$NUKTA", "z" to "ज$NUKTA",
        "rha" to "ड$NUKTA",
        "rhha" to "ढ$NUKTA",
        "fa" to "फ$NUKTA", "f" to "फ$NUKTA"
    )

    private val numbers = mapOf(
        "0" to "०", "1" to "१", "2" to "२", "3" to "३", "4" to "४",
        "5" to "५", "6" to "६", "7" to "७", "8" to "८", "9" to "९"
    )

    override fun transliterate(input: String): String {
        if (input.isEmpty()) return ""
        
        val words = input.split(Regex("\\s+"))
        return words.joinToString(" ") { transliterateWord(it) }
    }

    private fun transliterateWord(word: String): String {
        if (word.isEmpty()) return ""

        val buffer = StringBuilder()
        var i = 0
        var lastWasConsonant = false

        while (i < word.length) {
            val charStr = word[i].toString()
            
            // Try numbers
            if (numbers.containsKey(charStr)) {
                if (lastWasConsonant) {
                    buffer.append(VIRAMA)
                    lastWasConsonant = false
                }
                buffer.append(numbers[charStr])
                i++
                continue
            }

            // Try nukta consonants
            var matched = false
            for (len in 5 downTo 2) {
                if (i + len <= word.length) {
                    val substr = word.substring(i, i + len).lowercase()
                    if (nuktaConsonants.containsKey(substr)) {
                        if (lastWasConsonant) buffer.append(VIRAMA)
                        buffer.append(nuktaConsonants[substr])
                        i += len
                        lastWasConsonant = true
                        matched = true
                        break
                    }
                }
            }
            if (matched) continue

            // Try special conjuncts
            for (len in 4 downTo 2) {
                if (i + len <= word.length) {
                    val substr = word.substring(i, i + len).lowercase()
                    if (specialConjuncts.containsKey(substr)) {
                        if (lastWasConsonant) buffer.append(VIRAMA)
                        buffer.append(specialConjuncts[substr])
                        i += len
                        lastWasConsonant = true
                        matched = true
                        break
                    }
                }
            }
            if (matched) continue

            // Try consonant + vowel (or just consonant)
            val consonantMatch = matchConsonant(word, i)
            if (consonantMatch.first != null) {
                if (lastWasConsonant) buffer.append(VIRAMA)
                buffer.append(consonantMatch.first)
                i += consonantMatch.second

                // Try matra
                if (i < word.length) {
                    val matraMatch = matchMatra(word, i)
                    if (matraMatch.first != null && matraMatch.first!!.isNotEmpty()) {
                        buffer.append(matraMatch.first)
                        i += matraMatch.second
                        lastWasConsonant = false
                    } else {
                        lastWasConsonant = true
                    }
                } else {
                    lastWasConsonant = true
                }
                continue
            }

            // Try standalone vowel
            val vowelMatch = matchVowel(word, i)
            if (vowelMatch.first != null) {
                if (lastWasConsonant) buffer.append(VIRAMA)
                buffer.append(vowelMatch.first)
                i += vowelMatch.second
                lastWasConsonant = false
                continue
            }

            // Handle anusvara (m/n before consonant)
            // Simplified logic: m/n followed by something that looks like it needs nasalization
            val charLower = charStr.lowercase()
            if ((charLower == "m" || charLower == "n") && i + 1 < word.length) {
                // If it's a generic nasal context (simplified from Dart)
                 buffer.append(ANUSVARA)
                 i++
                 lastWasConsonant = false
                 continue
            }

            // Handle visarga (h at end)
            if (charLower == "h" && (i + 1 >= word.length)) {
                buffer.append(VISARGA)
                i++
                lastWasConsonant = false
                continue
            }

            // Unmatched character
            if (lastWasConsonant && word[i] != ' ') {
                buffer.append(VIRAMA)
                lastWasConsonant = false
            }
            buffer.append(word[i])
            i++
        }
        
        return buffer.toString()
    }

    private fun matchConsonant(word: String, start: Int): Pair<String?, Int> {
        for (len in 4 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (consonants.containsKey(substr)) return Pair(consonants[substr], len)
                if (consonants.containsKey(substr.lowercase())) return Pair(consonants[substr.lowercase()], len)
            }
        }
        return Pair(null, 0)
    }

    private fun matchMatra(word: String, start: Int): Pair<String?, Int> {
        for (len in 3 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (matras.containsKey(substr)) return Pair(matras[substr], len)
                if (matras.containsKey(substr.lowercase())) return Pair(matras[substr.lowercase()], len)
            }
        }
        return Pair(null, 0)
    }

    private fun matchVowel(word: String, start: Int): Pair<String?, Int> {
        for (len in 3 downTo 1) {
            if (start + len <= word.length) {
                val substr = word.substring(start, start + len)
                if (vowels.containsKey(substr)) return Pair(vowels[substr], len)
                if (vowels.containsKey(substr.lowercase())) return Pair(vowels[substr.lowercase()], len)
            }
        }
        return Pair(null, 0)
    }

    override fun getSuggestions(input: String, limit: Int): List<String> {
        // Native suggestion logic would require a dictionary
        // For now, return empty or implement basic trie later
        return emptyList()
    }
}
