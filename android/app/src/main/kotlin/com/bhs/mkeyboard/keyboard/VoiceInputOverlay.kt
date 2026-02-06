package com.bhs.mkeyboard.keyboard

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun VoiceInputOverlay(
    theme: KeyboardTheme,
    voiceState: VoiceInputManager.VoiceState,
    partialResult: String,
    errorMessage: String?,
    volumeLevel: Float,
    hasWallpaper: Boolean,
    onStopClick: () -> Unit,
    onRetryClick: () -> Unit,
    onCloseClick: () -> Unit
) {
    val bgColor = if (hasWallpaper) {
        Color.Black.copy(alpha = 0.85f)
    } else {
        theme.backgroundColor
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(bgColor)
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = when (voiceState) {
                    VoiceInputManager.VoiceState.LISTENING -> "Listening..."
                    VoiceInputManager.VoiceState.PROCESSING -> "Processing..."
                    VoiceInputManager.VoiceState.ERROR -> "Error"
                    VoiceInputManager.VoiceState.NO_PERMISSION -> "No Permission"
                    else -> "Voice Input"
                },
                color = theme.textColor,
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )

            // Close button
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(theme.keyColor)
                    .clickable { onCloseClick() },
                contentAlignment = Alignment.Center
            ) {
                Text("×", color = theme.textColor, fontSize = 18.sp)
            }
        }

        // Microphone animation
        when (voiceState) {
            VoiceInputManager.VoiceState.LISTENING -> {
                MicrophoneAnimation(
                    theme = theme,
                    volumeLevel = volumeLevel,
                    onClick = onStopClick
                )
            }
            VoiceInputManager.VoiceState.PROCESSING -> {
                ProcessingAnimation(theme = theme)
            }
            VoiceInputManager.VoiceState.ERROR,
            VoiceInputManager.VoiceState.NO_PERMISSION -> {
                ErrorDisplay(
                    theme = theme,
                    message = errorMessage ?: "Something went wrong",
                    onRetry = onRetryClick
                )
            }
            else -> {}
        }

        // Partial result display
        if (partialResult.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        theme.keyColor.copy(alpha = 0.5f),
                        RoundedCornerShape(12.dp)
                    )
                    .padding(12.dp)
            ) {
                Text(
                    text = partialResult,
                    color = theme.textColor,
                    fontSize = 18.sp,
                    textAlign = TextAlign.Start,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

@Composable
private fun MicrophoneAnimation(
    theme: KeyboardTheme,
    volumeLevel: Float,
    onClick: () -> Unit
) {
    // Pulsating circle based on volume
    val pulseScale by animateFloatAsState(
        targetValue = 1f + (volumeLevel * 0.4f),
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "pulse"
    )

    // Continuous subtle breathing animation
    val infiniteTransition = rememberInfiniteTransition(label = "breathe")
    val breatheScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.08f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse
        ),
        label = "breathe"
    )

    Box(
        modifier = Modifier
            .size(80.dp)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        // Outer pulse ring
        Box(
            modifier = Modifier
                .size(80.dp)
                .scale(pulseScale * breatheScale)
                .clip(CircleShape)
                .background(theme.accentColor.copy(alpha = 0.2f))
        )

        // Middle ring
        Box(
            modifier = Modifier
                .size(60.dp)
                .scale(breatheScale)
                .clip(CircleShape)
                .background(theme.accentColor.copy(alpha = 0.4f))
        )

        // Inner mic button
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(theme.accentColor),
            contentAlignment = Alignment.Center
        ) {
            Text("🎤", fontSize = 24.sp)
        }
    }

    Spacer(modifier = Modifier.height(4.dp))

    Text(
        text = "Tap to stop",
        color = theme.textColor.copy(alpha = 0.6f),
        fontSize = 12.sp
    )
}

@Composable
private fun ProcessingAnimation(theme: KeyboardTheme) {
    val infiniteTransition = rememberInfiniteTransition(label = "processing")

    Row(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 16.dp)
    ) {
        repeat(3) { index ->
            val delay = index * 200
            val scale by infiniteTransition.animateFloat(
                initialValue = 0.5f,
                targetValue = 1f,
                animationSpec = infiniteRepeatable(
                    animation = tween(600, delayMillis = delay),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "dot$index"
            )

            Box(
                modifier = Modifier
                    .size(12.dp)
                    .scale(scale)
                    .clip(CircleShape)
                    .background(theme.accentColor)
            )
        }
    }

    Text(
        text = "Processing...",
        color = theme.textColor.copy(alpha = 0.6f),
        fontSize = 12.sp
    )
}

@Composable
private fun ErrorDisplay(
    theme: KeyboardTheme,
    message: String,
    onRetry: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.padding(vertical = 8.dp)
    ) {
        Text("⚠️", fontSize = 32.sp)

        Text(
            text = message,
            color = theme.textColor.copy(alpha = 0.7f),
            fontSize = 14.sp,
            textAlign = TextAlign.Center
        )

        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(20.dp))
                .background(theme.accentColor)
                .clickable { onRetry() }
                .padding(horizontal = 24.dp, vertical = 8.dp)
        ) {
            Text(
                text = "Try Again",
                color = Color.White,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

private val EaseInOutCubic = CubicBezierEasing(0.65f, 0f, 0.35f, 1f)