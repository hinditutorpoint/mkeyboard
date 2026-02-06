package com.bhs.mkeyboard.keyboard

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class VoiceInputManager(private val context: Context) {

    companion object {
        private const val TAG = "VoiceInputManager"
    }

    enum class VoiceState {
        IDLE,
        LISTENING,
        PROCESSING,
        ERROR,
        NO_PERMISSION
    }

    private val _state = MutableStateFlow(VoiceState.IDLE)
    val state: StateFlow<VoiceState> = _state.asStateFlow()

    private val _partialResult = MutableStateFlow("")
    val partialResult: StateFlow<String> = _partialResult.asStateFlow()

    private val _finalResult = MutableStateFlow("")
    val finalResult: StateFlow<String> = _finalResult.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _volumeLevel = MutableStateFlow(0f)
    val volumeLevel: StateFlow<Float> = _volumeLevel.asStateFlow()

    private var speechRecognizer: SpeechRecognizer? = null
    private var currentLanguage: String = "en-US"

    fun isAvailable(): Boolean {
        return SpeechRecognizer.isRecognitionAvailable(context)
    }

    fun startListening(language: KeyboardLanguage) {
        if (!isAvailable()) {
            _state.value = VoiceState.ERROR
            _errorMessage.value = "Speech recognition not available"
            return
        }

        currentLanguage = when (language) {
            KeyboardLanguage.ENGLISH -> "en-US"
            KeyboardLanguage.HINDI -> "hi-IN"
            KeyboardLanguage.GONDI -> "hi-IN" // Fallback to Hindi for Gondi
        }

        // Release previous recognizer
        stopListening()

        try {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
                setRecognitionListener(createListener())
            }

            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(
                    RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                    RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
                )
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, currentLanguage)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, currentLanguage)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
                putExtra(
                    RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS,
                    3000L
                )
                putExtra(
                    RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS,
                    1500L
                )
                putExtra(
                    RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS,
                    1500L
                )
            }

            _state.value = VoiceState.LISTENING
            _partialResult.value = ""
            _finalResult.value = ""
            _errorMessage.value = null

            speechRecognizer?.startListening(intent)
            Log.d(TAG, "Started listening in $currentLanguage")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting speech recognition", e)
            _state.value = VoiceState.ERROR
            _errorMessage.value = "Failed to start: ${e.message}"
        }
    }

    fun stopListening() {
        try {
            speechRecognizer?.stopListening()
            speechRecognizer?.cancel()
            speechRecognizer?.destroy()
            speechRecognizer = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping speech recognition", e)
        }
        if (_state.value == VoiceState.LISTENING) {
            _state.value = VoiceState.IDLE
        }
    }

    fun reset() {
        stopListening()
        _state.value = VoiceState.IDLE
        _partialResult.value = ""
        _finalResult.value = ""
        _errorMessage.value = null
        _volumeLevel.value = 0f
    }

    private fun createListener(): RecognitionListener {
        return object : RecognitionListener {

            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(TAG, "Ready for speech")
                _state.value = VoiceState.LISTENING
            }

            override fun onBeginningOfSpeech() {
                Log.d(TAG, "Speech started")
            }

            override fun onRmsChanged(rmsdB: Float) {
                // Normalize volume: RMS typically ranges from -2 to 10
                val normalized = ((rmsdB + 2f) / 12f).coerceIn(0f, 1f)
                _volumeLevel.value = normalized
            }

            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                Log.d(TAG, "Speech ended")
                _state.value = VoiceState.PROCESSING
                _volumeLevel.value = 0f
            }

            override fun onError(error: Int) {
                val message = when (error) {
                    SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                    SpeechRecognizer.ERROR_CLIENT -> "Client error"
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "No permission"
                    SpeechRecognizer.ERROR_NETWORK -> "Network error"
                    SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Network timeout"
                    SpeechRecognizer.ERROR_NO_MATCH -> "No speech detected"
                    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Recognizer busy"
                    SpeechRecognizer.ERROR_SERVER -> "Server error"
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "No speech heard"
                    else -> "Unknown error ($error)"
                }
                Log.e(TAG, "Speech error: $message")

                if (error == SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS) {
                    _state.value = VoiceState.NO_PERMISSION
                } else {
                    _state.value = VoiceState.ERROR
                }
                _errorMessage.value = message
                _volumeLevel.value = 0f
            }

            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(
                    SpeechRecognizer.RESULTS_RECOGNITION
                )
                val bestResult = matches?.firstOrNull() ?: ""
                Log.d(TAG, "Final result: $bestResult")

                _finalResult.value = bestResult
                _partialResult.value = ""
                _state.value = VoiceState.IDLE
                _volumeLevel.value = 0f
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(
                    SpeechRecognizer.RESULTS_RECOGNITION
                )
                val partial = matches?.firstOrNull() ?: ""
                Log.d(TAG, "Partial: $partial")
                _partialResult.value = partial
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        }
    }
}