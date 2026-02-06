package com.bhs.mkeyboard.keyboard

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun NumberPadView(
    theme: KeyboardTheme,
    isPhonePad: Boolean = false,
    isDecimal: Boolean = false,
    hapticEnabled: Boolean,
    soundEnabled: Boolean,
    hasWallpaper: Boolean,
    actionButton: ImeActionHelper.ActionButton,
    onInput: (String) -> Unit,
    onBackspace: () -> Unit,
    onAction: () -> Unit,
    modifier: Modifier = Modifier
) {
    val layout = if (isPhonePad) KeyboardLayouts.phonePad else KeyboardLayouts.numberPad

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        layout.forEach { row ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                row.forEach { key ->
                    KeyButton(
                        label = key,
                        theme = theme,
                        weight = 1f,
                        fontSize = 22f,
                        hapticEnabled = hapticEnabled,
                        soundEnabled = soundEnabled,
                        hasWallpaper = hasWallpaper,
                        onTap = { onInput(key) }
                    )
                }
            }
        }

        // Bottom row: decimal/extra | 0 or special | backspace | action
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            if (isDecimal) {
                KeyButton(
                    label = ".",
                    theme = theme,
                    weight = 1f,
                    fontSize = 22f,
                    hapticEnabled = hapticEnabled,
                    soundEnabled = soundEnabled,
                    hasWallpaper = hasWallpaper,
                    onTap = { onInput(".") }
                )
            } else {
                Spacer(modifier = Modifier.weight(1f))
            }

            // Backspace
            KeyButton(
                label = "⌫",
                theme = theme,
                isSpecial = true,
                weight = 1f,
                fontSize = 20f,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                hasWallpaper = hasWallpaper,
                isRepeatable = true,
                onTap = onBackspace
            )

            // Action button
            KeyButton(
                label = actionButton.icon,
                theme = theme,
                isSpecial = true,
                weight = 1f,
                fontSize = 20f,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                hasWallpaper = hasWallpaper,
                onTap = onAction
            )
        }
    }
}