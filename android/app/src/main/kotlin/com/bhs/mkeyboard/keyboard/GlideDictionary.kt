package com.bhs.mkeyboard.keyboard

import android.content.Context
import android.util.Log
import org.json.JSONArray

/**
 * Dictionary for resolving glide-typed key sequences into words.
 * Uses a trie-based approach for fast prefix matching.
 */
class GlideDictionary(private val context: Context) {

    companion object {
        private const val TAG = "GlideDictionary"
    }

    private data class TrieNode(
        val children: MutableMap<Char, TrieNode> = mutableMapOf(),
        var word: String? = null,
        var frequency: Int = 0
    )

    private val englishRoot = TrieNode()
    private val hindiRoot = TrieNode()   // key = ITRANS input, word = Hindi output
    private val gondiRoot = TrieNode()   // key = ITRANS input, word = Gondi output
    private var isLoaded = false

    fun load() {
        if (isLoaded) return

        try {
            // Load common English words
            loadEnglishDictionary()

            // Load suggestion words for Hindi/Gondi glide
            loadTransliterationDictionary()

            isLoaded = true
            Log.d(TAG, "Dictionary loaded")
        } catch (e: Exception) {
            Log.e(TAG, "Error loading dictionary", e)
        }
    }

    /**
     * Given a glide key sequence (e.g. "hlo"), find matching words.
     * The sequence contains the keys the finger passed through.
     * We find words whose characters are a superset match of the sequence.
     *
     * @param keySequence The keys visited during glide (e.g. "helo" for "hello")
     * @param languageIndex 0=English, 1=Hindi, 2=Gondi
     * @param limit Max results
     */
    fun findMatches(
        keySequence: String,
        languageIndex: Int,
        limit: Int = 5
    ): List<String> {
        if (keySequence.length < 2) return emptyList()

        val root = when (languageIndex) {
            0 -> englishRoot
            1 -> hindiRoot
            2 -> gondiRoot
            else -> return emptyList()
        }

        val results = mutableListOf<Pair<String, Int>>() // word, score
        val firstChar = keySequence.first().lowercaseChar()
        val lastChar = keySequence.last().lowercaseChar()

        // Find all words starting with the first key and ending with the last key
        findWordsInTrie(root, firstChar, lastChar, keySequence.lowercase(), results)

        // Sort by score (higher = better match) then frequency
        return results
            .sortedWith(compareByDescending<Pair<String, Int>> { it.second }
                .thenByDescending { getFrequency(root, it.first) })
            .map { it.first }
            .distinct()
            .take(limit)
    }

    private fun findWordsInTrie(
        root: TrieNode,
        firstChar: Char,
        lastChar: Char,
        glideSequence: String,
        results: MutableList<Pair<String, Int>>
    ) {
        // Start from the first character's subtree
        val startNode = root.children[firstChar] ?: return

        // DFS to find all words
        fun dfs(node: TrieNode, depth: Int) {
            node.word?.let { word ->
                val wordLower = word.lowercase()
                // Word must start with firstChar and end with lastChar
                if (wordLower.isNotEmpty() &&
                    wordLower.first() == firstChar &&
                    wordLower.last() == lastChar
                ) {
                    val score = calculateMatchScore(wordLower, glideSequence)
                    if (score > 0) {
                        results.add(word to score)
                    }
                }
            }

            // Limit depth to prevent excessive searching
            if (depth > 15) return

            for ((_, child) in node.children) {
                dfs(child, depth + 1)
            }
        }

        dfs(startNode, 1)
    }

    /**
     * Calculate how well a word matches the glide sequence.
     * Higher score = better match.
     *
     * The glide sequence contains keys the finger passed through.
     * A good match means the word's characters appear in order
     * within the glide sequence.
     */
    private fun calculateMatchScore(word: String, glideSequence: String): Int {
        if (word.isEmpty() || glideSequence.isEmpty()) return 0
        if (word.first() != glideSequence.first()) return 0
        if (word.last() != glideSequence.last()) return 0

        // Check if all characters of the word appear in order in the glide
        var glideIdx = 0
        var matched = 0

        for (ch in word) {
            while (glideIdx < glideSequence.length) {
                if (glideSequence[glideIdx] == ch) {
                    matched++
                    glideIdx++
                    break
                }
                glideIdx++
            }
        }

        if (matched < word.length) return 0 // Not all chars found in sequence

        // Score: favor words whose length is close to glide sequence length
        val lengthDiff = kotlin.math.abs(word.length - glideSequence.length)
        val lengthScore = maxOf(0, 10 - lengthDiff)

        // Favor longer words (more meaningful)
        val wordLengthScore = minOf(word.length, 8)

        return lengthScore + wordLengthScore + matched
    }

