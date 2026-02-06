package com.bhs.mkeyboard.keyboard

import android.view.inputmethod.EditorInfo
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInWindow
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.bhs.mkeyboard.R
import com.bhs.mkeyboard.transliteration.GondiTransliterator
import com.bhs.mkeyboard.transliteration.GondiVariants
import com.bhs.mkeyboard.transliteration.HindiTransliterator
import com.bhs.mkeyboard.transliteration.HindiVariants

@Composable
fun KeyboardView(
    onInput: (String, Boolean) -> Unit,
    onBackspace: () -> Unit,
    onEnter: () -> Unit,
    onSpace: () -> Unit,
    onSettingsClick: () -> Unit,
    onLanguageChanged: (KeyboardLanguage) -> Unit,
    settingsVersion: Int,
    composingText: String = "",
    transliteratedText: String = "",
    onSuggestionSelected: (String) -> Unit = {},
    onVoiceInput: () -> Unit = {},
    onVoiceStop: () -> Unit = {},
    onVoiceClose: () -> Unit = {},
    onVoiceRetry: () -> Unit = {},
    isVoiceActive: Boolean = false,
    voiceState: VoiceInputManager.VoiceState = VoiceInputManager.VoiceState.IDLE,
    voicePartialResult: String = "",
    voiceErrorMessage: String? = null,
    voiceVolumeLevel: Float = 0f,
    onGlideStart: (Float, Float) -> Unit = { _, _ -> },
    onGlideMove: (Float, Float) -> Unit = { _, _ -> },
    onGlideEnd: () -> Unit = {},
    glideTrailPoints: List<GlideTypingDetector.GlidePoint> = emptyList(),
    glideSuggestions: List<String> = emptyList(),
    isGlideActive: Boolean = false,
    onGlideSuggestionSelected: (String) -> Unit = {},
    inputConfig: ImeActionHelper.InputConfig = ImeActionHelper.InputConfig(
        keyboardType = ImeActionHelper.KeyboardType.TEXT,
        actionButton = ImeActionHelper.ActionButton.ENTER,
        imeAction = EditorInfo.IME_ACTION_UNSPECIFIED
    ),
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val settings = remember(settingsVersion) { KeyboardSettings(context) }
    val suggestionEngine = remember { SuggestionEngine(context) }
    val gondiFontFamily = remember { FontFamily(Font(R.font.noto_sans_masaram_gondi)) }

    val hindiTransliterator = remember { HindiTransliterator() }
    val gondiTransliterator = remember { GondiTransliterator() }

    val popupState = remember { KeyPopupState() }

    var currentTheme by remember(settingsVersion) { mutableStateOf(settings.theme) }
    var currentWallpaperUrl by remember(settingsVersion) { mutableStateOf(settings.wallpaperUrl) }
    var currentLanguage by remember(settingsVersion) {
        mutableStateOf(KeyboardLanguage.entries[settings.defaultLanguageIndex.coerceIn(0, 2)])
    }

    val showNumberPad = inputConfig.keyboardType == ImeActionHelper.KeyboardType.NUMBER ||
            inputConfig.keyboardType == ImeActionHelper.KeyboardType.PHONE ||
            inputConfig.keyboardType == ImeActionHelper.KeyboardType.DECIMAL

    LaunchedEffect(currentLanguage) { onLanguageChanged(currentLanguage) }

    val activeSuggestions = if (glideSuggestions.isNotEmpty()) {
        glideSuggestions
    } else {
        remember(composingText, transliteratedText, currentLanguage, settingsVersion) {
            if ((composingText.isNotEmpty() || transliteratedText.isNotEmpty()) && settings.showSuggestions) {
                suggestionEngine.getSuggestions(composingText, currentLanguage.ordinal, transliteratedText)
            } else emptyList()
        }
    }
    val hasSuggestions = activeSuggestions.isNotEmpty()

    var isShift by remember { mutableStateOf(false) }
    var showSymbols by remember { mutableStateOf(false) }
    var symbolPageIndex by remember { mutableStateOf(0) }
    var showThemePicker by remember { mutableStateOf(false) }
    var showEmoji by remember { mutableStateOf(false) }

    val layout = when {
        showSymbols -> if (symbolPageIndex == 0) {
            if (currentLanguage == KeyboardLanguage.GONDI) KeyboardLayouts.gondiSymbols1
            else KeyboardLayouts.symbols1
        } else KeyboardLayouts.symbols2
        else -> when (currentLanguage) {
            KeyboardLanguage.ENGLISH -> KeyboardLayouts.englishLetters
            KeyboardLanguage.HINDI -> KeyboardLayouts.hindiLetters
            KeyboardLanguage.GONDI -> KeyboardLayouts.gondiLetters
        }
    }

    LaunchedEffect(showSymbols, showThemePicker, showEmoji, isVoiceActive) {
        popupState.dismiss()
    }

    // Track keyboard position in window for overlay positioning
    var keyboardTopInWindow by remember { mutableStateOf(0f) }

    Box(modifier = modifier.fillMaxWidth()) {
        if (currentWallpaperUrl != null) {
            AsyncImage(
                model = ImageRequest.Builder(context)
                    .data(currentWallpaperUrl)
                    .crossfade(true)
                    .allowHardware(false)
                    .build(),
                contentDescription = "Keyboard wallpaper",
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxWidth().matchParentSize()
            )
        }

        // Main keyboard column — fixed size, clips its own content
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clipToBounds()  // Prevent content from expanding outside
                .background(
                    if (currentWallpaperUrl != null) currentTheme.backgroundColor.copy(alpha = 0.7f)
                    else currentTheme.backgroundColor
                )
                .padding(bottom = 4.dp)
                .onGloballyPositioned { coordinates ->
                    keyboardTopInWindow = coordinates.positionInWindow().y
                }
        ) {
            if (isVoiceActive) {
                VoiceInputOverlay(
                    theme = currentTheme,
                    voiceState = voiceState,
                    partialResult = voicePartialResult,
                    errorMessage = voiceErrorMessage,
                    volumeLevel = voiceVolumeLevel,
                    hasWallpaper = currentWallpaperUrl != null,
                    onStopClick = onVoiceStop,
                    onRetryClick = onVoiceRetry,
                    onCloseClick = onVoiceClose
                )
            } else if (showNumberPad) {
                NumberPadView(
                    theme = currentTheme,
                    isPhonePad = inputConfig.keyboardType == ImeActionHelper.KeyboardType.PHONE,
                    isDecimal = inputConfig.keyboardType == ImeActionHelper.KeyboardType.DECIMAL,
                    hapticEnabled = settings.hapticFeedback,
                    soundEnabled = settings.soundOnKeyPress,
                    hasWallpaper = currentWallpaperUrl != null,
                    actionButton = inputConfig.actionButton,
                    onInput = { text -> onInput(text, true) },
                    onBackspace = onBackspace,
                    onAction = onEnter
                )
            } else {
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
                    onVoiceClick = onVoiceInput,
                    isThemeActive = showThemePicker,
                    isEmojiActive = showEmoji,
                    suggestions = activeSuggestions,
                    onSuggestionClick = { suggestion ->
                        if (glideSuggestions.isNotEmpty()) {
                            onGlideSuggestionSelected(suggestion)
                        } else {
                            onSuggestionSelected(suggestion)
                        }
                    },
                    hasSuggestions = hasSuggestions,
                    fontFamily = gondiFontFamily
                )

                if (showThemePicker) {
                    ThemeWallpaperPicker(
                        currentTheme = currentTheme,
                        currentWallpaperUrl = currentWallpaperUrl,
                        settings = settings,
                        onThemeSelected = { currentTheme = it },
                        onWallpaperSelected = { url ->
                            currentWallpaperUrl = url
                            settings.setWallpaperUrl(url)
                        },
                        onClose = { showThemePicker = false }
                    )
                }

                if (showEmoji) {
                    EmojiPicker(
                        theme = currentTheme,
                        onEmojiSelected = { emoji -> onInput(emoji, true) }
                    )
                }

                if (!showThemePicker && !showEmoji) {
                    // Number row
                    if (settings.showNumberRow && !showSymbols) {
                        val numberKeys = if (currentLanguage == KeyboardLanguage.GONDI)
                            KeyboardLayouts.gondiNumbers[0] else KeyboardLayouts.numbers[0]
                        KeyRow(
                            keys = numberKeys,
                            theme = currentTheme,
                            popupState = popupState,
                            isShift = false,
                            hapticEnabled = settings.hapticFeedback,
                            soundEnabled = settings.soundOnKeyPress,
                            hasWallpaper = currentWallpaperUrl != null,
                            fontFamily = if (currentLanguage == KeyboardLanguage.GONDI)
                                gondiFontFamily else null,
                            currentLanguage = currentLanguage,
                            showHints = false,
                            showSymbols = false,
                            hindiTransliterator = hindiTransliterator,
                            gondiTransliterator = gondiTransliterator,
                            onKeyTap = { key -> onInput(key, false) }
                        )
                    }

                    Spacer(modifier = Modifier.height(2.dp))

                    layout.forEachIndexed { index, row ->
                        val startKey = if (index == 2) {
                            if (showSymbols) {
                                if (symbolPageIndex == 0) "=\\<" else "?123"
                            } else "⇧"
                        } else null
                        val endKey = if (index == 2) "⌫" else null

                        KeyRow(
                            keys = row,
                            theme = currentTheme,
                            popupState = popupState,
                            isShift = isShift,
                            hapticEnabled = settings.hapticFeedback,
                            soundEnabled = settings.soundOnKeyPress,
                            hasWallpaper = currentWallpaperUrl != null,
                            fontFamily = if (currentLanguage == KeyboardLanguage.GONDI)
                                gondiFontFamily else null,
                            currentLanguage = currentLanguage,
                            showHints = (currentLanguage == KeyboardLanguage.GONDI ||
                                    currentLanguage == KeyboardLanguage.HINDI) && !showSymbols,
                            showSymbols = showSymbols,
                            hindiTransliterator = hindiTransliterator,
                            gondiTransliterator = gondiTransliterator,
                            onKeyTap = { key ->
                                popupState.dismiss()
                                val output = if (isShift) key.uppercase() else key
                                onInput(output, showSymbols)
                                if (isShift) isShift = false
                            },
                            startKey = startKey,
                            endKey = endKey,
                            onStartKeyTap = {
                                popupState.dismiss()
                                if (showSymbols) {
                                    symbolPageIndex = if (symbolPageIndex == 0) 1 else 0
                                } else {
                                    isShift = !isShift
                                }
                            },
                            onEndKeyTap = {
                                popupState.dismiss()
                                onBackspace()
                            },
                            isEndKeyRepeatable = true
                        )
                        Spacer(modifier = Modifier.height(settings.keySpacing.dp))
                    }

                    BottomRow(
                        theme = currentTheme,
                        currentLanguage = currentLanguage,
                        showSymbols = showSymbols,
                        hapticEnabled = settings.hapticFeedback,
                        soundEnabled = settings.soundOnKeyPress,
                        hasWallpaper = currentWallpaperUrl != null,
                        hasSuggestions = hasSuggestions,
                        actionButton = inputConfig.actionButton,
                        onLanguageToggle = {
                            popupState.dismiss()
                            currentLanguage = currentLanguage.next()
                            onLanguageChanged(currentLanguage)
                        },
                        onSymbolToggle = {
                            popupState.dismiss()
                            showSymbols = !showSymbols
                            symbolPageIndex = 0
                        },
                        onSpace = {
                            popupState.dismiss()
                            onSpace()
                        },
                        onEnter = {
                            popupState.dismiss()
                            onEnter()
                        },
                        onEmojiClick = {
                            popupState.dismiss()
                            showEmoji = !showEmoji
                            showThemePicker = false
                        },
                        gondiFontFamily = gondiFontFamily
                    )
                }
            }
        }

        // Glide trail — on top of keyboard but inside bounds
        if (isGlideActive && glideTrailPoints.isNotEmpty()) {
            GlideTrailCanvas(
                trailPoints = glideTrailPoints,
                trailColor = currentTheme.accentColor,
                modifier = Modifier.matchParentSize()
            )
        }

        // KEY POPUP OVERLAY — rendered INSIDE the keyboard Box
        // Uses absolute positioning within the keyboard bounds
        // Does NOT affect keyboard size because it uses matchParentSize
        if (popupState.isActive() && !showThemePicker && !showEmoji && !isVoiceActive) {
            KeyPopupOverlay(
                popupState = popupState,
                theme = currentTheme,
                hasWallpaper = currentWallpaperUrl != null,
                hapticEnabled = settings.hapticFeedback,
                modifier = Modifier.matchParentSize()  // Same size as keyboard, no expansion
            )
        }
    }
}

