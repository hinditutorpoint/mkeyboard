package com.bhs.mkeyboard.transliteration

interface Transliterator {
    val languageName: String
    fun transliterate(input: String): String
    fun getSuggestions(input: String, limit: Int = 5): List<String>
}
