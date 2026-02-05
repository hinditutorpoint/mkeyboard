@file:OptIn(androidx.compose.foundation.layout.ExperimentalLayoutApi::class)
package com.bhs.mkeyboard.keyboard

import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.SoundEffectConstants
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.indication
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.PressInteraction
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.ripple.rememberRipple
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties
import androidx.compose.foundation.border
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Key button composable - must be used inside a Row
 */
@Composable
fun RowScope.KeyButton(
    label: String,
    modifier: Modifier = Modifier,
    theme: KeyboardTheme,
    isSpecial: Boolean = false,
    weight: Float = 1f,
    fontSize: Float = 18f,
    fontFamily: FontFamily? = null,
    hapticEnabled: Boolean = true,
    soundEnabled: Boolean = false,
    isRepeatable: Boolean = false,
    variants: List<String> = emptyList(),
    onTap: () -> Unit,
    onLongPress: (() -> Unit)? = null,
    onVariantSelected: ((String) -> Unit)? = null
) {
    val context = LocalContext.current
    val view = LocalView.current
    var isPressed by remember { mutableStateOf(false) }
    var showPopup by remember { mutableStateOf(false) }
    val interactionSource = remember { MutableInteractionSource() }
    val coroutineScope = rememberCoroutineScope()
    
    val backgroundColor = when {
        isPressed || showPopup -> theme.keyPressedColor
        isSpecial -> theme.specialKeyColor
        else -> theme.keyColor
    }
    
    Box(
        modifier = modifier
            .weight(weight)
            .height(48.dp)
            .clip(RoundedCornerShape(theme.keyRadius.dp))
            .background(backgroundColor)
            .indication(interactionSource, rememberRipple())
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = { offset ->
                        isPressed = true
                        val press = PressInteraction.Press(offset)
                        interactionSource.emit(press)
                        
                        if (hapticEnabled) {
                            vibrate(context)
                        }
                        if (soundEnabled) {
                            view.playSoundEffect(SoundEffectConstants.CLICK)
                        }
                        
                        // Handle repeating action
                        var repeatJob: kotlinx.coroutines.Job? = null
                        if (isRepeatable) {
                            repeatJob = coroutineScope.launch {
                                delay(400) // Initial delay
                                while (isPressed) {
                                    onTap()
                                    if (hapticEnabled) vibrate(context)
                                    if (soundEnabled) view.playSoundEffect(SoundEffectConstants.CLICK)
                                    delay(50) // Repeat interval
                                }
                            }
                        }

                        tryAwaitRelease()
                        
                        // Release
                        isPressed = false
                        repeatJob?.cancel()
                        interactionSource.emit(PressInteraction.Release(press))
                        showPopup = false
                    },
                    onTap = { onTap() },
                    onLongPress = { 
                        if (variants.isNotEmpty()) {
                            showPopup = true
                            if (hapticEnabled) vibrate(context)
                        } else {
                            onLongPress?.invoke()
                        }
                    }
                )
            },
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            color = theme.textColor,
            fontSize = fontSize.sp,
            fontFamily = fontFamily,
            textAlign = TextAlign.Center
        )
        
        // Popup for Variants
        if (showPopup && variants.isNotEmpty()) {
            androidx.compose.ui.window.Popup(
                alignment = Alignment.TopCenter,
                onDismissRequest = { showPopup = false },
                properties = PopupProperties(focusable = false)
            ) {
                Box(
                    modifier = Modifier
                        .padding(bottom = 60.dp)
                        .widthIn(max = 280.dp)
                        .background(
                            theme.backgroundColor, 
                            RoundedCornerShape(8.dp)
                        )
                        .border(1.dp, theme.accentColor, RoundedCornerShape(8.dp))
                        .padding(8.dp)
                ) {
                    // Use FlowRow for better performance (limit items to 20)
                    androidx.compose.foundation.layout.FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        variants.take(20).forEach { variant ->
                            Box(
                                modifier = Modifier
                                    .size(36.dp)
                                    .background(theme.keyColor, RoundedCornerShape(4.dp))
                                    .clickable {
                                        onVariantSelected?.invoke(variant)
                                        showPopup = false
                                    },
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = variant, 
                                    color = theme.textColor,
                                    fontSize = 16.sp,
                                    fontFamily = fontFamily
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun vibrate(context: android.content.Context) {
    val vibrator = context.getSystemService(android.content.Context.VIBRATOR_SERVICE) as? Vibrator
    vibrator?.let {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            it.vibrate(VibrationEffect.createOneShot(30, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            it.vibrate(30)
        }
    }
}