// ── KeyRow ───────────────────────────────────────────────────────────

@Composable
private fun KeyRow(
    keys: List<String>,
    theme: KeyboardTheme,
    popupState: KeyPopupState,
    isShift: Boolean,
    hapticEnabled: Boolean,
    soundEnabled: Boolean,
    hasWallpaper: Boolean,
    fontFamily: FontFamily?,
    currentLanguage: KeyboardLanguage,
    showHints: Boolean,
    showSymbols: Boolean,
    hindiTransliterator: HindiTransliterator,
    gondiTransliterator: GondiTransliterator,
    onKeyTap: (String) -> Unit,
    startKey: String? = null,
    endKey: String? = null,
    onStartKeyTap: () -> Unit = {},
    onEndKeyTap: () -> Unit = {},
    isEndKeyRepeatable: Boolean = false
) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        if (startKey != null) {
            KeyButton(
                label = startKey,
                theme = theme,
                popupState = popupState,
                isSpecial = true,
                weight = 1.3f,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                hasWallpaper = hasWallpaper,
                fontFamily = fontFamily,
                onTap = onStartKeyTap
            )
        }

        keys.forEach { key ->
            val variants = remember(key, currentLanguage, showSymbols) {
                if (!showSymbols) {
                    when (currentLanguage) {
                        KeyboardLanguage.GONDI -> GondiVariants.getVariants(key)
                        KeyboardLanguage.HINDI -> HindiVariants.getVariants(key)
                        KeyboardLanguage.ENGLISH -> emptyList()
                    }
                } else emptyList()
            }

            val displayLabel: String
            val hintText: String?

            if (showHints) {
                val inputKey = if (isShift) key.uppercase() else key
                val isGondi = currentLanguage == KeyboardLanguage.GONDI
                val transliterator = if (isGondi) gondiTransliterator else hindiTransliterator
                val base = transliterator.transliterate(inputKey)

                displayLabel = if (isGondi) {
                    if (base.endsWith("\uD807\uDD44") || base.endsWith("𑵄")) {
                        transliterator.transliterate(inputKey + "a")
                    } else base
                } else {
                    if (base.endsWith("्")) {
                        transliterator.transliterate(inputKey + "a")
                    } else base
                }

                hintText = if (isShift) key.uppercase() else key.lowercase()
            } else {
                displayLabel = if (isShift) key.uppercase() else key
                hintText = null
            }

            KeyButton(
                label = displayLabel,
                theme = theme,
                popupState = popupState,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                hasWallpaper = hasWallpaper,
                topRightText = hintText,
                fontFamily = fontFamily,
                variants = variants,
                onTap = { onKeyTap(key) },
                onVariantSelected = { variant -> onKeyTap(variant) }
            )
        }

        if (endKey != null) {
            KeyButton(
                label = endKey,
                theme = theme,
                popupState = popupState,
                isSpecial = true,
                weight = 1.3f,
                hapticEnabled = hapticEnabled,
                soundEnabled = soundEnabled,
                hasWallpaper = hasWallpaper,
                isRepeatable = isEndKeyRepeatable,
                onTap = onEndKeyTap
            )
        }
    }
}