    private fun getFrequency(root: TrieNode, word: String): Int {
        var node = root
        for (ch in word.lowercase()) {
            node = node.children[ch] ?: return 0
        }
        return node.frequency
    }

    private fun insertWord(root: TrieNode, key: String, word: String, frequency: Int = 1) {
        var node = root
        for (ch in key.lowercase()) {
            node = node.children.getOrPut(ch) { TrieNode() }
        }
        node.word = word
        node.frequency = frequency
    }

    private fun loadEnglishDictionary() {
        // Common English words — in production, load from a file
        val commonWords = listOf(
            "the", "be", "to", "of", "and", "a", "in", "that", "have", "I",
            "it", "for", "not", "on", "with", "he", "as", "you", "do", "at",
            "this", "but", "his", "by", "from", "they", "we", "say", "her",
            "she", "or", "an", "will", "my", "one", "all", "would", "there",
            "their", "what", "so", "up", "out", "if", "about", "who", "get",
            "which", "go", "me", "when", "make", "can", "like", "time", "no",
            "just", "him", "know", "take", "people", "into", "year", "your",
            "good", "some", "could", "them", "see", "other", "than", "then",
            "now", "look", "only", "come", "its", "over", "think", "also",
            "back", "after", "use", "two", "how", "our", "work", "first",
            "well", "way", "even", "new", "want", "because", "any", "these",
            "give", "day", "most", "us", "hello", "world", "please", "thank",
            "thanks", "sorry", "okay", "yes", "no", "maybe", "where", "here",
            "there", "today", "tomorrow", "yesterday", "morning", "night",
            "good", "great", "nice", "fine", "happy", "love", "like", "name",
            "phone", "home", "school", "water", "food", "help", "done",
            "message", "send", "call", "text", "email", "open", "close",
            "start", "stop", "play", "search", "find", "type", "write",
            "read", "going", "coming", "eating", "sleeping", "working",
            "beautiful", "wonderful", "amazing", "awesome", "perfect",
            "friend", "family", "brother", "sister", "mother", "father",
            "welcome", "goodbye", "evening", "afternoon", "address",
            "number", "keyboard", "language", "english", "hindi"
        )

        commonWords.forEachIndexed { index, word ->
            val frequency = commonWords.size - index // Higher frequency for common words
            insertWord(englishRoot, word, word, frequency)
        }

        // Try loading from assets
        try {
            val stream = context.assets.open("dictionary/english_words.txt")
            stream.bufferedReader().forEachLine { line ->
                val word = line.trim().lowercase()
                if (word.isNotEmpty() && word.length >= 2) {
                    insertWord(englishRoot, word, word, 1)
                }
            }
        } catch (e: Exception) {
            Log.d(TAG, "No english_words.txt found, using built-in list")
        }
    }

    private fun loadTransliterationDictionary() {
        try {
            val jsonString = context.assets.open("suggestions/suggestions.json")
                .bufferedReader().use { it.readText() }
            val jsonArray = JSONArray(jsonString)

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val kbdKey = obj.optString("kbd_key", "").lowercase()
                val hindi = obj.optString("hindi", "")
                val gondiWord = obj.optString("gondiword", "")
                val gondi = obj.optString("gondi", "")
                val english = obj.optString("english", "")

                if (kbdKey.isNotEmpty()) {
                    if (hindi.isNotEmpty()) {
                        insertWord(hindiRoot, kbdKey, hindi, 5)
                    }
                    val gondiOutput = gondiWord.ifEmpty { gondi }
                    if (gondiOutput.isNotEmpty()) {
                        insertWord(gondiRoot, kbdKey, gondiOutput, 5)
                    }
                    if (english.isNotEmpty()) {
                        insertWord(englishRoot, kbdKey, english, 3)
                    }
                }
            }
        } catch (e: Exception) {
            Log.d(TAG, "No suggestions.json found for glide dictionary")
        }
    }
}