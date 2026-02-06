package com.bhs.mkeyboard

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.inputmethodservice.InputMethodService
import androidx.compose.runtime.Recomposer
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.AndroidUiDispatcher
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.compositionContext
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.bhs.mkeyboard.keyboard.*
import com.bhs.mkeyboard.transliteration.Transliterator
import com.bhs.mkeyboard.transliteration.HindiTransliterator
import com.bhs.mkeyboard.transliteration.GondiTransliterator
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class HindiKeyboardService : InputMethodService(),
    LifecycleOwner, ViewModelStoreOwner, SavedStateRegistryOwner {

    companion object {
        const val TAG = "HindiKeyboardService"
    }

    private val lifecycleRegistry = LifecycleRegistry(this)
    private val savedStateRegistryController = SavedStateRegistryController.create(this)
    private val store = ViewModelStore()

    private var settingsVersion by mutableIntStateOf(0)

    private var coroutineScope: CoroutineScope? = null
    private var recomposer: Recomposer? = null

    private val hindiTransliterator = HindiTransliterator()
    private val gondiTransliterator = GondiTransliterator()
    private var currentTransliterator: Transliterator? = null
    private var currentLanguage = KeyboardLanguage.ENGLISH

    private var composingTextState by mutableStateOf("")
    private var transliteratedTextState by mutableStateOf("")

    // Input field configuration
    var inputConfig by mutableStateOf(ImeActionHelper.InputConfig(
        keyboardType = ImeActionHelper.KeyboardType.TEXT,
        actionButton = ImeActionHelper.ActionButton.ENTER,
        imeAction = EditorInfo.IME_ACTION_UNSPECIFIED
    ))
        private set

    // Voice input
    private lateinit var voiceInputManager: VoiceInputManager
    var voiceState by mutableStateOf(VoiceInputManager.VoiceState.IDLE)
        private set
    var voicePartialResult by mutableStateOf("")
        private set
    var voiceErrorMessage by mutableStateOf<String?>(null)
        private set
    var voiceVolumeLevel by mutableStateOf(0f)
        private set
    var isVoiceActive by mutableStateOf(false)
        private set

    // Glide typing
    lateinit var glideDetector: GlideTypingDetector
        private set
    lateinit var glideDictionary: GlideDictionary
        private set
    var glideTrailPoints by mutableStateOf<List<GlideTypingDetector.GlidePoint>>(emptyList())
        private set
    var glideSuggestions by mutableStateOf<List<String>>(emptyList())
        private set
    var isGlideActive by mutableStateOf(false)
        private set

    // Settings
    private lateinit var keyboardSettings: KeyboardSettings

    override val lifecycle: Lifecycle get() = lifecycleRegistry
    override val viewModelStore: ViewModelStore get() = store
    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    override fun onCreate() {
        super.onCreate()
        savedStateRegistryController.performRestore(null)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)

        keyboardSettings = KeyboardSettings(this)

        coroutineScope = CoroutineScope(SupervisorJob() + AndroidUiDispatcher.Main)
        recomposer = Recomposer(AndroidUiDispatcher.Main)
        coroutineScope?.launch { recomposer?.runRecomposeAndApplyChanges() }

        // Initialize voice input
        voiceInputManager = VoiceInputManager(this)

        // Initialize glide typing
        glideDetector = GlideTypingDetector()
        glideDictionary = GlideDictionary(this)
        coroutineScope?.launch { glideDictionary.load() }

        // Observe voice state
        coroutineScope?.launch {
            voiceInputManager.state.collectLatest { state ->
                voiceState = state
                if (state == VoiceInputManager.VoiceState.IDLE && isVoiceActive) {
                    val result = voiceInputManager.finalResult.value
                    if (result.isNotEmpty()) {
                        commitText(result)
                        commitText(" ")
                    }
                    isVoiceActive = false
                }
            }
        }
        coroutineScope?.launch {
            voiceInputManager.partialResult.collectLatest { voicePartialResult = it }
        }
        coroutineScope?.launch {
            voiceInputManager.errorMessage.collectLatest { voiceErrorMessage = it }
        }
        coroutineScope?.launch {
            voiceInputManager.volumeLevel.collectLatest { voiceVolumeLevel = it }
        }

        // Restore last language
        val savedIndex = keyboardSettings.getStartupLanguageIndex()
        currentLanguage = KeyboardLanguage.entries[savedIndex]
        updateTransliterator(currentLanguage)
    }

    override fun onCreateInputView(): View {
        Log.d(TAG, "onCreateInputView")

        if (!lifecycleRegistry.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            if (!lifecycleRegistry.currentState.isAtLeast(Lifecycle.State.STARTED))
                lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
            lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        }

        val composeView = ComposeView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            setViewTreeLifecycleOwner(this@HindiKeyboardService)
            setViewTreeViewModelStoreOwner(this@HindiKeyboardService)
            setViewTreeSavedStateRegistryOwner(this@HindiKeyboardService)
        }

        recomposer?.let { composeView.compositionContext = it }

        composeView.setContent {
            KeyboardView(
                onInput = { text, isRaw -> handleInput(text, isRaw) },
                onBackspace = { handleBackspace() },
                onEnter = { handleAction() },
                onSpace = { handleSpace() },
                onSettingsClick = { openApp() },
                onLanguageChanged = { lang -> updateTransliterator(lang) },
                settingsVersion = settingsVersion,
                composingText = composingTextState,
                transliteratedText = transliteratedTextState,
                onSuggestionSelected = { handleSuggestionSelected(it) },
                inputConfig = inputConfig,
                // Voice
                onVoiceInput = { startVoiceInput() },
                onVoiceStop = { stopVoiceInput() },
                onVoiceClose = { closeVoiceInput() },
                onVoiceRetry = { startVoiceInput() },
                isVoiceActive = isVoiceActive,
                voiceState = voiceState,
                voicePartialResult = voicePartialResult,
                voiceErrorMessage = voiceErrorMessage,
                voiceVolumeLevel = voiceVolumeLevel,
                // Glide
                onGlideStart = { x, y -> handleGlideStart(x, y) },
                onGlideMove = { x, y -> handleGlideMove(x, y) },
                onGlideEnd = { handleGlideEnd() },
                glideTrailPoints = glideTrailPoints,
                glideSuggestions = glideSuggestions,
                isGlideActive = isGlideActive,
                onGlideSuggestionSelected = { handleGlideSuggestionSelected(it) }
            )
        }

        return composeView
    }

    // ── Input field detection ───────────────────────────────────────

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        settingsVersion++

        // Detect input type and action button
        inputConfig = ImeActionHelper.getInputConfig(info)
        Log.d(TAG, "Input type: ${inputConfig.keyboardType}, action: ${inputConfig.actionButton}")

        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        resetComposing()
        glideSuggestions = emptyList()

        // Restore saved language (don't reset to English)
        val savedIndex = keyboardSettings.getStartupLanguageIndex()
        val savedLang = KeyboardLanguage.entries[savedIndex]
        if (currentLanguage != savedLang && !restarting) {
            currentLanguage = savedLang
            updateTransliterator(currentLanguage)
        }
    }

    // ── Action button handling ──────────────────────────────────────

    private fun handleAction() {
        commitPendingComposing()

        val ic = currentInputConnection ?: return

        when (inputConfig.imeAction) {
            EditorInfo.IME_ACTION_SEARCH -> ic.performEditorAction(EditorInfo.IME_ACTION_SEARCH)
            EditorInfo.IME_ACTION_GO -> ic.performEditorAction(EditorInfo.IME_ACTION_GO)
            EditorInfo.IME_ACTION_SEND -> ic.performEditorAction(EditorInfo.IME_ACTION_SEND)
            EditorInfo.IME_ACTION_NEXT -> ic.performEditorAction(EditorInfo.IME_ACTION_NEXT)
            EditorInfo.IME_ACTION_DONE -> ic.performEditorAction(EditorInfo.IME_ACTION_DONE)
            else -> {
                // Default: send Enter key
                ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
                ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER))
            }
        }
    }

    // ── Transliteration ─────────────────────────────────────────────

    private fun updateTransliterator(lang: KeyboardLanguage) {
        currentLanguage = lang

        // Save language choice
        keyboardSettings.lastLanguageIndex = lang.ordinal

        // Disable transliteration for URL/email/password/number fields
        if (inputConfig.disableTransliteration) {
            currentTransliterator = null
        } else {
            currentTransliterator = when (lang) {
                KeyboardLanguage.HINDI -> hindiTransliterator
                KeyboardLanguage.GONDI -> gondiTransliterator
                KeyboardLanguage.ENGLISH -> null
            }
        }
        resetComposing()
    }

    private fun handleInput(text: String, isRaw: Boolean = false) {
        if (isRaw || inputConfig.disableTransliteration) {
            commitPendingComposing()
            commitText(text)
            return
        }

        composingTextState += text

        val transliterator = currentTransliterator
        if (transliterator != null) {
            val transliterated = transliterator.transliterate(composingTextState)
            transliteratedTextState = transliterated
            setComposingText(transliterated)
        } else {
            transliteratedTextState = composingTextState
            setComposingText(composingTextState)
        }
    }

    private fun handleSuggestionSelected(suggestion: String) {
        composingTextState = ""
        transliteratedTextState = ""
        currentInputConnection?.setComposingText("", 0)
        currentInputConnection?.finishComposingText()
        currentInputConnection?.commitText(suggestion, 1)
        currentInputConnection?.commitText(" ", 1)
    }

    private fun handleBackspace() {
        if (composingTextState.isNotEmpty()) {
            composingTextState = composingTextState.dropLast(1)
            if (composingTextState.isEmpty()) {
                transliteratedTextState = ""
                currentInputConnection?.finishComposingText()
                deleteBackward()
            } else {
                val transliterator = currentTransliterator
                if (transliterator != null) {
                    val transliterated = transliterator.transliterate(composingTextState)
                    transliteratedTextState = transliterated
                    setComposingText(transliterated)
                } else {
                    transliteratedTextState = composingTextState
                    setComposingText(composingTextState)
                }
            }
        } else {
            deleteBackward()
        }
    }

    private fun handleSpace() {
        commitPendingComposing()
        commitText(" ")
    }

    private fun commitPendingComposing() {
        if (composingTextState.isNotEmpty()) {
            val transliterator = currentTransliterator
            val finalText = transliterator?.transliterate(composingTextState) ?: composingTextState
            commitText(finalText)
            resetComposing()
        }
    }

    private fun resetComposing() {
        composingTextState = ""
        transliteratedTextState = ""
    }

    private fun setComposingText(text: String) {
        currentInputConnection?.setComposingText(text, 1)
    }

    // ── Voice Input ─────────────────────────────────────────────────

    private fun startVoiceInput() {
        if (!hasRecordAudioPermission()) {
            // Launch permission request activity
            requestMicrophonePermission()
            return
        }

        commitPendingComposing()
        isVoiceActive = true
        voiceInputManager.startListening(currentLanguage)
    }

    private fun stopVoiceInput() {
        voiceInputManager.stopListening()
    }

    private fun closeVoiceInput() {
        voiceInputManager.reset()
        isVoiceActive = false
        voicePartialResult = ""
        voiceErrorMessage = null
        voiceVolumeLevel = 0f
    }

    private fun hasRecordAudioPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this, Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestMicrophonePermission() {
        try {
            // Try launching the permission request activity
            val intent = Intent(this, MicPermissionActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch permission activity", e)
            // Fallback: open app settings
            openAppSettings()
        }
    }

    private fun openAppSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open app settings", e)
        }
    }

    // ── Glide Typing ────────────────────────────────────────────────

    private fun handleGlideStart(x: Float, y: Float) {
        commitPendingComposing()
        glideDetector.onGlideStart(x, y)
        isGlideActive = true
        glideSuggestions = emptyList()
        glideTrailPoints = glideDetector.getTracePath()
    }

    private fun handleGlideMove(x: Float, y: Float) {
        glideDetector.onGlideMove(x, y)
        glideTrailPoints = glideDetector.getTracePath()
    }

    private fun handleGlideEnd() {
        val keySequence = glideDetector.onGlideEnd()
        isGlideActive = false
        glideTrailPoints = emptyList()

        if (keySequence.isNotEmpty()) {
            val matches = glideDictionary.findMatches(
                keySequence = keySequence,
                languageIndex = currentLanguage.ordinal,
                limit = 5
            )

            if (matches.isNotEmpty()) {
                glideSuggestions = matches
                val firstMatch = matches.first()
                commitText(firstMatch)
                commitText(" ")
            } else {
                glideSuggestions = emptyList()
                val transliterator = currentTransliterator
                if (transliterator != null) {
                    commitText(transliterator.transliterate(keySequence))
                } else {
                    commitText(keySequence)
                }
                commitText(" ")
            }
        }
    }

    private fun handleGlideSuggestionSelected(word: String) {
        val deleteCount = glideSuggestions.firstOrNull()?.length?.plus(1) ?: 0
        if (deleteCount > 0) {
            currentInputConnection?.deleteSurroundingText(deleteCount, 0)
        }
        commitText(word)
        commitText(" ")
        glideSuggestions = emptyList()
    }

    // ── Lifecycle ───────────────────────────────────────────────────

    override fun onFinishInputView(finishingInput: Boolean) {
        commitPendingComposing()
        closeVoiceInput()
        glideDetector.cancelGlide()
        glideSuggestions = emptyList()
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
        super.onFinishInputView(finishingInput)
    }

    override fun onDestroy() {
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
        voiceInputManager.reset()
        recomposer?.cancel()
        coroutineScope?.cancel()
        recomposer = null
        coroutineScope = null
        store.clear()
        super.onDestroy()
    }

    override fun onEvaluateFullscreenMode(): Boolean = false
    override fun onEvaluateInputViewShown(): Boolean = true

    // ── Helpers ──────────────────────────────────────────────────────

    private fun commitText(text: String) {
        currentInputConnection?.commitText(text, 1)
    }

    private fun deleteBackward() {
        currentInputConnection?.deleteSurroundingText(1, 0)
    }

    private fun openApp() {
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error opening app", e)
        }
    }
}