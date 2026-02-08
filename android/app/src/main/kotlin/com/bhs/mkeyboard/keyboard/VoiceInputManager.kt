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
            KeyboardLanguage.GONDI -> "hi-IN"
            KeyboardLanguage.GUNJALA -> "hi-IN"
            KeyboardLanguage.CHIKI -> "hi-IN"
        }

        // Check actual permission state
        val permission = androidx.core.content.ContextCompat.checkSelfPermission(
            context, android.Manifest.permission.RECORD_AUDIO
        )
        if (permission != android.content.pm.PackageManager.PERMISSION_GRANTED) {
            _state.value = VoiceState.NO_PERMISSION
            _errorMessage.value = "Permission denied"
            return
        }

        stopListening()

        try {
            // Try to find Google's recognition service explicitely
            val componentName = findRecognitionComponent(context)
            Log.d(TAG, "Creating SpeechRecognizer with component: $componentName")

            speechRecognizer = if (componentName != null) {
                SpeechRecognizer.createSpeechRecognizer(context, componentName)
            } else {
                SpeechRecognizer.createSpeechRecognizer(context)
            }.apply {
                setRecognitionListener(createListener())
            }

            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, currentLanguage)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, currentLanguage)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
                putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.packageName)
                // Prefer offline recognition if available
                putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
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
            Log.e(TAG, "Error stopping", e)
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
            override fun onReadyForSpeech(params: Bundle?) { _state.value = VoiceState.LISTENING }
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) {
                 val normalized = ((rmsdB + 2f) / 12f).coerceIn(0f, 1f)
                _volumeLevel.value = normalized
            }
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() { 
                _state.value = VoiceState.PROCESSING 
                _volumeLevel.value = 0f
            }
            override fun onError(error: Int) {
                val message = when (error) {
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "No permission"
                    SpeechRecognizer.ERROR_NO_MATCH -> "No speech detected"
                    else -> "Error $error"
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
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val bestResult = matches?.firstOrNull() ?: ""
                _finalResult.value = bestResult
                _partialResult.value = ""
                _state.value = VoiceState.IDLE
                _volumeLevel.value = 0f
            }
            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                val partial = matches?.firstOrNull() ?: ""
                _partialResult.value = partial
            }
            override fun onEvent(eventType: Int, params: Bundle?) {}
        }
    }

    private fun findRecognitionComponent(context: Context): android.content.ComponentName? {
        try {
            val pm = context.packageManager
            val intent = Intent(android.speech.RecognitionService.SERVICE_INTERFACE)
            val list = pm.queryIntentServices(intent, 0)
            
            // Prefer Google
            val google = list.find { it.serviceInfo.packageName.contains("google", true) }
            return if (google != null) {
                android.content.ComponentName(google.serviceInfo.packageName, google.serviceInfo.name)
            } else {
                list.firstOrNull()?.let {
                    android.content.ComponentName(it.serviceInfo.packageName, it.serviceInfo.name)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error finding recognition service", e)
            return null
        }
    }
}