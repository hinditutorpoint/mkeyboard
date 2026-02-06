package com.bhs.mkeyboard.keyboard

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.FontFamily

@Composable
fun ToolbarRow(
    theme: KeyboardTheme,
    onSettingsClick: () -> Unit,
    onThemeClick: () -> Unit,
    onEmojiClick: () -> Unit,
    onVoiceClick: () -> Unit,
    isThemeActive: Boolean = false,
    isEmojiActive: Boolean = false,
    suggestions: List<String> = emptyList(),
    onSuggestionClick: (String) -> Unit = {},
    hasSuggestions: Boolean = false,
    fontFamily: FontFamily? = null,
    modifier: Modifier = Modifier
) {
    var isExpanded by remember { mutableStateOf(false) }

    LaunchedEffect(hasSuggestions) {
        if (!hasSuggestions) isExpanded = false
    }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(44.dp)
            .background(theme.backgroundColor)
            .padding(horizontal = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Leading icon
        if (hasSuggestions) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clickable { isExpanded = !isExpanded },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = if (isExpanded) "⬅️" else "➡️",
                    fontSize = 18.sp
                )
            }
        } else {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clickable { onSettingsClick() },
                contentAlignment = Alignment.Center
            ) {
                Text(text = "⚙️", fontSize = 18.sp)
            }
        }

        // Content area
        if (hasSuggestions && !isExpanded) {
            // Suggestions strip
            androidx.compose.foundation.lazy.LazyRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier
                    .weight(1f)
                    .fillMaxHeight(),
                contentPadding = PaddingValues(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                items(suggestions.size) { index ->
                    Box(
                        modifier = Modifier
                            .background(theme.keyColor, RoundedCornerShape(16.dp))
                            .clickable { onSuggestionClick(suggestions[index]) }
                            .padding(horizontal = 12.dp, vertical = 6.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = suggestions[index],
                            color = theme.textColor,
                            fontSize = 16.sp,
                            fontFamily = fontFamily
                        )
                    }
                }
            }
        } else {
            // Tools group
            Row(
                modifier = Modifier.weight(1f),
                horizontalArrangement = Arrangement.Start,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (hasSuggestions && isExpanded) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clickable { onSettingsClick() },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(text = "⚙️", fontSize = 18.sp)
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                }

                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clickable { onThemeClick() },
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "🎨", fontSize = 18.sp)
                }

                Spacer(modifier = Modifier.width(4.dp))

                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clickable { onEmojiClick() },
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "😀", fontSize = 18.sp)
                }
            }

            // Voice
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clickable { onVoiceClick() },
                contentAlignment = Alignment.Center
            ) {
                Text(text = "🎤", fontSize = 18.sp)
            }
        }
    }
}