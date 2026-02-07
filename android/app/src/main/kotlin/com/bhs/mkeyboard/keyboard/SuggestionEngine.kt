package com.bhs.mkeyboard.keyboard

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import org.json.JSONArray

class SuggestionEngine private constructor(private val context: Context) {

    companion object {
        private const val TAG = "SuggestionEngine"
        @Volatile
        private var INSTANCE: SuggestionEngine? = null

        fun getInstance(context: Context): SuggestionEngine {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: SuggestionEngine(context.applicationContext).also { INSTANCE = it }
            }
        }
    }

    private val prefs: SharedPreferences = context.getSharedPreferences(
        "FlutterSharedPreferences", Context.MODE_PRIVATE
    )

    // Coroutine scope for async loading
    private val scope = kotlinx.coroutines.CoroutineScope(
        kotlinx.coroutines.Dispatchers.IO + kotlinx.coroutines.SupervisorJob()
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
    private val cacheValidityMs = 60000L // Increase cache validity to 1 min

    fun getSuggestions(
        input: String,
        languageIndex: Int,
        transliteratedText: String = "",
        limit: Int = 3
    ): List<String> {
        if (input.isEmpty() && transliteratedText.isEmpty()) return emptyList()

        if (System.currentTimeMillis() - lastLoadTime > cacheValidityMs || cachedWords.isEmpty()) {
             // Trigger load in background if needed, don't block
             scope.launch { loadAllWords() }
        }

        val lastInputWord = input.split(" ").lastOrNull()?.lowercase() ?: ""
        val lastTranslitWord = transliteratedText.split(" ").lastOrNull() ?: ""
        
        // Log removed to reduce spam
        // Log.d(TAG, "Getting suggestions: input='$lastInputWord', translit='$lastTranslitWord', lang=$languageIndex")

        if (lastInputWord.isEmpty() && lastTranslitWord.isEmpty()) return emptyList()

        return when (languageIndex) {
            0 -> getEnglishSuggestions(lastInputWord, limit)
            1 -> getHindiSuggestions(lastInputWord, lastTranslitWord, limit)
            2 -> getGondiSuggestions(lastInputWord, lastTranslitWord, limit)
            else -> emptyList()
        }
    }

    private var englishDictionary: Set<String> = emptySet()
    private var hindiDictionary: Set<String> = emptySet()

    private var englishBigrams: Map<String, List<String>> = emptyMap()
    private var hindiBigrams: Map<String, List<String>> = emptyMap()
    private var isLoading = false

    private fun loadAllWords() {
        if (isLoading) return
        isLoading = true
        
        try {
            val allWords = mutableListOf<SuggestionWord>()
            allWords.addAll(loadCustomWords())
            allWords.addAll(loadAssetSuggestions())
            cachedWords = allWords
            
            loadEnglishDictionary()
            loadHindiDictionary()
            loadBigrams()
            
            lastLoadTime = System.currentTimeMillis()
            Log.d(TAG, "Total loaded: ${allWords.size} words, EngDict: ${englishDictionary.size}, HinDict: ${hindiDictionary.size}, EngBigrams: ${englishBigrams.size}")
        } catch (e: Exception) {
            Log.e(TAG, "Error loading words", e)
        } finally {
            isLoading = false
        }
    }

    private fun loadBigrams() {
        try {
            // Load English Bigrams
            val engContent = context.assets.open("dictionary/english_bigrams.json")
                .bufferedReader().use { it.readText() }
            val engJson = org.json.JSONObject(engContent)
            val engMap = mutableMapOf<String, List<String>>()
            for (key in engJson.keys()) {
                val list = mutableListOf<String>()
                val arr = engJson.getJSONArray(key)
                for (i in 0 until arr.length()) {
                    list.add(arr.getString(i))
                }
                engMap[key.lowercase()] = list
            }
            englishBigrams = engMap

            // Load Hindi Bigrams
            val hinContent = context.assets.open("dictionary/hindi_bigrams.json")
                .bufferedReader().use { it.readText() }
            val hinJson = org.json.JSONObject(hinContent)
            val hinMap = mutableMapOf<String, List<String>>()
            for (key in hinJson.keys()) {
                val list = mutableListOf<String>()
                val arr = hinJson.getJSONArray(key)
                for (i in 0 until arr.length()) {
                    list.add(arr.getString(i))
                }
                hinMap[key] = list // key is Hindi, keep usage case (though usually case doesn't apply)
            }
            hindiBigrams = hinMap

        } catch (e: Exception) {
            Log.e(TAG, "Error loading bigrams", e)
        }
    }

    fun getNextWordSuggestions(lastWord: String, languageIndex: Int): List<String> {
        val word = lastWord.trim().lowercase()
        if (word.isEmpty()) return emptyList()

        return when (languageIndex) {
            0 -> englishBigrams[word] ?: emptyList()
            1 -> hindiBigrams[lastWord.trim()] ?: emptyList() // Use original case for Hindi if needed
            else -> emptyList()
        }
    }

    private fun loadHindiDictionary() {
        try {
            val content = context.assets.open("dictionary/hindi_words.txt")
                .bufferedReader().use { it.readText() }
            
            // Split by newlines and trim
            hindiDictionary = content.lineSequence()
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .toSet()
        } catch (e: Exception) {
            Log.e(TAG, "Error loading Hindi dictionary", e)
            hindiDictionary = emptySet()
        }
    }

    private fun loadEnglishDictionary() {
        try {
            val content = context.assets.open("dictionary/english_words.txt")
                .bufferedReader().use { it.readText() }
            
            // Split by newlines and trim
            englishDictionary = content.lineSequence()
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .toSet()
        } catch (e: Exception) {
            Log.e(TAG, "Error loading English dictionary", e)
            englishDictionary = emptySet()
        }
    }

    private fun getEnglishSuggestions(input: String, limit: Int): List<String> {
        if (input.isEmpty()) return emptyList()

        val suggestions = mutableListOf<String>()

        // 1. Custom/Pinned words first
        cachedWords.forEach { word ->
            if (word.englishOutput.lowercase().startsWith(input)) {
                suggestions.add(word.englishOutput)
            }
        }

        // 2. English dictionary words
        val dictMatches = englishDictionary
            .filter { it.startsWith(input, ignoreCase = true) } // Case-insensitive match
            .take(limit) // Limit dictionary matches
        
        suggestions.addAll(dictMatches)
        
        // 3. Alternatives from JSON
        cachedWords.forEach { word ->
            word.alternatives.forEach { alt ->
                if (alt.lowercase().startsWith(input)) {
                    suggestions.add(alt)
                }
            }
        }

        return suggestions.distinct().take(limit)
    }

    private fun getHindiSuggestions(input: String, translit: String, limit: Int): List<String> {
        if (input.isEmpty() && translit.isEmpty()) return emptyList()

        // Strip trailing Halanta (U+094D) if present, to match "m"->"म्" against "म..."
        val cleanTranslit = if (translit.endsWith("\u094D")) translit.dropLast(1) else translit

        val suggestions = mutableListOf<String>()

        // 1. Custom/Pinned words
        val customMatches = cachedWords
            .filter {
                (translit.isNotEmpty() && (it.hindiOutput.startsWith(translit) || (cleanTranslit.isNotEmpty() && it.hindiOutput.startsWith(cleanTranslit)))) ||
                (input.isNotEmpty() && it.inputKey.lowercase().startsWith(input))
            }
            .sortedByDescending { it.usageCount }
            .map { it.hindiOutput }
        suggestions.addAll(customMatches)

        // 2. Hindi Dictionary words
        if (translit.isNotEmpty()) {
            val dictMatches = hindiDictionary
                .filter {
                    it.startsWith(translit) || (cleanTranslit.isNotEmpty() && it.startsWith(cleanTranslit))
                }
                .take(limit)
            suggestions.addAll(dictMatches)
        }

        return suggestions.distinct().take(limit)
    }

    private fun getGondiSuggestions(input: String, translit: String, limit: Int): List<String> {
        if (input.isEmpty() && translit.isEmpty()) return emptyList()

        // Strip trailing Halanta (U+11D44) if present
        val cleanTranslit = if (translit.endsWith("\uD807\uDD44")) translit.dropLast(2) else translit

        return cachedWords
            .filter {
                it.gondiOutput.isNotEmpty() && (
                    (translit.isNotEmpty() && (it.gondiOutput.startsWith(translit) || (cleanTranslit.isNotEmpty() && it.gondiOutput.startsWith(cleanTranslit)))) ||
                    (input.isNotEmpty() && it.inputKey.lowercase().startsWith(input))
                )
            }
            .sortedByDescending { it.usageCount }
            .map { it.gondiOutput }
            .distinct()
            .take(limit)
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

    fun learnWord(input: String, output: String, languageIndex: Int) {
        if (input.isEmpty() || output.isEmpty()) return

        // 1. Update in-memory cache
        val existingIndex = cachedWords.indexOfFirst {
            it.inputKey.equals(input, ignoreCase = true) &&
            ((languageIndex == 1 && it.hindiOutput == output) ||
             (languageIndex == 2 && it.gondiOutput == output))
        }

        if (existingIndex != -1) {
            // Update existing word usage
            val word = cachedWords[existingIndex]
            val newWord = word.copy(usageCount = word.usageCount + 1)
            cachedWords = cachedWords.toMutableList().apply { set(existingIndex, newWord) }
            saveCustomWordUsage(input, languageIndex, newWord.usageCount)
        } else {
            // Check if it's a standard English word before adding as custom
            if (languageIndex == 0 && englishDictionary.contains(input.lowercase())) {
                return // Found in English dictionary, do not learn as custom
            }
            // Check if it's a standard Hindi word
            if (languageIndex == 1 && hindiDictionary.contains(output)) {
                return // Found in Hindi dictionary
            }

            // Add new word to custom words
            val newWord = SuggestionWord(
                inputKey = input,
                hindiOutput = if (languageIndex == 1) output else "",
                gondiOutput = if (languageIndex == 2) output else "",
                englishOutput = input,
                alternatives = emptyList(),
                usageCount = 1,
                isPinned = false
            )
            cachedWords = cachedWords + newWord
            addCustomWordToPrefs(newWord, languageIndex)
        }
    }

    private fun addCustomWordToPrefs(word: SuggestionWord, languageIndex: Int) {
        try {
            val jsonString = prefs.getString("flutter.customWords", "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)

            val newObj = org.json.JSONObject()
            newObj.put("english", word.inputKey)
            newObj.put("translated", if (languageIndex == 1) word.hindiOutput else word.gondiOutput)
            newObj.put("language", languageIndex)
            newObj.put("usageCount", 1)
            newObj.put("isPinned", false)

            jsonArray.put(newObj)
            prefs.edit().putString("flutter.customWords", jsonArray.toString()).apply()
            Log.d(TAG, "Added new custom word: ${word.inputKey}")
        } catch (e: Exception) {
            Log.e(TAG, "Error adding custom word", e)
        }
    }

    private fun saveCustomWordUsage(english: String, languageIndex: Int, newCount: Int) {
        try {
            val jsonString = prefs.getString("flutter.customWords", "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)
            var found = false

            val updatedArray = JSONArray()

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val e = obj.optString("english", "")
                val l = obj.optInt("language", 0)

                if (e.equals(english, ignoreCase = true) && l == languageIndex) {
                    obj.put("usageCount", newCount)
                    found = true
                }
                updatedArray.put(obj)
            }

            if (found) {
                prefs.edit().putString("flutter.customWords", updatedArray.toString()).apply()
                Log.d(TAG, "Updated usage for $english to $newCount")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error saving word usage", e)
        }
    }

    fun areSuggestionsEnabled(): Boolean {
        return prefs.getBoolean("flutter.showSuggestions", true)
    }
}