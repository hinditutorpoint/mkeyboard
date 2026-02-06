package com.bhs.mkeyboard.keyboard

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import org.json.JSONArray

class SuggestionEngine(private val context: Context) {

    companion object {
        private const val TAG = "SuggestionEngine"
    }

    private val prefs: SharedPreferences = context.getSharedPreferences(
        "FlutterSharedPreferences", Context.MODE_PRIVATE
    )

    data class SuggestionWord(
        val inputKey: String,
        val hindiOutput: String,
        val gondiOutput: String,
        val englishOutput: String,
        val alternatives: List<String>,
        val usageCount: Int = 0,
        val isPinned: Boolean = false
    )

    private var cachedWords: List<SuggestionWord> = emptyList()
    private var lastLoadTime: Long = 0
    private val cacheValidityMs = 5000L

    fun getSuggestions(
        input: String,
        languageIndex: Int,
        transliteratedText: String = "",
        limit: Int = 3
    ): List<String> {
        if (input.isEmpty() && transliteratedText.isEmpty()) return emptyList()

        if (System.currentTimeMillis() - lastLoadTime > cacheValidityMs) {
            loadAllWords()
        }

        val lastInputWord = input.split(" ").lastOrNull()?.lowercase() ?: ""
        val lastTranslitWord = transliteratedText.split(" ").lastOrNull() ?: ""

        Log.d(TAG, "Getting suggestions: input='$lastInputWord', translit='$lastTranslitWord', lang=$languageIndex")

        if (lastInputWord.isEmpty() && lastTranslitWord.isEmpty()) return emptyList()

        return when (languageIndex) {
            0 -> getEnglishSuggestions(lastInputWord, limit)
            1 -> getHindiSuggestions(lastTranslitWord, limit)
            2 -> getGondiSuggestions(lastTranslitWord, limit)
            else -> emptyList()
        }
    }

    private fun getEnglishSuggestions(input: String, limit: Int): List<String> {
        if (input.isEmpty()) return emptyList()

        val suggestions = mutableListOf<String>()

        cachedWords.forEach { word ->
            if (word.englishOutput.lowercase().startsWith(input)) {
                suggestions.add(word.englishOutput)
            }
        }

        cachedWords.forEach { word ->
            word.alternatives.forEach { alt ->
                if (alt.lowercase().startsWith(input)) {
                    suggestions.add(alt)
                }
            }
        }

        return suggestions.distinct().take(limit)
    }

    private fun getHindiSuggestions(translit: String, limit: Int): List<String> {
        if (translit.isEmpty()) return emptyList()

        return cachedWords
            .filter { it.hindiOutput.startsWith(translit) }
            .sortedByDescending { it.usageCount }
            .map { it.hindiOutput }
            .distinct()
            .take(limit)
    }

    private fun getGondiSuggestions(translit: String, limit: Int): List<String> {
        if (translit.isEmpty()) return emptyList()

        return cachedWords
            .filter { it.gondiOutput.isNotEmpty() && it.gondiOutput.startsWith(translit) }
            .sortedByDescending { it.usageCount }
            .map { it.gondiOutput }
            .distinct()
            .take(limit)
    }

    private fun loadAllWords() {
        val allWords = mutableListOf<SuggestionWord>()
        allWords.addAll(loadCustomWords())
        allWords.addAll(loadAssetSuggestions())
        cachedWords = allWords
        lastLoadTime = System.currentTimeMillis()
        Log.d(TAG, "Total loaded: ${allWords.size} words")
    }

    private fun loadCustomWords(): List<SuggestionWord> {
        try {
            val jsonString = prefs.getString("flutter.customWords", "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)

            val words = mutableListOf<SuggestionWord>()
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val language = obj.optInt("language", 0)
                val english = obj.optString("english", "")
                val translated = obj.optString("translated", "")

                if (english.isNotEmpty() && translated.isNotEmpty()) {
                    words.add(
                        SuggestionWord(
                            inputKey = english,
                            hindiOutput = if (language == 1) translated else "",
                            gondiOutput = if (language == 2) translated else "",
                            englishOutput = english,
                            alternatives = emptyList(),
                            usageCount = obj.optInt("usageCount", 0),
                            isPinned = obj.optBoolean("isPinned", false)
                        )
                    )
                }
            }
            return words
        } catch (e: Exception) {
            Log.e(TAG, "Error loading custom words", e)
            return emptyList()
        }
    }

    private fun loadAssetSuggestions(): List<SuggestionWord> {
        try {
            val jsonString = context.assets.open("suggestions/suggestions.json")
                .bufferedReader().use { it.readText() }
            val jsonArray = JSONArray(jsonString)

            val words = mutableListOf<SuggestionWord>()
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val kbdKey = obj.optString("kbd_key", "")
                val hindi = obj.optString("hindi", "")
                val gondi = obj.optString("gondi", "")
                val gondiWord = obj.optString("gondiword", "")
                val english = obj.optString("english", "")

                val alts = mutableListOf<String>()
                val altArr = obj.optJSONArray("alternatives")
                if (altArr != null) {
                    for (j in 0 until altArr.length()) {
                        alts.add(altArr.getString(j))
                    }
                }

                if (kbdKey.isNotEmpty()) {
                    words.add(
                        SuggestionWord(
                            inputKey = kbdKey,
                            hindiOutput = hindi,
                            gondiOutput = gondiWord.ifEmpty { gondi },
                            englishOutput = english.ifEmpty { kbdKey },
                            alternatives = alts,
                            usageCount = 0,
                            isPinned = false
                        )
                    )
                }
            }
            return words
        } catch (e: Exception) {
            Log.e(TAG, "Error loading asset suggestions", e)
            return emptyList()
        }
    }

    fun areSuggestionsEnabled(): Boolean {
        return prefs.getBoolean("flutter.showSuggestions", true)
    }
}