package com.bhs.mkeyboard.keyboard

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.roundToInt

/**
 * Gboard-style key popup overlay.
 * Renders WITHIN the keyboard Box using matchParentSize — never changes keyboard size.
 * 
 * Shows:
 * 1. Key preview bubble (on press) — magnified character above the key
 * 2. Variant strip (on long press) — horizontal scrollable row
 */
@Composable
fun KeyPopupOverlay(
    popupState: KeyPopupState,
    theme: KeyboardTheme,
    hasWallpaper: Boolean,
    hapticEnabled: Boolean,
    modifier: Modifier = Modifier
) {
    if (!popupState.isActive()) return

    val density = LocalDensity.current

    val bubbleBg = if (hasWallpaper) Color(0xEE333333) else theme.keyColor
    val bubbleText = if (hasWallpaper) Color.White else theme.textColor
    val stripBg = if (hasWallpaper) Color(0xEE222222) else theme.backgroundColor
    val stripItemBg = if (hasWallpaper) Color.White.copy(alpha = 0.15f) else theme.keyColor
    val stripItemText = if (hasWallpaper) Color.White else theme.textColor

    val keyBounds = popupState.keyBounds
    val keyCenterX = keyBounds.left + keyBounds.width / 2f

    // Use a Box with fillMaxSize — but it doesn't CAUSE the parent to grow
    // because the parent uses matchParentSize on this composable
    Box(modifier = modifier) {
        if (popupState.isExpanded && popupState.variants.isNotEmpty()) {
            // ── VARIANT STRIP ───────────────────────────────────
            val stripHeight = with(density) { 54.dp.toPx() }
            val gap = with(density) { 6.dp.toPx() }

            // Position: above the key, clamped to not go above keyboard top (y=0)
            val stripY = (keyBounds.top - stripHeight - gap)
                .coerceAtLeast(0f)
                .roundToInt()

            // Center horizontally on the key, clamped to screen
            val stripMaxWidth = with(density) { 320.dp.toPx() }

            Box(
                modifier = Modifier
                    .offset { IntOffset(0, stripY) }
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp)
            ) {
                val scrollState = rememberScrollState()

                Box(
                    modifier = Modifier
                        .align(Alignment.Center)
                        .widthIn(max = 320.dp)
                        .shadow(
                            elevation = 8.dp,
                            shape = RoundedCornerShape(12.dp)
                        )
                        .background(
                            color = stripBg,
                            shape = RoundedCornerShape(12.dp)
                        )
                        .padding(6.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .horizontalScroll(scrollState)
                            .padding(horizontal = 2.dp),
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        popupState.variants.forEach { variant ->
                            Box(
                                modifier = Modifier
                                    .size(44.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(stripItemBg)
                                    .clickable(
                                        interactionSource = remember { MutableInteractionSource() },
                                        indication = null
                                    ) {
                                        popupState.onVariantSelected?.invoke(variant)
                                        popupState.dismiss()
                                    },
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = variant,
                                    color = stripItemText,
                                    fontSize = 20.sp,
                                    fontFamily = popupState.previewFontFamily,
                                    fontWeight = FontWeight.Medium,
                                    textAlign = TextAlign.Center
                                )
                            }
                        }
                    }
                }
            }
        } else if (popupState.isPreviewVisible && popupState.previewLabel != null) {
            // ── KEY PREVIEW BUBBLE ──────────────────────────────
            val bubbleSizeDp = 56.dp
            val bubbleSizePx = with(density) { bubbleSizeDp.toPx() }
            val gap = with(density) { 4.dp.toPx() }

            val bubbleX = (keyCenterX - bubbleSizePx / 2f)
                .coerceAtLeast(0f)
                .roundToInt()
            val bubbleY = (keyBounds.top - bubbleSizePx - gap)
                .coerceAtLeast(0f)
                .roundToInt()

            Box(
                modifier = Modifier
                    .offset { IntOffset(bubbleX, bubbleY) }
                    .size(bubbleSizeDp)
                    .shadow(
                        elevation = 6.dp,
                        shape = RoundedCornerShape(10.dp)
                    )
                    .background(
                        color = bubbleBg,
                        shape = RoundedCornerShape(10.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = popupState.previewLabel ?: "",
                    color = bubbleText,
                    fontSize = 28.sp,
                    fontFamily = popupState.previewFontFamily,
                    fontWeight = FontWeight.Medium,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}