// ── BottomRow ────────────────────────────────────────────────────────

@Composable
private fun BottomRow(
    theme: KeyboardTheme,
    currentLanguage: KeyboardLanguage,
    showSymbols: Boolean,
    hapticEnabled: Boolean,
    soundEnabled: Boolean,
    hasWallpaper: Boolean,
    hasSuggestions: Boolean,
    actionButton: ImeActionHelper.ActionButton = ImeActionHelper.ActionButton.ENTER,
    onLanguageToggle: () -> Unit,
    onSymbolToggle: () -> Unit,
    onSpace: () -> Unit,
    onEnter: () -> Unit,
    onEmojiClick: () -> Unit,
    gondiFontFamily: FontFamily
) {
    // Action button appearance
    val actionLabel = actionButton.icon
    val actionColor = when (actionButton) {
        ImeActionHelper.ActionButton.SEARCH -> theme.accentColor
        ImeActionHelper.ActionButton.GO -> theme.accentColor
        ImeActionHelper.ActionButton.SEND -> theme.accentColor
        ImeActionHelper.ActionButton.NEXT -> theme.accentColor
        ImeActionHelper.ActionButton.DONE -> theme.accentColor
        else -> theme.specialKeyColor
    }

    Row(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        KeyButton(
            label = if (showSymbols) "ABC" else "?123",
            theme = theme, isSpecial = true, weight = 1.2f, fontSize = 14f,
            hapticEnabled = hapticEnabled, soundEnabled = soundEnabled,
            hasWallpaper = hasWallpaper, onTap = onSymbolToggle
        )

        KeyButton(
            label = if (currentLanguage == KeyboardLanguage.GONDI) "𑴀𑴁"
                    else currentLanguage.displayName,
            theme = theme, isSpecial = true, weight = 1f,
            hapticEnabled = hapticEnabled, soundEnabled = soundEnabled,
            hasWallpaper = hasWallpaper,
            fontFamily = if (currentLanguage == KeyboardLanguage.GONDI) gondiFontFamily else null,
            onTap = onLanguageToggle
        )

        if (hasSuggestions) {
            KeyButton(
                label = "😀", theme = theme, isSpecial = true, weight = 1f,
                hapticEnabled = hapticEnabled, soundEnabled = soundEnabled,
                hasWallpaper = hasWallpaper, onTap = onEmojiClick
            )
        }

        KeyButton(
            label = if (currentLanguage == KeyboardLanguage.GONDI) "𑴤𑴫𑴦𑴱𑴤 𑴎𑴽𑵀𑴘𑴳"
                    else currentLanguage.name.lowercase().replaceFirstChar { it.uppercase() },
            theme = theme,
            weight = if (hasSuggestions) 3f else 4f,
            hapticEnabled = hapticEnabled, soundEnabled = soundEnabled,
            hasWallpaper = hasWallpaper,
            fontFamily = if (currentLanguage == KeyboardLanguage.GONDI) gondiFontFamily else null,
            onTap = onSpace
        )

        // Action button — changes based on input field type
        KeyButton(
            label = actionLabel,
            theme = theme.copy(
                specialKeyColor = if (actionButton != ImeActionHelper.ActionButton.ENTER)
                    theme.accentColor else theme.specialKeyColor
            ),
            isSpecial = true,
            weight = 1.5f,
            hapticEnabled = hapticEnabled,
            soundEnabled = soundEnabled,
            hasWallpaper = hasWallpaper,
            onTap = onEnter
        )
    }
}

