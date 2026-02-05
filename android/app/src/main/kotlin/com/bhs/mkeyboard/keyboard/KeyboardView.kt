package com.bhs.mkeyboard.keyboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import com.bhs.mkeyboard.R

/**
 * Main keyboard view composable
 */
@Composable
fun KeyboardView(
    onInput: (String, Boolean) -> Unit, // text, isRaw
    onBackspace: () -> Unit,
    onEnter: () -> Unit,
    onSpace: () -> Unit,
    onSettingsClick: () -> Unit,
    onLanguageChanged: (KeyboardLanguage) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val settings = remember { KeyboardSettings(context) }
    // Load custom font
    val gondiFontFamily = remember { FontFamily(Font(R.font.noto_sans_masaram_gondi)) }
    var currentTheme by remember { mutableStateOf(settings.theme) }
    
    var currentLanguage by remember { mutableStateOf(KeyboardLanguage.entries[settings.defaultLanguageIndex.coerceIn(0, 2)]) }
    
    // Notify service of initial language
    LaunchedEffect(currentLanguage) {
        onLanguageChanged(currentLanguage)
    }
    
    var isShift by remember { mutableStateOf(false) }
    var showSymbols by remember { mutableStateOf(false) }
    var symbolPageIndex by remember { mutableStateOf(0) }
    var showThemePicker by remember { mutableStateOf(false) }
    var showEmoji by remember { mutableStateOf(false) }
    
    val layout = when {
        showSymbols -> if (symbolPageIndex == 0) KeyboardLayouts.symbols1 else KeyboardLayouts.symbols2
        else -> when (currentLanguage) {
            KeyboardLanguage.ENGLISH -> KeyboardLayouts.englishLetters
            KeyboardLanguage.HINDI -> KeyboardLayouts.hindiLetters
            KeyboardLanguage.GONDI -> KeyboardLayouts.gondiLetters
        }
    }
    
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(currentTheme.backgroundColor)
            .padding(bottom = 4.dp)
    ) {
        // Toolbar
        ToolbarRow(
            theme = currentTheme,
            onSettingsClick = onSettingsClick,
            onThemeClick = { 
                showThemePicker = !showThemePicker
                showEmoji = false
            },
            onEmojiClick = { 
                showEmoji = !showEmoji
                showThemePicker = false
            },
            onVoiceClick = { /* TODO: Voice input */ },
            isThemeActive = showThemePicker,
            isEmojiActive = showEmoji,
            suggestions = emptyList(), // Placeholder for suggestions
            onSuggestionClick = { suggestion -> onInput(suggestion, false) }
        )
        
        // Theme picker (if active)
        if (showThemePicker) {
            ThemePicker(
                currentTheme = currentTheme,
                onThemeSelected = { selectedTheme ->
                    currentTheme = selectedTheme
                    showThemePicker = false
                }
            )
        }
        
        // Emoji picker (if active)
        if (showEmoji) {
            EmojiPicker(
                theme = currentTheme,
                onEmojiSelected = { emoji -> onInput(emoji, true) }
            )
        }
        
            // Main keyboard (hidden when pickers are active)
        if (!showThemePicker && !showEmoji) {
            // Number row
            if (settings.showNumberRow && !showSymbols) {
                KeyRow(
                    keys = KeyboardLayouts.numbers[0],
                    theme = currentTheme,
                    isShift = false,
                    hapticEnabled = settings.hapticFeedback,
                    soundEnabled = settings.soundOnKeyPress,
                    onKeyTap = { key -> onInput(key, false) }
                )
            }
            
            Spacer(modifier = Modifier.height(2.dp))
            
            // Letter rows
            layout.forEachIndexed { index, row ->
                // Determine Left Key (Shift or Page Switcher)
                val startKey = if (index == 2) {
                    if (showSymbols) {
                        if (symbolPageIndex == 0) "=\\<" else "?123"
                    } else {
                        "⇧"
                    }
                } else null
                
                // Determine Right Key (Backspace)
                val endKey = if (index == 2) "⌫" else null

                KeyRow(
                    keys = row,
                    theme = currentTheme,
                    isShift = isShift,
                    hapticEnabled = settings.hapticFeedback,
                    soundEnabled = settings.soundOnKeyPress,
                    fontFamily = if (currentLanguage.name == "GONDI") gondiFontFamily else null,
                    onKeyTap = { key -> 
                        val output = if (isShift) key.uppercase() else key
                        // If showing symbols, treat as raw input (bypass transliteration)
                        onInput(output, showSymbols)
                        if (isShift) isShift = false
                    },
                    startKey = startKey,
                    endKey = endKey,
                    onStartKeyTap = { 
                        if (showSymbols) {
                            symbolPageIndex = if (symbolPageIndex == 0) 1 else 0
                        } else {
                            isShift = !isShift
                        }
                    },
                    onEndKeyTap = onBackspace,
                    isEndKeyRepeatable = true,
                    onVariantRequest = { key ->
                        if (currentLanguage.name == "GONDI" && !showSymbols) {
                            com.bhs.mkeyboard.transliteration.GondiVariants.getVariants(key)
                        } else {
                            emptyList()
                        }
                    },
                    onVariantSelected = { variant -> onInput(variant, false) }
                )
                Spacer(modifier = Modifier.height(settings.keySpacing.dp))
            }
            
            // Bottom row
            BottomRow(
                theme = currentTheme,
                currentLanguage = currentLanguage,
                showSymbols = showSymbols,
                hapticEnabled = settings.hapticFeedback,
                soundEnabled = settings.soundOnKeyPress,
                onLanguageToggle = { 
                    currentLanguage = currentLanguage.next()
                    onLanguageChanged(currentLanguage)
                },
                onSymbolToggle = { 
                    showSymbols = !showSymbols
                    symbolPageIndex = 0
                },
                onSpace = onSpace,
                onEnter = onEnter
            )
        }
    }
}


