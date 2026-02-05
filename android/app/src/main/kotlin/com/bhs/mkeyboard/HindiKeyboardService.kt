package com.bhs.mkeyboard

import android.content.Context
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.inputmethodservice.InputMethodService
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.compose.runtime.Recomposer
import androidx.compose.ui.platform.AndroidUiDispatcher
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.compositionContext
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
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.findViewTreeViewModelStoreOwner
import androidx.savedstate.findViewTreeSavedStateRegistryOwner
import com.bhs.mkeyboard.keyboard.KeyboardView
import com.bhs.mkeyboard.keyboard.KeyboardLanguage
import com.bhs.mkeyboard.transliteration.Transliterator
import com.bhs.mkeyboard.transliteration.HindiTransliterator
import com.bhs.mkeyboard.transliteration.GondiTransliterator
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class HindiKeyboardService : InputMethodService(), LifecycleOwner, ViewModelStoreOwner, SavedStateRegistryOwner {

    companion object {
        const val TAG = "HindiKeyboardService"
    }

    private val lifecycleRegistry = LifecycleRegistry(this)
    private val savedStateRegistryController = SavedStateRegistryController.create(this)
    private val store = ViewModelStore()
    
    // Coroutine scope for Recomposer
    private var coroutineScope: CoroutineScope? = null
    private var recomposer: Recomposer? = null
    
    // Transliteration state
    private val hindiTransliterator = HindiTransliterator()
    private val gondiTransliterator = GondiTransliterator()
    private var currentTransliterator: Transliterator? = null
    
    // Composing text for transliteration
    private var composingText = StringBuilder()
    
    override val lifecycle: Lifecycle
        get() = lifecycleRegistry

    override val viewModelStore: ViewModelStore
        get() = store
    
    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    override fun onCreate() {
        super.onCreate()
        savedStateRegistryController.performRestore(null)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)
        
        // Create Recomposer with AndroidUiDispatcher
        coroutineScope = CoroutineScope(SupervisorJob() + AndroidUiDispatcher.Main)
        recomposer = Recomposer(AndroidUiDispatcher.Main)
        
        // Launch the recomposer runRecomposeAndApplyChanges loop
        coroutineScope?.launch {
            recomposer?.runRecomposeAndApplyChanges()
        }
    }

    override fun onCreateInputView(): View {
        Log.d(TAG, "onCreateInputView: Creating ComposeView")
        
        // Ensure lifecycle is at RESUMED state
        if (!lifecycleRegistry.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            if (!lifecycleRegistry.currentState.isAtLeast(Lifecycle.State.STARTED)) {
                lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
            }
            lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        }
        
        val composeView = ComposeView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            
            // Set lifecycle owners directly on ComposeView
            setViewTreeLifecycleOwner(this@HindiKeyboardService)
            setViewTreeViewModelStoreOwner(this@HindiKeyboardService)
            setViewTreeSavedStateRegistryOwner(this@HindiKeyboardService)
        }
        
        // Set our custom recomposer as the compositionContext
        // This bypasses the WindowRecomposer lookup that walks up the view tree
        recomposer?.let { composeView.compositionContext = it }
        
        composeView.setContent {
            Log.d(TAG, "setContent: Composing KeyboardView")
            KeyboardView(
                onInput = { text, isRaw -> handleInput(text, isRaw) },
                onBackspace = { handleBackspace() },
                onEnter = { handleEnter() },
                onSpace = { handleSpace() },
                onSettingsClick = { openApp() },
                onLanguageChanged = { lang -> updateTransliterator(lang) }
            )
        }
        
        Log.d(TAG, "Returning ComposeView")
        return composeView
    }
    
    private fun updateTransliterator(lang: KeyboardLanguage) {
        currentTransliterator = when (lang) {
            KeyboardLanguage.HINDI -> hindiTransliterator
            KeyboardLanguage.GONDI -> gondiTransliterator
            KeyboardLanguage.ENGLISH -> null
        }
        resetComposing()
    }

    private fun handleInput(text: String, isRaw: Boolean = false) {
        // If raw input (e.g. symbols, numbers in symbol layout), commit directly
        if (isRaw) {
            if (composingText.isNotEmpty()) {
                val transliterator = currentTransliterator
                if (transliterator != null) {
                    commitText(transliterator.transliterate(composingText.toString()))
                } else {
                    commitText(composingText.toString())
                }
                resetComposing()
            }
            commitText(text)
            return
        }

        val transliterator = currentTransliterator
        
        if (transliterator != null) {
            composingText.append(text)
            val transliterated = transliterator.transliterate(composingText.toString())
            setComposingText(transliterated)
        } else {
            // English - direct commit
            commitText(text)
        }
    }
    
    private fun handleBackspace() {
        if (composingText.isNotEmpty()) {
            composingText.deleteCharAt(composingText.length - 1)
            if (composingText.isEmpty()) {
                currentInputConnection?.commitText("", 1) // Clear composing span
            } else {
                val transliterator = currentTransliterator
                if (transliterator != null) {
                     val transliterated = transliterator.transliterate(composingText.toString())
                     setComposingText(transliterated)
                }
            }
        } else {
            deleteBackward()
        }
    }
    
    private fun handleSpace() {
        if (composingText.isNotEmpty()) {
             // Commit the transliterated word, then the space
             val transliterator = currentTransliterator
             if (transliterator != null) {
                 val finalWord = transliterator.transliterate(composingText.toString())
                 commitText(finalWord) // Commit finishes composing
             }
             resetComposing()
        }
        commitText(" ")
    }
    
    private fun handleEnter() {
        if (composingText.isNotEmpty()) {
             val transliterator = currentTransliterator
             if (transliterator != null) {
                 val finalWord = transliterator.transliterate(composingText.toString())
                 commitText(finalWord)
             }
             resetComposing()
        }
        sendEnterKey()
    }
    
    private fun resetComposing() {
        composingText.setLength(0)
    }
    
    private fun setComposingText(text: String) {
        currentInputConnection?.setComposingText(text, 1)
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        resetComposing()
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        // Commit any pending composing text
        if (composingText.isNotEmpty() && currentTransliterator != null) {
            commitText(currentTransliterator!!.transliterate(composingText.toString()))
            resetComposing()
        }
        
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
        super.onFinishInputView(finishingInput)
    }

    override fun onDestroy() {
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
        
        // Clean up Recomposer and coroutine scope
        recomposer?.cancel()
        coroutineScope?.cancel()
        recomposer = null
        coroutineScope = null
        
        store.clear()
        super.onDestroy()
    }

    override fun onEvaluateFullscreenMode(): Boolean = false
    override fun onEvaluateInputViewShown(): Boolean = true

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
                intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } else {
                Log.e(TAG, "Launch intent not found for package: $packageName")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error opening app", e)
        }
    }

    private fun sendEnterKey() {
        currentInputConnection?.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
        currentInputConnection?.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER))
    }
}