// ═══════════════════════════════════════════════════════════════════════
// Theme/Wallpaper Picker
// ═══════════════════════════════════════════════════════════════════════

@Composable
private fun ThemeWallpaperPicker(
    currentTheme: KeyboardTheme,
    currentWallpaperUrl: String?,
    settings: KeyboardSettings,
    onThemeSelected: (KeyboardTheme) -> Unit,
    onWallpaperSelected: (String?) -> Unit,
    onClose: () -> Unit
) {
    val context = LocalContext.current

    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Colors", "Wallpapers")

    var wallpapers by remember { mutableStateOf<List<PixabayImage>>(emptyList()) }
    var isLoading by remember { mutableStateOf(false) }
    var selectedCategory by remember { mutableStateOf(PixabayService.categories.first()) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(selectedCategory) {
        isLoading = true
        errorMessage = null
        val result = PixabayService.searchWallpapers(selectedCategory.query)
        result.fold(
            onSuccess = { wallpapers = it },
            onFailure = { errorMessage = "Failed to load" }
        )
        isLoading = false
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                color = currentTheme.backgroundColor,
                shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)
            )
    ) {
        // Header with tabs
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            tabs.forEachIndexed { index, title ->
                val isSelected = selectedTab == index
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(20.dp))
                        .background(
                            if (isSelected) currentTheme.accentColor.copy(alpha = 0.15f)
                            else Color.Transparent
                        )
                        .clickable { selectedTab = index }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = title,
                        color = if (isSelected) currentTheme.accentColor
                                else currentTheme.textColor.copy(alpha = 0.6f),
                        fontSize = 14.sp,
                        fontWeight = if (isSelected) FontWeight.SemiBold else null
                    )
                }
                if (index < tabs.lastIndex) {
                    Spacer(modifier = Modifier.width(4.dp))
                }
            }

            Spacer(modifier = Modifier.weight(1f))

            // Close button
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(currentTheme.keyColor)
                    .clickable { onClose() },
                contentAlignment = Alignment.Center
            ) {
                Text("×", color = currentTheme.textColor, fontSize = 20.sp)
            }
        }

        // Content
        when (selectedTab) {
            0 -> GboardThemesGrid(
                currentTheme = currentTheme,
                currentWallpaperUrl = currentWallpaperUrl,
                context = context,
                onThemeSelected = onThemeSelected,
                onWallpaperSelected = onWallpaperSelected
            )
            1 -> GboardWallpapersGrid(
                currentTheme = currentTheme,
                currentWallpaperUrl = currentWallpaperUrl,
                categories = PixabayService.categories,
                selectedCategory = selectedCategory,
                wallpapers = wallpapers,
                isLoading = isLoading,
                errorMessage = errorMessage,
                onCategorySelected = { selectedCategory = it },
                onWallpaperSelected = onWallpaperSelected
            )
        }
    }
}

