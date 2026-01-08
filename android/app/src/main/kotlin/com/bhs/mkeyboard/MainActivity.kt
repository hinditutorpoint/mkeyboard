package com.bhs.mkeyboard

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity
 *
 * PURPOSE:
 * - App open screen
 * - Keyboard enable/disable helpers
 * - InputMethod picker
 *
 * ❌ NOT USED FOR IME UI
 * ❌ DOES NOT CREATE FlutterEngine for keyboard
 */
class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "com.bhs.mkeyboard/settings"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // Opens Android keyboard enable screen
                "openKeyboardSettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    )
                    result.success(true)
                }

                // Shows IME picker popup
                "showInputMethodPicker" -> {
                    (getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager)
                        .showInputMethodPicker()
                    result.success(true)
                }

                // Check if keyboard is enabled in system
                "isKeyboardEnabled" -> {
                    val imm =
                        getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                    result.success(
                        imm.enabledInputMethodList.any {
                            it.packageName == packageName
                        }
                    )
                }

                // Check if keyboard is currently selected
                "isKeyboardSelected" -> {
                    val currentIme = Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.DEFAULT_INPUT_METHOD
                    )
                    result.success(currentIme?.contains(packageName) == true)
                }

                else -> result.notImplemented()
            }
        }
    }
}
