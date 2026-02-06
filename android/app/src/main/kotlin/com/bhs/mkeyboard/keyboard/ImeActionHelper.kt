package com.bhs.mkeyboard.keyboard

import android.text.InputType
import android.view.inputmethod.EditorInfo

/**
 * Detects the appropriate keyboard type and action button
 * based on EditorInfo from the input field.
 */
object ImeActionHelper {

    enum class KeyboardType {
        TEXT,       // Normal text input
        NUMBER,     // Number input (show number pad)
        PHONE,      // Phone number (show phone pad)
        EMAIL,      // Email address (show @ key prominently)
        URL,        // URL input (show .com, / keys)
        PASSWORD,   // Password (disable suggestions)
        SEARCH,     // Search field
        DECIMAL     // Decimal number (number pad + dot)
    }

    enum class ActionButton(val label: String, val icon: String) {
        ENTER("Enter", "↵"),
        SEARCH("Search", "🔍"),
        GO("Go", "→"),
        SEND("Send", "➤"),
        NEXT("Next", "→"),
        DONE("Done", "✓"),
        NONE("", "↵")
    }

    data class InputConfig(
        val keyboardType: KeyboardType,
        val actionButton: ActionButton,
        val imeAction: Int,
        val disableSuggestions: Boolean = false,
        val disableTransliteration: Boolean = false
    )

    fun getInputConfig(editorInfo: EditorInfo?): InputConfig {
        if (editorInfo == null) {
            return InputConfig(
                keyboardType = KeyboardType.TEXT,
                actionButton = ActionButton.ENTER,
                imeAction = EditorInfo.IME_ACTION_UNSPECIFIED
            )
        }

        val inputType = editorInfo.inputType
        val imeOptions = editorInfo.imeOptions

        // Detect keyboard type from inputType
        val keyboardType = detectKeyboardType(inputType)

        // Detect action button from imeOptions
        val imeAction = imeOptions and EditorInfo.IME_MASK_ACTION
        val actionButton = detectActionButton(imeAction, imeOptions)

        // Should we disable suggestions?
        val noSuggestions = (inputType and InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS) != 0

        // Should we disable transliteration?
        val disableTranslit = keyboardType == KeyboardType.PASSWORD ||
                keyboardType == KeyboardType.EMAIL ||
                keyboardType == KeyboardType.URL ||
                keyboardType == KeyboardType.NUMBER ||
                keyboardType == KeyboardType.PHONE ||
                keyboardType == KeyboardType.DECIMAL

        return InputConfig(
            keyboardType = keyboardType,
            actionButton = actionButton,
            imeAction = imeAction,
            disableSuggestions = noSuggestions || keyboardType == KeyboardType.PASSWORD,
            disableTransliteration = disableTranslit
        )
    }

    private fun detectKeyboardType(inputType: Int): KeyboardType {
        val typeClass = inputType and InputType.TYPE_MASK_CLASS
        val typeVariation = inputType and InputType.TYPE_MASK_VARIATION

        return when (typeClass) {
            InputType.TYPE_CLASS_NUMBER -> {
                if ((inputType and InputType.TYPE_NUMBER_FLAG_DECIMAL) != 0) {
                    KeyboardType.DECIMAL
                } else {
                    KeyboardType.NUMBER
                }
            }
            InputType.TYPE_CLASS_PHONE -> KeyboardType.PHONE
            InputType.TYPE_CLASS_TEXT -> {
                when (typeVariation) {
                    InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS,
                    InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS -> KeyboardType.EMAIL

                    InputType.TYPE_TEXT_VARIATION_URI -> KeyboardType.URL

                    InputType.TYPE_TEXT_VARIATION_PASSWORD,
                    InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD,
                    InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD -> KeyboardType.PASSWORD

                    InputType.TYPE_TEXT_VARIATION_FILTER,
                    InputType.TYPE_TEXT_VARIATION_WEB_EDIT_TEXT -> KeyboardType.TEXT

                    else -> KeyboardType.TEXT
                }
            }
            else -> KeyboardType.TEXT
        }
    }

    private fun detectActionButton(imeAction: Int, imeOptions: Int): ActionButton {
        // Check if actionNone is explicitly set
        if ((imeOptions and EditorInfo.IME_FLAG_NO_ENTER_ACTION) != 0) {
            return ActionButton.ENTER
        }

        return when (imeAction) {
            EditorInfo.IME_ACTION_SEARCH -> ActionButton.SEARCH
            EditorInfo.IME_ACTION_GO -> ActionButton.GO
            EditorInfo.IME_ACTION_SEND -> ActionButton.SEND
            EditorInfo.IME_ACTION_NEXT -> ActionButton.NEXT
            EditorInfo.IME_ACTION_DONE -> ActionButton.DONE
            EditorInfo.IME_ACTION_NONE -> ActionButton.ENTER
            EditorInfo.IME_ACTION_UNSPECIFIED -> ActionButton.ENTER
            else -> ActionButton.ENTER
        }
    }
}