@Composable
private fun KeyRow(
    keys: List<String>,
    theme: KeyboardTheme,
    isShift: Boolean,
    hapticEnabled: Boolean,
    soundEnabled: Boolean,
    fontFamily: FontFamily? = null,
    onKeyTap: (String) -> Unit,
    startKey: String? = null,
    endKey: String? = null,
    onStartKeyTap: () -> Unit = {},
    onEndKeyTap: () -> Unit = {},
    isEndKeyRepeatable: Boolean = false,
    onVariantRequest: ((String) -> List<String>)? = null,
    onVariantSelected: ((String) -> Unit)? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        if (startKey != null) {
            KeyButton(
                label = startKey,
                theme = theme,
                isSpecial = true,
                weight = 1.3f,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                fontFamily = fontFamily,
                onTap = onStartKeyTap
            )
        }
        
        keys.forEach { key ->
            // Generate variants if handler provided
            val variants = onVariantRequest?.invoke(key) ?: emptyList()
            
            KeyButton(
                label = if (isShift) key.uppercase() else key,
                theme = theme,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                fontFamily = fontFamily,
                variants = variants,
                onTap = { onKeyTap(key) },
                onVariantSelected = onVariantSelected
            )
        }
        
        if (endKey != null) {
            KeyButton(
                label = endKey,
                theme = theme,
                isSpecial = true,
                weight = 1.3f,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                isRepeatable = isEndKeyRepeatable,
                onTap = onEndKeyTap
            )
        }
    }
}

@Composable
private fun BottomRow(
    theme: KeyboardTheme,
    currentLanguage: KeyboardLanguage,
    showSymbols: Boolean,
    hapticEnabled: Boolean,
    soundEnabled: Boolean,
    onLanguageToggle: () -> Unit,
    onSymbolToggle: () -> Unit,
    onSpace: () -> Unit,
    onEnter: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        KeyButton(
            label = if (showSymbols) "ABC" else "?123",
            theme = theme,
            isSpecial = true,
            weight = 1.2f,
            fontSize = 14f,
            hapticEnabled = hapticEnabled,
            soundEnabled = soundEnabled,
            onTap = onSymbolToggle
        )
        
        KeyButton(
            label = currentLanguage.displayName,
            theme = theme,
            isSpecial = true,
            weight = 1f,
            hapticEnabled = hapticEnabled,
            soundEnabled = soundEnabled,
            onTap = onLanguageToggle
        )
        
        KeyButton(
            // Show full name title cased (e.g. "English", "Hindi", "Gondi")
            label = currentLanguage.name.lowercase().replaceFirstChar { it.uppercase() },
            theme = theme,
            weight = 4f,
            hapticEnabled = hapticEnabled,
            soundEnabled = soundEnabled,
            onTap = onSpace
        )
        
        KeyButton(
            label = "↵",
            theme = theme,
            isSpecial = true,
            weight = 1.5f,
            hapticEnabled = hapticEnabled,
            soundEnabled = soundEnabled,
            onTap = onEnter
        )
    }
}

