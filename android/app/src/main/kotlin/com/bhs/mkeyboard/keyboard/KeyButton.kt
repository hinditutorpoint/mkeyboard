@file:OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
@file:Suppress("DEPRECATION")
package com.bhs.mkeyboard.keyboard

import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.SoundEffectConstants
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.waitForUpOrCancellation
import androidx.compose.foundation.indication
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.boundsInRoot
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private const val LONG_PRESS_TIMEOUT_MS = 300L
private const val REPEAT_INTERVAL_MS = 50L

@Composable
fun RowScope.KeyButton(
    label: String,
    modifier: Modifier = Modifier,
    theme: KeyboardTheme,
    popupState: KeyPopupState? = null,
    isSpecial: Boolean = false,
    weight: Float = 1f,
    fontSize: Float = 18f,
    fontFamily: FontFamily? = null,
    hapticEnabled: Boolean = true,
    soundEnabled: Boolean = false,
    isRepeatable: Boolean = false,
    hasWallpaper: Boolean = false,
    topRightText: String? = null,
    variants: List<String> = emptyList(),
    onTap: () -> Unit,
    onLongPress: (() -> Unit)? = null,
    onVariantSelected: ((String) -> Unit)? = null
) {
    val context = LocalContext.current
    val view = LocalView.current

    var isPressed by remember { mutableStateOf(false) }
    val currentOnTap = rememberUpdatedState(onTap)
    val currentOnLongPress = rememberUpdatedState(onLongPress)
    val currentVariants = rememberUpdatedState(variants)
    val interactionSource = remember { MutableInteractionSource() }
    val scope = rememberCoroutineScope()

    // Track this key's position in root coordinates
    var keyBoundsInRoot by remember { mutableStateOf(Rect.Zero) }

    val backgroundColor = when {
        hasWallpaper -> when {
            isPressed -> Color.White.copy(alpha = 0.35f)
            isSpecial -> Color.White.copy(alpha = 0.15f)
            else -> Color.White.copy(alpha = 0.25f)
        }
        else -> when {
            isPressed -> theme.keyPressedColor
            isSpecial -> theme.specialKeyColor
            else -> theme.keyColor
        }
    }
    val textColor = if (hasWallpaper) Color.White else theme.textColor

    val ripple = rememberRipple()

    Box(
        modifier = modifier
            .weight(weight)
            .height(48.dp)
            .clip(RoundedCornerShape(theme.keyRadius.dp))
            .background(backgroundColor)
            .indication(interactionSource, ripple)
            .onGloballyPositioned { coordinates ->
                keyBoundsInRoot = coordinates.boundsInRoot()
            }
            .pointerInput(isRepeatable, variants, variants.size) {
                awaitPointerEventScope {
                    while (true) {
                        val down = awaitFirstDown(requireUnconsumed = false)
                        isPressed = true

                        // Dismiss any existing popup from another key
                        popupState?.dismiss()

                        // Drive ripple
                        val press = PressInteraction.Press(down.position)
                        scope.launch { interactionSource.emit(press) }

                        // Show key preview (non-special keys only)
                        if (popupState != null && !isSpecial) {
                            popupState.showPreview(
                                label = label,
                                bounds = keyBoundsInRoot,
                                fontFamily = fontFamily
                            )
                        }

                        // Haptic + sound on touch
                        if (hapticEnabled) vibrate(context)
                        if (soundEnabled) view.playSoundEffect(SoundEffectConstants.CLICK)

                        var handledByLongPress = false
                        var repeatJob: Job? = null

                        // Long press timer
                        val longPressJob = scope.launch {
                            delay(LONG_PRESS_TIMEOUT_MS)
                            if (!isPressed) return@launch
                            handledByLongPress = true

                            when {
                                currentVariants.value.isNotEmpty() && popupState != null -> {
                                    // Expand preview into variant strip
                                    popupState.expandToVariants(currentVariants.value) { variant ->
                                        onVariantSelected?.invoke(variant)
                                    }
                                    if (hapticEnabled) vibrate(context)
                                }
                                isRepeatable -> {
                                    popupState?.hidePreview()
                                    if (hapticEnabled) vibrate(context)
                                    repeatJob = scope.launch {
                                        while (isPressed) {
                                            currentOnTap.value()
                                            delay(REPEAT_INTERVAL_MS)
                                        }
                                    }
                                }
                                else -> {
                                    popupState?.hidePreview()
                                    currentOnLongPress.value?.invoke()
                                    if (hapticEnabled) vibrate(context)
                                }
                            }
                        }

                        // Wait for release
                        val upOrCancel = waitForUpOrCancellation()
                        isPressed = false
                        longPressJob.cancel()
                        repeatJob?.cancel()

                        // Release ripple
                        scope.launch {
                            if (upOrCancel != null) {
                                interactionSource.emit(PressInteraction.Release(press))
                            } else {
                                interactionSource.emit(PressInteraction.Cancel(press))
                            }
                        }

                        // Hide preview on release
                        popupState?.hidePreview()

                        // Short tap
                        if (upOrCancel != null && !handledByLongPress) {
                            if (popupState?.isExpanded != true) {
                                currentOnTap.value()
                            }
                        }
                    }
                }
            },
        contentAlignment = Alignment.Center
    ) {
        // Main label
        Text(
            text = label,
            color = textColor,
            fontSize = fontSize.sp,
            fontFamily = fontFamily,
            textAlign = TextAlign.Center
        )

        // Top-right hint
        if (topRightText != null) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(top = 2.dp, end = 4.dp),
                contentAlignment = Alignment.TopEnd
            ) {
                Text(
                    text = topRightText,
                    color = textColor.copy(alpha = 0.6f),
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = null
                )
            }
        }
    }
}

private fun vibrate(context: android.content.Context) {
    val vibrator = context.getSystemService(
        android.content.Context.VIBRATOR_SERVICE
    ) as? Vibrator ?: return
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        vibrator.vibrate(
            VibrationEffect.createOneShot(20, VibrationEffect.DEFAULT_AMPLITUDE)
        )
    } else {
        @Suppress("DEPRECATION")
        vibrator.vibrate(20)
    }
}