@Composable
private fun GboardThemesGrid(
    currentTheme: KeyboardTheme,
    currentWallpaperUrl: String?,
    context: android.content.Context,
    onThemeSelected: (KeyboardTheme) -> Unit,
    onWallpaperSelected: (String?) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(180.dp)
            .padding(horizontal = 12.dp)
    ) {
        if (currentWallpaperUrl != null) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 8.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(currentTheme.keyColor.copy(alpha = 0.5f))
                    .clickable { onWallpaperSelected(null) }
                    .padding(horizontal = 12.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Text("✕", color = currentTheme.textColor, fontSize = 14.sp)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Clear wallpaper", color = currentTheme.textColor, fontSize = 13.sp)
            }
        }

        androidx.compose.foundation.lazy.LazyRow(
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            contentPadding = PaddingValues(vertical = 4.dp)
        ) {
            items(KeyboardTheme.allThemes.size) { index ->
                val theme = KeyboardTheme.allThemes[index]
                val isSelected = theme.name == currentTheme.name && currentWallpaperUrl == null

                GboardThemeCard(
                    theme = theme,
                    isSelected = isSelected,
                    currentAccentColor = currentTheme.accentColor,
                    textColor = currentTheme.textColor,
                    onClick = {
                        val prefs = context.getSharedPreferences(
                            "FlutterSharedPreferences",
                            android.content.Context.MODE_PRIVATE
                        )
                        prefs.edit().putString("flutter.themeName", theme.name).apply()
                        onThemeSelected(theme)
                        onWallpaperSelected(null)
                    }
                )
            }
        }
    }
}

