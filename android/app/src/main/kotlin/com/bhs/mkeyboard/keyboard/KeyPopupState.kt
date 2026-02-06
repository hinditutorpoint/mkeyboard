package com.bhs.mkeyboard.keyboard

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.text.font.FontFamily

class KeyPopupState {
    var previewLabel by mutableStateOf<String?>(null)
        private set

    var previewFontFamily by mutableStateOf<FontFamily?>(null)
        private set

    var keyBounds by mutableStateOf(Rect.Zero)
        private set

    var variants by mutableStateOf<List<String>>(emptyList())
        private set

    var isExpanded by mutableStateOf(false)
        private set

    var isPreviewVisible by mutableStateOf(false)
        private set

    var onVariantSelected: ((String) -> Unit)? = null
        private set

    fun showPreview(
        label: String,
        bounds: Rect,
        fontFamily: FontFamily? = null
    ) {
        previewLabel = label
        keyBounds = bounds
        previewFontFamily = fontFamily
        isPreviewVisible = true
        isExpanded = false
        variants = emptyList()
    }

    fun expandToVariants(
        variantList: List<String>,
        onSelected: (String) -> Unit
    ) {
        if (variantList.isEmpty()) return
        variants = variantList
        onVariantSelected = onSelected
        isExpanded = true
    }

    fun hidePreview() {
        isPreviewVisible = false
        if (!isExpanded) {
            dismiss()
        }
    }

    fun dismiss() {
        previewLabel = null
        previewFontFamily = null
        keyBounds = Rect.Zero
        variants = emptyList()
        isExpanded = false
        isPreviewVisible = false
        onVariantSelected = null
    }

    fun isActive(): Boolean = isPreviewVisible || isExpanded
}