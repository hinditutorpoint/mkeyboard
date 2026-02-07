package com.bhs.mkeyboard.transliteration

interface Transliterator {
    val languageName: String
    fun transliterate(input: String): String
    
    // Add default method with composing support
    fun transliterate(input: String, isComposing: Boolean): String {
        return transliterate(input)  // default: ignores composing
    }
    
    fun getSuggestions(input: String, limit: Int = 5): List<String>
}