@Composable
private fun GboardThemeCard(
    theme: KeyboardTheme,
    isSelected: Boolean,
    currentAccentColor: Color,
    textColor: Color,
    onClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .width(85.dp)
            .clip(RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(4.dp)
    ) {
        Box(
            modifier = Modifier
                .size(75.dp, 55.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(theme.backgroundColor)
                .then(
                    if (isSelected) Modifier.border(
                        width = 3.dp,
                        color = currentAccentColor,
                        shape = RoundedCornerShape(12.dp)
                    ) else Modifier
                )
                .padding(6.dp)
        ) {
            Column(
                verticalArrangement = Arrangement.spacedBy(3.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(2.dp),
                    modifier = Modifier.weight(1f).fillMaxWidth()
                ) {
                    repeat(5) {
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .fillMaxHeight()
                                .background(theme.keyColor, RoundedCornerShape(3.dp))
                        )
                    }
                }
                Row(
                    horizontalArrangement = Arrangement.spacedBy(2.dp),
                    modifier = Modifier.weight(1f).fillMaxWidth()
                ) {
                    Box(
                        modifier = Modifier
                            .weight(1.2f)
                            .fillMaxHeight()
                            .background(theme.specialKeyColor, RoundedCornerShape(3.dp))
                    )
                    repeat(3) {
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .fillMaxHeight()
                                .background(theme.keyColor, RoundedCornerShape(3.dp))
                        )
                    }
                    Box(
                        modifier = Modifier
                            .weight(1.2f)
                            .fillMaxHeight()
                            .background(theme.specialKeyColor, RoundedCornerShape(3.dp))
                    )
                }
                Row(
                    horizontalArrangement = Arrangement.spacedBy(2.dp),
                    modifier = Modifier.weight(1f).fillMaxWidth()
                ) {
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .background(theme.specialKeyColor, RoundedCornerShape(3.dp))
                    )
                    Box(
                        modifier = Modifier
                            .weight(3f)
                            .fillMaxHeight()
                            .background(theme.keyColor, RoundedCornerShape(3.dp))
                    )
                    Box(
                        modifier = Modifier
                            .weight(1.5f)
                            .fillMaxHeight()
                            .background(theme.accentColor, RoundedCornerShape(3.dp))
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(6.dp))

        Text(
            text = theme.name,
            color = if (isSelected) currentAccentColor else textColor.copy(alpha = 0.8f),
            fontSize = 11.sp,
            fontWeight = if (isSelected) FontWeight.Medium else null,
            maxLines = 1
        )

        if (isSelected) {
            Spacer(modifier = Modifier.height(2.dp))
            Box(
                modifier = Modifier
                    .size(6.dp)
                    .background(currentAccentColor, CircleShape)
            )
        }
    }
}

@Composable
private fun GboardWallpapersGrid(
    currentTheme: KeyboardTheme,
    currentWallpaperUrl: String?,
    categories: List<WallpaperCategory>,
    selectedCategory: WallpaperCategory,
    wallpapers: List<PixabayImage>,
    isLoading: Boolean,
    errorMessage: String?,
    onCategorySelected: (WallpaperCategory) -> Unit,
    onWallpaperSelected: (String?) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp)
            .padding(horizontal = 8.dp)
    ) {
        // Category chips
        androidx.compose.foundation.lazy.LazyRow(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            contentPadding = PaddingValues(horizontal = 4.dp, vertical = 4.dp)
        ) {
            items(categories.size) { index ->
                val category = categories[index]
                val isSelected = category.name == selectedCategory.name

                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(16.dp))
                        .background(
                            if (isSelected) currentTheme.accentColor
                            else currentTheme.keyColor
                        )
                        .clickable { onCategorySelected(category) }
                        .padding(horizontal = 14.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = category.name,
                        color = if (isSelected) Color.White
                                else currentTheme.textColor.copy(alpha = 0.8f),
                        fontSize = 12.sp,
                        fontWeight = if (isSelected) FontWeight.Medium else null
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(4.dp))

        when {
            isLoading -> {
                Box(
                    modifier = Modifier.fillMaxWidth().weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(
                        color = currentTheme.accentColor,
                        strokeWidth = 2.dp,
                        modifier = Modifier.size(28.dp)
                    )
                }
            }
            errorMessage != null -> {
                Box(
                    modifier = Modifier.fillMaxWidth().weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("⚠️", fontSize = 24.sp)
                        Text(
                            errorMessage,
                            color = currentTheme.textColor.copy(alpha = 0.5f),
                            fontSize = 12.sp
                        )
                    }
                }
            }
            else -> {
                androidx.compose.foundation.lazy.grid.LazyVerticalGrid(
                    columns = androidx.compose.foundation.lazy.grid.GridCells.Fixed(3),
                    modifier = Modifier.weight(1f),
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalArrangement = Arrangement.spacedBy(6.dp),
                    contentPadding = PaddingValues(4.dp)
                ) {
                    items(wallpapers.size) { index ->
                        val wallpaper = wallpapers[index]
                        val isSelected = wallpaper.webformatURL == currentWallpaperUrl

                        GboardWallpaperCard(
                            wallpaper = wallpaper,
                            isSelected = isSelected,
                            accentColor = currentTheme.accentColor,
                            onClick = { onWallpaperSelected(wallpaper.webformatURL) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun GboardWallpaperCard(
    wallpaper: PixabayImage,
    isSelected: Boolean,
    accentColor: Color,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1.33f)
            .clip(RoundedCornerShape(8.dp))
            .then(
                if (isSelected) Modifier.border(
                    width = 2.dp,
                    color = accentColor,
                    shape = RoundedCornerShape(8.dp)
                ) else Modifier
            )
            .clickable(onClick = onClick)
    ) {
        val context = LocalContext.current
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data(wallpaper.previewURL)
                .allowHardware(false)
                .build(),
            contentDescription = wallpaper.tags,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        if (isSelected) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = 0.35f)),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .background(accentColor, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        "✓",
                        color = Color.White,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
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
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                color = theme.backgroundColor,
                shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)
            )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Emoji",
                color = theme.textColor,
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium
            )

            Spacer(modifier = Modifier.weight(1f))

            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(theme.accentColor.copy(alpha = 0.15f))
                    .padding(horizontal = 10.dp, vertical = 4.dp)
            ) {
                Text(
                    text = "Recent",
                    color = theme.accentColor,
                    fontSize = 11.sp
                )
            }
        }

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
                .height(240.dp)
        )
    }
}