@Composable
private fun ThemePicker(
    currentTheme: KeyboardTheme,
    onThemeSelected: (KeyboardTheme) -> Unit
) {
    val context = LocalContext.current
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(140.dp)
            .background(currentTheme.backgroundColor)
            .padding(8.dp)
    ) {
        Text(
            text = "Select Theme",
            color = currentTheme.textColor,
            fontSize = 14.sp,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        
        // Horizontal scrollable theme cards
        androidx.compose.foundation.lazy.LazyRow(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 4.dp)
        ) {
            items(KeyboardTheme.allThemes.size) { index ->
                val theme = KeyboardTheme.allThemes[index]
                val isSelected = theme.name == currentTheme.name
                
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier
                        .width(80.dp)
                        .clickable {
                            // Save to SharedPreferences
                            val prefs = context.getSharedPreferences(
                                "FlutterSharedPreferences",
                                android.content.Context.MODE_PRIVATE
                            )
                            prefs.edit().putString("flutter.themeName", theme.name).apply()
                            onThemeSelected(theme)
                        }
                ) {
                    // Mini keyboard preview
                    Box(
                        modifier = Modifier
                            .size(70.dp, 50.dp)
                            .background(
                                color = theme.backgroundColor,
                                shape = RoundedCornerShape(8.dp)
                            )
                            .then(
                                if (isSelected) Modifier.border(
                                    2.dp,
                                    theme.accentColor,
                                    RoundedCornerShape(8.dp)
                                ) else Modifier
                            )
                            .padding(4.dp)
                    ) {
                        Column(
                            verticalArrangement = Arrangement.spacedBy(2.dp),
                            modifier = Modifier.fillMaxSize()
                        ) {
                            // Row 1
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(2.dp),
                                modifier = Modifier.weight(1f)
                            ) {
                                repeat(4) {
                                    Box(
                                        modifier = Modifier
                                            .weight(1f)
                                            .fillMaxHeight()
                                            .background(theme.keyColor, RoundedCornerShape(2.dp))
                                    )
                                }
                            }
                            // Row 2
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(2.dp),
                                modifier = Modifier.weight(1f)
                            ) {
                                repeat(4) {
                                    Box(
                                        modifier = Modifier
                                            .weight(1f)
                                            .fillMaxHeight()
                                            .background(
                                                if (it == 0) theme.specialKeyColor else theme.keyColor,
                                                RoundedCornerShape(2.dp)
                                            )
                                    )
                                }
                            }
                        }
                    }

                    
                    // Selection indicator
                    if (isSelected) {
                        Box(
                            modifier = Modifier
                                .size(24.dp)
                                .align(Alignment.CenterHorizontally)
                                .offset(y = (-12).dp) // Overlap slightly
                                .background(currentTheme.accentColor, androidx.compose.foundation.shape.CircleShape)
                                .border(1.dp, currentTheme.backgroundColor, androidx.compose.foundation.shape.CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = "✓", color = currentTheme.backgroundColor, fontSize = 14.sp)
                        }
                    } else {
                        Spacer(modifier = Modifier.height(12.dp))
                    }
                    
                    Text(
                        text = theme.name,
                        color = if (isSelected) currentTheme.accentColor else currentTheme.textColor,
                        fontSize = 11.sp,
                        fontWeight = if (isSelected) androidx.compose.ui.text.font.FontWeight.Bold else null
                    )
                }
            }
        }
    }
}

@Composable
private fun EmojiPicker(
    theme: KeyboardTheme,
    onEmojiSelected: (String) -> Unit
) {
    androidx.compose.ui.viewinterop.AndroidView(
        factory = { context ->
            androidx.emoji2.emojipicker.EmojiPickerView(context).apply {
                layoutParams = android.view.ViewGroup.LayoutParams(
                    android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                    android.view.ViewGroup.LayoutParams.MATCH_PARENT
                )
                setOnEmojiPickedListener { item ->
                    onEmojiSelected(item.emoji)
                }
            }
        },
        modifier = Modifier
            .fillMaxWidth()
            .height(260.dp) // Taller for better usability similar to Gboard
            .background(theme.backgroundColor)
    )
}
