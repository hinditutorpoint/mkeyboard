package com.bhs.mkeyboard

import android.content.Context
import android.inputmethodservice.InputMethodService
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.util.Log
import android.view.Gravity
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class HindiKeyboardService : InputMethodService() {

    private var flutterEngine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var methodChannel: MethodChannel? = null
    private var rootLayout: View? = null

    companion object {
        const val IME_ENGINE_ID = "ime_engine"
        const val CHANNEL_NAME = "com.bhs.mkeyboard/keyboard"
        const val TAG = "HindiKeyboardService"
    }

    override fun onCreate() {
        super.onCreate()
        initFlutterEngine()
    }

    private fun initFlutterEngine() {
        try {
            val cache = FlutterEngineCache.getInstance()
            var engine = cache.get(IME_ENGINE_ID)

            if (engine == null) {
                engine = FlutterEngine(this)
                val loader = FlutterInjector.instance().flutterLoader()
                if (!loader.initialized()) loader.startInitialization(this)
                loader.ensureInitializationComplete(this, null)

                engine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "imeMain")
                )
                cache.put(IME_ENGINE_ID, engine)
            }

            flutterEngine = engine
            methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            setupMethodChannel()

        } catch (e: Exception) {
            Log.e(TAG, "Engine init failed: ${e.message}")
        }
    }

    override fun onCreateInputView(): View {
        // 1. Force the Service Window to be transparent
        window?.window?.setBackgroundDrawableResource(android.R.color.transparent)

        // 2. Load the XML Layout
        rootLayout = LayoutInflater.from(this).inflate(R.layout.keyboard_view, null)
        val container = rootLayout?.findViewById<FrameLayout>(R.id.flutter_container)

        // 3. Define Keyboard Height (Prevents 0-pixel/Collapsed view)
        val dm = resources.displayMetrics
        val keyboardHeight = (dm.heightPixels * 0.40).toInt() // 40% of screen height

        container?.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            keyboardHeight
        ).apply { gravity = Gravity.BOTTOM }

        // 4. Attach FlutterView
        flutterView = FlutterView(this)
        flutterView?.setBackgroundColor(0x00000000) // Transparent Flutter background
        
        flutterEngine?.let {
            flutterView?.attachToFlutterEngine(it)
        }

        container?.removeAllViews()
        container?.addView(flutterView)

        return rootLayout!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        
        flutterEngine?.lifecycleChannel?.appIsResumed()
        
        flutterView?.post {
            flutterView?.invalidate()
        }
        
        updateFullscreenMode()

        info?.let {
            methodChannel?.invokeMethod("onStartInput", mapOf(
                "inputType" to it.inputType,
                "imeOptions" to it.imeOptions,
                "packageName" to it.packageName
            ))
        }
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        // Put Flutter to sleep to save battery when keyboard is closed
        flutterEngine?.lifecycleChannel?.appIsInactive()
    }

    // --- Prevent Black Fullscreen Issues ---
    override fun onEvaluateFullscreenMode(): Boolean = false
    override fun onEvaluateInputViewShown(): Boolean = true
    override fun onUpdateExtractingViews(ei: EditorInfo?) {
        super.onUpdateExtractingViews(ei)
        setExtractViewShown(false)
    }

    private fun setupMethodChannel() {
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "inputText" -> {
                    val text = call.argument<String>("text") ?: ""
                    currentInputConnection?.commitText(text, 1)
                    result.success(true)
                }
                "deleteBackward" -> {
                    currentInputConnection?.deleteSurroundingText(1, 0)
                    result.success(true)
                }
                "sendKeyEvent" -> {
                    val keyCode = call.argument<Int>("keyCode") ?: 0
                    currentInputConnection?.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
                    currentInputConnection?.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
                    result.success(true)
                }
                "vibrate" -> {
                    val duration = (call.argument<Any>("duration") as? Number)?.toLong() ?: 50L
                    vibrate(duration)
                    result.success(true)
                }
                "hideKeyboard" -> {
                    requestHideSelf(0)
                    result.success(true)
                }
                "switchLanguage" -> {
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        switchToNextInputMethod(false)
                    } else {
                        imm.switchToNextInputMethod(window?.window?.attributes?.token, false)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun vibrate(duration: Long) {
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            vibrator.vibrate(duration)
        }
    }

    override fun onDestroy() {
        flutterView?.detachFromFlutterEngine()
        flutterView = null
        super.onDestroy()
    }
}