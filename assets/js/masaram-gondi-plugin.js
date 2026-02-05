/**
 * Masaram Gondi Direct Typing Plugin
 * v5.7.0 - Plugin Class & UI Components
 * 
 * Main Plugin (Requires Core Masaram Gondi)
 * 
 * @author Rajesh Kumar Dhuriya
 * @license MIT
 */

(function ($) {
    'use strict';

    // ═══════════════════════════════════════════════════════════════════════════
    // CHECK CORE DEPENDENCY
    // ═══════════════════════════════════════════════════════════════════════════

    if (!$.masaramGondiCore) {
        console.error('MasaramGondi: Core module not found. Please include masaram-gondi-core.js first.');
        return;
    }

    // Import from core
    const Core = $.masaramGondiCore;
    const MARKS = Core.MARKS;
    const KEYBOARD_LAYOUTS = Core.keyboards;
    const DEFAULT_SUGGESTIONS = Core.suggestions;
    const DEFAULTS = Core.defaults;
    const transliterate = Core.transliterate;
    const gondiToIPA = Core.gondiToIPA;
    const Storage = Core.helpers.Storage;
    const debounce = Core.helpers.debounce;

    // ═══════════════════════════════════════════════════════════════════════════
    // CSS INJECTION
    // ═══════════════════════════════════════════════════════════════════════════

    function injectStyles() {
        if ($('#mgd-styles').length) return;

        // Check if external CSS is loaded
        const hasExternalCSS = $('link[href*="masaram"]').length > 0 ||
            $('style:contains(".mgd-keyboard")').length > 0;

        if (hasExternalCSS) return;

        // Inject minimal fallback styles
        const minimalCSS = `
            .mgd-wrapper { position: relative; display: block; width: 100%; }
            .mgd-keyboard { display: none; background: #e8e8e8; border-radius: 8px; padding: 10px; margin-top: 8px; font-family: 'Noto Sans Masaram Gondi', sans-serif; }
            .mgd-keyboard.mgd-keyboard-visible { display: block; }
            .mgd-keyboard-row { display: flex; justify-content: center; gap: 4px; margin-bottom: 4px; }
            .mgd-key { min-width: 36px; height: 44px; border: none; border-radius: 6px; background: #fff; cursor: pointer; display: flex; flex-direction: column; align-items: center; justify-content: center; box-shadow: 0 2px 0 #aaa; }
            .mgd-key:active { transform: translateY(2px); box-shadow: none; }
            .mgd-key-main { font-size: 18px; }
            .mgd-key-sub { font-size: 9px; color: #888; }
            .mgd-key-space { flex: 1; min-width: 100px; }
            .mgd-key-backspace, .mgd-key-clear { background: #ffcccc; }
            .mgd-popup { position: absolute; z-index: 10000; background: #fff; border: 1px solid #ccc; border-radius: 8px; padding: 6px 0; min-width: 180px; display: none; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
            .mgd-popup.mgd-popup-visible { display: block; }
            .mgd-popup-item { display: flex; align-items: center; padding: 10px 14px; cursor: pointer; gap: 10px; }
            .mgd-popup-item:hover { background: #f5f5f5; }
            .mgd-popup-divider { height: 1px; background: #eee; margin: 4px 0; }
            .mgd-popup-toggle { width: 36px; height: 20px; background: #ccc; border-radius: 10px; position: relative; }
            .mgd-popup-toggle.mgd-active { background: #4CAF50; }
            .mgd-popup-toggle::after { content: ''; position: absolute; width: 16px; height: 16px; background: #fff; border-radius: 50%; top: 2px; left: 2px; transition: transform 0.2s; }
            .mgd-popup-toggle.mgd-active::after { transform: translateX(16px); }
            .mgd-mode-badge { padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; }
            .mgd-mode-badge.mgd-mode-en { background: #e3f2fd; color: #1976d2; }
            .mgd-mode-badge.mgd-mode-hi { background: #fff3e0; color: #e65100; }
            .mgd-suggestions { position: absolute; z-index: 9999; background: #fff; border: 1px solid #ddd; border-radius: 8px; max-height: 200px; overflow-y: auto; display: none; width: 100%; max-width: 350px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
            .mgd-suggestions.mgd-suggestions-visible { display: block; }
            .mgd-suggestion-item { display: flex; align-items: center; padding: 10px 14px; cursor: pointer; gap: 12px; border-bottom: 1px solid #f5f5f5; font-family: 'Noto Sans Masaram Gondi', sans-serif; }
            .mgd-suggestion-item:hover, .mgd-suggestion-item.mgd-selected { background: #f5f8ff; }
            .mgd-suggestion-gondi { font-size: 20px; min-width: 60px; }
            .mgd-suggestion-roman { font-size: 14px; color: #666; flex: 1; }
            .mgd-suggestion-hindi { font-size: 13px; color: #999; }
            .mgd-translate-panel { position: absolute; z-index: 9999; background: #fff; border: 1px solid #ddd; border-radius: 8px; width: 100%; max-width: 400px; display: none; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
            .mgd-translate-panel.mgd-translate-visible { display: block; }
            .mgd-translate-header { display: flex; justify-content: space-between; padding: 10px 14px; background: #f8f8f8; border-bottom: 1px solid #eee; }
            .mgd-translate-content { padding: 14px; }
            .mgd-translate-row { display: flex; gap: 10px; margin-bottom: 10px; }
            .mgd-translate-label { min-width: 50px; font-size: 11px; color: #888; text-transform: uppercase; }
            .mgd-translate-value { flex: 1; font-size: 16px; }
            .mgd-translate-value.mgd-gondi { font-size: 20px; }
            .mgd-translate-close { background: none; border: none; font-size: 18px; cursor: pointer; color: #999; }
            .mgd-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.3); z-index: 9998; display: none; }
            .mgd-overlay.mgd-overlay-visible { display: block; }
            @media (max-width: 480px) {
                .mgd-keyboard { position: fixed; bottom: 0; left: 0; right: 0; border-radius: 12px 12px 0 0; z-index: 9000; }
                .mgd-popup, .mgd-suggestions, .mgd-translate-panel { position: fixed !important; bottom: 0 !important; left: 0 !important; right: 0 !important; top: auto !important; max-width: none; border-radius: 12px 12px 0 0; }
            }
        `;

        $('<style id="mgd-styles">' + minimalCSS + '</style>').appendTo('head');
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MAIN PLUGIN CLASS
    // ═══════════════════════════════════════════════════════════════════════════

    class MasaramGondi {
        constructor(element, options) {
            this.$el = $(element);
            this.options = $.extend(true, {}, DEFAULTS, options);

            // Generate unique ID
            this.uid = 'mgd_' + Math.random().toString(36).substr(2, 9);

            // Core state
            this.buffer = '';
            this.mode = this.options.mode;
            this.$target = this.options.target ? $(this.options.target) : null;
            this.hasTarget = this.$target && this.$target.length > 0;
            this.$ipaTarget = this.options.ipaTarget ? $(this.options.ipaTarget) : null;
            this.hasIpaTarget = this.$ipaTarget && this.$ipaTarget.length > 0;

            // UI elements
            this.$wrapper = null;
            this.$keyboard = null;
            this.$popup = null;
            this.$suggestions = null;
            this.$translatePanel = null;
            this.$overlay = null;

            // State flags
            this._prefixGondi = '';
            this._isEditMode = false;
            this._shiftActive = false;
            this._selectedSuggestionIndex = -1;
            this._longPressTimer = null;
            this._suggestionsCache = {};

            // Interaction flags (prevent blur conflicts)
            this._isClickingKeyboard = false;
            this._isClickingPopup = false;
            this._isClickingSuggestion = false;
            this._isClickingTranslate = false;

            // Toggle states (persisted)
            this._keyboardEnabled = this.options.keyboard;
            this._keyboardVisible = false;
            this._suggestionsEnabled = this.options.suggestions;
            this._translateEnabled = this.options.translate;

            // Load persisted state
            this._loadPersistedState();

            // Merge suggestion data
            this._suggestionsData = $.extend({}, DEFAULT_SUGGESTIONS, this.options.suggestionsData);

            // Debounced API fetch
            this._fetchSuggestionsDebounced = debounce(
                this._fetchSuggestionsFromApi.bind(this),
                this.options.suggestionsApiDebounce
            );

            this._init();
        }

        // ═══════════════════════════════════════════════════════════════════════
        // INITIALIZATION
        // ═══════════════════════════════════════════════════════════════════════

        _init() {
            injectStyles();
            this._createWrapper();

            if (this.options.placeholder) this.$el.attr('placeholder', this.options.placeholder);
            if (this.options.maxLength) this.$el.attr('maxlength', this.options.maxLength);

            this._handleExistingValue();
            this._bindEvents();

            // Create UI components
            this._createKeyboard();
            if (this.options.popup) this._createPopup();
            if (this.options.suggestions) this._createSuggestions();
            if (this.options.translate) this._createTranslatePanel();
            this._createOverlay();

            this.$el.data('masaramGondi', this);

            if (typeof this.options.onReady === 'function') {
                this.options.onReady.call(this);
            }
        }

        _createWrapper() {
            if (!this.$el.parent().hasClass('mgd-wrapper')) {
                this.$el.wrap('<div class="mgd-wrapper"></div>');
            }
            this.$wrapper = this.$el.parent('.mgd-wrapper');
            this.$wrapper.attr('data-mgd-id', this.uid);
        }

        _handleExistingValue() {
            if (this.options.initialValue) {
                this.buffer = this.options.initialValue;
                this._update();
                return;
            }

            const existingValue = this.$el.val();
            if (existingValue && existingValue.trim()) {
                if (this.hasTarget) {
                    this.buffer = existingValue;
                    this._update();
                } else if (this.options.preserveExisting) {
                    this._prefixGondi = existingValue;
                    this._isEditMode = true;
                    this.buffer = '';
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // STATE PERSISTENCE
        // ═══════════════════════════════════════════════════════════════════════

        _getStorageKey() {
            return 'state_' + (this.options.persistKey || 'default');
        }

        _loadPersistedState() {
            if (!this.options.persistState) return;

            const saved = Storage.get(this._getStorageKey(), null);
            if (saved) {
                if (typeof saved.keyboardEnabled === 'boolean') {
                    this._keyboardEnabled = saved.keyboardEnabled;
                }
                if (typeof saved.suggestionsEnabled === 'boolean') {
                    this._suggestionsEnabled = saved.suggestionsEnabled;
                }
                if (typeof saved.translateEnabled === 'boolean') {
                    this._translateEnabled = saved.translateEnabled;
                }
                if (saved.mode && (saved.mode === 'en' || saved.mode === 'hi')) {
                    this.mode = saved.mode;
                }
            }
        }

        _savePersistedState() {
            if (!this.options.persistState) return;

            Storage.set(this._getStorageKey(), {
                keyboardEnabled: this._keyboardEnabled,
                suggestionsEnabled: this._suggestionsEnabled,
                translateEnabled: this._translateEnabled,
                mode: this.mode
            });
        }

        // ═══════════════════════════════════════════════════════════════════════
        // EVENT BINDING
        // ═══════════════════════════════════════════════════════════════════════

        _bindEvents() {
            const self = this;

            // ─────────────────────────────────────────────────────────────────
            // IME COMPOSITION TRACKING
            // ─────────────────────────────────────────────────────────────────
            this._isComposing = false;

            this.$el.on('compositionstart.' + this.uid, function () {
                self._isComposing = true;
            });

            this.$el.on('compositionend.' + this.uid, function (e) {
                self._isComposing = false;
                // Handle the composed text (IME output)
                const composedText = e.originalEvent.data;
                if (composedText) {
                    // Clear the input value (IME already inserted it)
                    const currentVal = self.$el.val();
                    // Remove the composed text that was inserted by IME
                    // and add it to our buffer for proper conversion
                    self.$el.val('');
                    self.buffer = '';
                    self._prefixGondi = '';

                    // Type the composed text through our system
                    self._type(currentVal);
                }
            });

            // ─────────────────────────────────────────────────────────────────
            // INPUT EVENT (for IME and other direct input)
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('input.' + this.uid, function (e) {
                // During composition, don't process - wait for compositionend
                if (self._isComposing) return;

                // Check if this is an insertText from IME or other source
                // that bypassed our keydown handler
                if (e.originalEvent && e.originalEvent.inputType === 'insertText') {
                    // This might be IME on some browsers, handle it
                    const insertedData = e.originalEvent.data;
                    if (insertedData && insertedData.length > 0) {
                        // Check if it's Hindi text that IME inserted
                        const currentVal = self.$el.val();
                        // If the input has changed outside our control, sync it
                        const expectedVal = self._prefixGondi + transliterate(self.buffer, self.mode);
                        if (currentVal !== expectedVal) {
                            // IME inserted text, capture it
                            self.$el.val('');
                            self.buffer = '';
                            self._prefixGondi = '';
                            self._type(currentVal);
                        }
                    }
                } else {
                    // For any other input event, ensure IPA is updated
                    if (self.options.ipa && self.hasIpaTarget) {
                        const currentVal = self.$el.val();
                        const gondiText = self._prefixGondi + transliterate(self.buffer, self.mode);
                        if (currentVal === gondiText) {
                            const ipaText = gondiToIPA(gondiText);

                            // First try to update Alpine model directly
                            let alpineUpdated = false;
                            if (window.Alpine && self.$ipaTarget[0]) {
                                let element = self.$ipaTarget[0];
                                while (element && element !== document.body) {
                                    if (element.hasAttribute && element.hasAttribute('x-data')) {
                                        const component = window.Alpine.$data(element);
                                        if (component && component.formData && component.formData.pronunciation !== undefined) {
                                            component.formData.pronunciation = ipaText;
                                            alpineUpdated = true;
                                            break;
                                        }
                                    }
                                    element = element.parentElement;
                                }
                            }

                            // If Alpine update didn't work, update the input directly
                            if (!alpineUpdated) {
                                if (self.$ipaTarget.is('input, textarea')) {
                                    self.$ipaTarget.val(ipaText);
                                } else {
                                    self.$ipaTarget.text(ipaText);
                                }
                                // Trigger input event for Alpine.js or other frameworks
                                self.$ipaTarget.trigger('input');
                            }
                        }
                    }
                }
            });

            // ─────────────────────────────────────────────────────────────────
            // KEYDOWN
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('keydown.' + this.uid, function (e) {
                // Don't intercept during IME composition
                if (self._isComposing) return true;

                // Also check for Process key (used by some IMEs)
                if (e.key === 'Process' || e.keyCode === 229) return true;

                if (e.key === 'Tab') return true;

                // Suggestions navigation
                if (self._isSuggestionsVisible()) {
                    if (e.key === 'ArrowDown') {
                        e.preventDefault();
                        self._navigateSuggestion(1);
                        return false;
                    }
                    if (e.key === 'ArrowUp') {
                        e.preventDefault();
                        self._navigateSuggestion(-1);
                        return false;
                    }
                    if (e.key === 'Enter' && self._selectedSuggestionIndex >= 0) {
                        e.preventDefault();
                        self._selectSuggestion(self._selectedSuggestionIndex);
                        return false;
                    }
                    if (e.key === 'Escape') {
                        e.preventDefault();
                        self._hideSuggestions();
                        return false;
                    }
                }

                if (e.key.startsWith('Arrow')) return true;

                const el = this;
                const selStart = el.selectionStart;
                const selEnd = el.selectionEnd;
                const valLength = el.value.length;
                const hasRealSelection = typeof selStart === 'number' &&
                    typeof selEnd === 'number' &&
                    selStart !== selEnd && valLength > 0;
                const isAllSelected = hasRealSelection && selStart === 0 && selEnd === valLength;

                // Backspace / Delete
                if (e.key === 'Backspace' || e.key === 'Delete') {
                    e.preventDefault();
                    if (isAllSelected) {
                        self._clearAll();
                    } else if (hasRealSelection) {
                        self._deleteSelection(selStart, selEnd, valLength);
                    } else {
                        self._backspace();
                    }
                    return false;
                }

                // Enter
                if (e.key === 'Enter' && self.$el.is('textarea')) {
                    e.preventDefault();
                    if (isAllSelected) self._clearAll();
                    self._type('\n');
                    return false;
                }

                // Ctrl/Cmd shortcuts
                if (e.ctrlKey || e.metaKey) {
                    switch (e.key.toLowerCase()) {
                        case 'a': return true;
                        case 'c': e.preventDefault(); self._copy(); return false;
                        case 'x': e.preventDefault(); self._cut(); return false;
                        case 'v': return true;
                        case 'z': e.preventDefault(); self._backspace(); return false;
                        default: return true;
                    }
                }

                // Regular character (only if not IME)
                if (e.key.length === 1) {
                    e.preventDefault();
                    if (isAllSelected) self._clearAll();
                    else if (hasRealSelection) self._deleteSelection(selStart, selEnd, valLength);
                    self._type(e.key);
                    return false;
                }
            });

            // ─────────────────────────────────────────────────────────────────
            // PASTE
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('paste.' + this.uid, function (e) {
                e.preventDefault();
                const el = this;
                const isAllSelected = el.selectionStart === 0 &&
                    el.selectionEnd === el.value.length &&
                    el.value.length > 0;
                if (isAllSelected) self._clearAll();

                const text = (e.originalEvent.clipboardData || window.clipboardData).getData('text');
                if (text) self._type(text);
            });

            // ─────────────────────────────────────────────────────────────────
            // FOCUS
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('focus.' + this.uid, function () {
                // Position cursor at end
                setTimeout(function () {
                    const len = self.$el.val().length;
                    if (self.$el[0].setSelectionRange) {
                        self.$el[0].setSelectionRange(len, len);
                    }
                }, 10);

                // Show keyboard if enabled and auto-show is on
                if (self._keyboardEnabled && self.options.keyboardAutoShow) {
                    self._showKeyboard();
                }
            });

            // ─────────────────────────────────────────────────────────────────
            // BLUR
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('blur.' + this.uid, function () {
                setTimeout(function () {
                    // Don't hide if clicking on our UI elements
                    if (self._isClickingKeyboard || self._isClickingPopup ||
                        self._isClickingSuggestion || self._isClickingTranslate) {
                        return;
                    }

                    // Hide popup
                    self._hidePopup();

                    // Hide suggestions
                    self._hideSuggestions();

                    // Hide keyboard if auto-hide is on
                    if (self.options.keyboardAutoHide) {
                        self._hideKeyboard();
                    }
                }, 150);
            });

            // ─────────────────────────────────────────────────────────────────
            // CONTEXT MENU (Right-click)
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('contextmenu.' + this.uid, function (e) {
                if (self.options.popup) {
                    e.preventDefault();
                    self._showPopup(e.pageX, e.pageY);
                }
            });

            // ─────────────────────────────────────────────────────────────────
            // LONG PRESS (Mobile)
            // ─────────────────────────────────────────────────────────────────
            this.$el.on('touchstart.' + this.uid, function (e) {
                if (self.options.popup) {
                    self._longPressTimer = setTimeout(function () {
                        const touch = e.originalEvent.touches[0];
                        self._showPopup(touch.pageX, touch.pageY);
                    }, 600);
                }
            });

            this.$el.on('touchend.' + this.uid + ' touchmove.' + this.uid, function () {
                if (self._longPressTimer) {
                    clearTimeout(self._longPressTimer);
                    self._longPressTimer = null;
                }
            });

            // ─────────────────────────────────────────────────────────────────
            // DOCUMENT EVENTS
            // ─────────────────────────────────────────────────────────────────
            $(document).on('click.' + this.uid, function (e) {
                const $target = $(e.target);

                // Close popup if clicking outside
                if (!$target.closest('.mgd-popup, .mgd-wrapper').length) {
                    self._hidePopup();
                }

                // Close suggestions if clicking outside
                if (!$target.closest('.mgd-suggestions, .mgd-wrapper').length) {
                    self._hideSuggestions();
                }
            });

            $(document).on('keydown.' + this.uid, function (e) {
                if (e.key === 'Escape') {
                    self._hidePopup();
                    self._hideSuggestions();
                    self._hideTranslatePanel();
                }
            });
        }

        // ═══════════════════════════════════════════════════════════════════════
        // OVERLAY
        // ═══════════════════════════════════════════════════════════════════════

        _createOverlay() {
            this.$overlay = $('<div class="mgd-overlay"></div>');
            $('body').append(this.$overlay);

            const self = this;
            this.$overlay.on('click.' + this.uid, function () {
                self._hidePopup();
                self._hideSuggestions();
                self._hideTranslatePanel();
                self._hideOverlay();
            });
        }

        _showOverlay() {
            if (this.$overlay) {
                this.$overlay.addClass('mgd-overlay-visible');
            }
        }

        _hideOverlay() {
            if (this.$overlay) {
                this.$overlay.removeClass('mgd-overlay-visible');
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // KEYBOARD
        // ═══════════════════════════════════════════════════════════════════════

        _createKeyboard() {
            const self = this;
            const layoutName = this.options.keyboardLayout;
            const layout = KEYBOARD_LAYOUTS[layoutName] || KEYBOARD_LAYOUTS.itrans;

            this.$keyboard = $('<div class="mgd-keyboard mgd-keyboard-' + layoutName + '"></div>');

            // Create rows
            if (layout.rows) {
                layout.rows.forEach(function (rowData) {
                    const $row = $('<div class="mgd-keyboard-row ' + (rowData.class || '') + '"></div>');

                    rowData.keys.forEach(function (key) {
                        const $key = self._createKeyboardKey(key, layoutName);
                        $row.append($key);
                    });

                    self.$keyboard.append($row);
                });
            }

            // Vowels row
            if (layout.vowels) {
                const $vowelRow = $('<div class="mgd-keyboard-row mgd-vowel-row"></div>');
                layout.vowels.forEach(function (vowel) {
                    const $key = self._createKeyboardKey(vowel, layoutName, true);
                    $vowelRow.append($key);
                });
                this.$keyboard.append($vowelRow);
            }

            // Matras row
            if (layout.matras) {
                const $matraRow = $('<div class="mgd-keyboard-row mgd-marks-row"></div>');
                layout.matras.forEach(function (matra) {
                    const $key = self._createKeyboardKey(matra, layoutName, true);
                    $key.addClass('mgd-key-mark');
                    $matraRow.append($key);
                });
                this.$keyboard.append($matraRow);
            }

            // Marks row (Gondi)
            if (layout.marks) {
                const $marksRow = $('<div class="mgd-keyboard-row mgd-marks-row"></div>');
                layout.marks.forEach(function (mark) {
                    const $key = self._createKeyboardKey(mark, layoutName, true);
                    $key.addClass('mgd-key-mark');
                    $marksRow.append($key);
                });
                this.$keyboard.append($marksRow);
            }

            // Special keys row
            const $specialRow = $('<div class="mgd-keyboard-row mgd-keyboard-special"></div>');

            // Shift (ITRANS only)
            if (layoutName === 'itrans') {
                const $shift = $('<button type="button" class="mgd-key mgd-key-shift" data-action="shift"><span class="mgd-key-main">⇧</span></button>');
                $shift.on('click', function (e) {
                    e.preventDefault();
                    self._toggleShift();
                });
                $specialRow.append($shift);
            }

            // Space
            const $space = $('<button type="button" class="mgd-key mgd-key-space" data-action="space"><span>Space</span></button>');
            $space.on('click', function (e) {
                e.preventDefault();
                self._type(' ');
                self.$el.focus();
            });
            $specialRow.append($space);

            // Backspace
            const $backspace = $('<button type="button" class="mgd-key mgd-key-backspace" data-action="backspace"><span>⌫</span></button>');
            $backspace.on('click', function (e) {
                e.preventDefault();
                self._backspace();
                self.$el.focus();
            });
            $specialRow.append($backspace);

            // Clear
            const $clear = $('<button type="button" class="mgd-key mgd-key-clear" data-action="clear"><span>✕</span></button>');
            $clear.on('click', function (e) {
                e.preventDefault();
                self._clearAll();
                self.$el.focus();
            });
            $specialRow.append($clear);

            // Hide keyboard
            const $hide = $('<button type="button" class="mgd-key mgd-key-hide" data-action="hide"><span>⌨↓</span></button>');
            $hide.on('click', function (e) {
                e.preventDefault();
                self._hideKeyboard();
                // Disable auto-show until re-enabled from menu
                if (self._keyboardEnabled) {
                    self._keyboardEnabled = false;
                    self._savePersistedState();
                }
            });
            $specialRow.append($hide);

            this.$keyboard.append($specialRow);

            // Position
            if (this.options.keyboardPosition === 'top') {
                this.$wrapper.prepend(this.$keyboard);
            } else {
                this.$wrapper.append(this.$keyboard);
            }

            // Prevent blur when clicking keyboard
            this.$keyboard.on('mousedown touchstart', function (e) {
                e.preventDefault(); // Prevent blur from happening
                self._isClickingKeyboard = true;
            });

            this.$keyboard.on('mouseup touchend', function () {
                setTimeout(function () {
                    self._isClickingKeyboard = false;
                }, 200);
            });
        }

        _createKeyboardKey(key, layoutName, isDirect) {
            const self = this;
            const $key = $('<button type="button" class="mgd-key"></button>');
            $key.attr('data-key', key);

            let displayMain = key;
            let displaySub = '';

            if (layoutName === 'itrans' && !isDirect) {
                // Show Gondi character as main, ITRANS as sub
                displayMain = this._getGondiForKey(key);
                displaySub = key;
            } else if (layoutName === 'hindi' && !isDirect) {
                // Show Hindi as main, Gondi as sub
                displayMain = key;
                displaySub = this._getGondiForHindiKey(key);
            }

            if (displaySub) {
                $key.html('<span class="mgd-key-main">' + displayMain + '</span>' +
                    '<span class="mgd-key-sub">' + displaySub + '</span>');
            } else {
                $key.html('<span class="mgd-key-main">' + displayMain + '</span>');
            }

            $key.on('click', function (e) {
                e.preventDefault();
                let charToType = key;

                // Handle shift for ITRANS
                if (layoutName === 'itrans' && self._shiftActive) {
                    const layout = KEYBOARD_LAYOUTS.itrans;
                    if (layout.shiftMap && layout.shiftMap[key]) {
                        charToType = layout.shiftMap[key];
                    } else {
                        charToType = key.toUpperCase();
                    }
                    self._toggleShift();
                }

                self._type(charToType);
                self.$el.focus();
            });

            return $key;
        }

        _getGondiForKey(key) {
            return Core.EN_CONSONANTS[key] || Core.EN_VOWELS[key] || Core.EN_NUMBERS[key] ||
                transliterate(key, 'en');
        }

        _getGondiForHindiKey(key) {
            return Core.HI_CONSONANTS[key] || Core.HI_VOWELS[key] || Core.HI_NUMBERS[key] ||
                transliterate(key, 'hi');
        }

        _toggleShift() {
            this._shiftActive = !this._shiftActive;
            this.$keyboard.find('.mgd-key-shift').toggleClass('mgd-active', this._shiftActive);
            this.$keyboard.toggleClass('mgd-shift-active', this._shiftActive);
        }

        _showKeyboard() {
            if (this.$keyboard && !this._keyboardVisible) {
                // Hide popup if open (conflict resolution)
                this._hidePopup();

                this.$keyboard.addClass('mgd-keyboard-visible');
                this._keyboardVisible = true;

                if (typeof this.options.onKeyboardToggle === 'function') {
                    this.options.onKeyboardToggle.call(this, true);
                }
            }
        }

        _hideKeyboard() {
            if (this.$keyboard && this._keyboardVisible) {
                this.$keyboard.removeClass('mgd-keyboard-visible');
                this._keyboardVisible = false;

                if (typeof this.options.onKeyboardToggle === 'function') {
                    this.options.onKeyboardToggle.call(this, false);
                }
            }
        }

        _rebuildKeyboard(layoutName) {
            // Store current visibility state
            const wasVisible = this._keyboardVisible;

            // Remove old keyboard
            if (this.$keyboard) {
                this.$keyboard.remove();
            }

            // Update layout option
            this.options.keyboardLayout = layoutName;

            // Create new keyboard with new layout
            this._createKeyboard();

            // Restore visibility if it was visible
            if (wasVisible) {
                this._keyboardVisible = false; // Reset so _showKeyboard works
                this._showKeyboard();
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // POPUP MENU
        // ═══════════════════════════════════════════════════════════════════════

        _createPopup() {
            const self = this;

            this.$popup = $('<div class="mgd-popup"></div>');
            this._renderPopupItems();

            $('body').append(this.$popup);

            // Prevent blur
            this.$popup.on('mousedown touchstart', function () {
                self._isClickingPopup = true;
            });

            this.$popup.on('mouseup touchend', function () {
                setTimeout(function () {
                    self._isClickingPopup = false;
                }, 100);
            });
        }

        _renderPopupItems() {
            const self = this;
            this.$popup.empty();

            this.options.popupItems.forEach(function (item) {
                if (item === 'divider') {
                    self.$popup.append('<div class="mgd-popup-divider"></div>');
                    return;
                }

                const $item = self._createPopupItem(item);
                if ($item) self.$popup.append($item);
            });
        }

        _createPopupItem(type) {
            const self = this;
            let $item;

            switch (type) {
                case 'copy':
                    $item = $('<div class="mgd-popup-item" data-action="copy">' +
                        '<span class="mgd-popup-icon">📋</span>' +
                        '<span class="mgd-popup-label">Copy</span>' +
                        '<span class="mgd-popup-shortcut">Ctrl+C</span>' +
                        '</div>');
                    $item.on('click', function () {
                        self._copy();
                        self._hidePopup();
                    });
                    break;

                case 'cut':
                    $item = $('<div class="mgd-popup-item" data-action="cut">' +
                        '<span class="mgd-popup-icon">✂️</span>' +
                        '<span class="mgd-popup-label">Cut</span>' +
                        '<span class="mgd-popup-shortcut">Ctrl+X</span>' +
                        '</div>');
                    $item.on('click', function () {
                        self._cut();
                        self._hidePopup();
                    });
                    break;

                case 'paste':
                    $item = $('<div class="mgd-popup-item" data-action="paste">' +
                        '<span class="mgd-popup-icon">📄</span>' +
                        '<span class="mgd-popup-label">Paste</span>' +
                        '<span class="mgd-popup-shortcut">Ctrl+V</span>' +
                        '</div>');
                    $item.on('click', function () {
                        self._paste();
                        self._hidePopup();
                    });
                    break;

                case 'selectAll':
                    $item = $('<div class="mgd-popup-item" data-action="selectAll">' +
                        '<span class="mgd-popup-icon">☑️</span>' +
                        '<span class="mgd-popup-label">Select All</span>' +
                        '<span class="mgd-popup-shortcut">Ctrl+A</span>' +
                        '</div>');
                    $item.on('click', function () {
                        self.$el.select();
                        self._hidePopup();
                    });
                    break;

                case 'clear':
                    $item = $('<div class="mgd-popup-item" data-action="clear">' +
                        '<span class="mgd-popup-icon">🗑️</span>' +
                        '<span class="mgd-popup-label">Clear All</span>' +
                        '</div>');
                    $item.on('click', function () {
                        self._clearAll();
                        self._hidePopup();
                    });
                    break;

                case 'mode':
                    $item = $('<div class="mgd-popup-item" data-action="mode">' +
                        '<span class="mgd-popup-icon">🔤</span>' +
                        '<span class="mgd-popup-label">Input Mode</span>' +
                        '<span class="mgd-mode-badge mgd-mode-' + this.mode + '">' +
                        (this.mode === 'en' ? 'EN' : 'हि') + '</span>' +
                        '</div>');
                    $item.on('click', function () {
                        self._toggleMode();
                        // Update badge
                        $(this).find('.mgd-mode-badge')
                            .removeClass('mgd-mode-en mgd-mode-hi')
                            .addClass('mgd-mode-' + self.mode)
                            .text(self.mode === 'en' ? 'EN' : 'हि');
                    });
                    break;

                case 'keyboard':
                    $item = $('<div class="mgd-popup-item" data-action="keyboard">' +
                        '<span class="mgd-popup-icon">⌨️</span>' +
                        '<span class="mgd-popup-label">Virtual Keyboard</span>' +
                        '<div class="mgd-popup-toggle ' + (this._keyboardEnabled ? 'mgd-active' : '') + '"></div>' +
                        '</div>');
                    $item.on('click', function () {
                        self._keyboardEnabled = !self._keyboardEnabled;
                        $(this).find('.mgd-popup-toggle').toggleClass('mgd-active', self._keyboardEnabled);

                        if (self._keyboardEnabled) {
                            self._showKeyboard();
                        } else {
                            self._hideKeyboard();
                        }

                        self._savePersistedState();
                        self._hidePopup();
                        self.$el.focus();
                    });
                    break;

                case 'suggestions':
                    $item = $('<div class="mgd-popup-item" data-action="suggestions">' +
                        '<span class="mgd-popup-icon">💡</span>' +
                        '<span class="mgd-popup-label">Suggestions</span>' +
                        '<div class="mgd-popup-toggle ' + (this._suggestionsEnabled ? 'mgd-active' : '') + '"></div>' +
                        '</div>');
                    $item.on('click', function () {
                        self._suggestionsEnabled = !self._suggestionsEnabled;
                        $(this).find('.mgd-popup-toggle').toggleClass('mgd-active', self._suggestionsEnabled);

                        if (!self._suggestionsEnabled) {
                            self._hideSuggestions();
                        }

                        self._savePersistedState();
                    });
                    break;

                case 'translate':
                    $item = $('<div class="mgd-popup-item" data-action="translate">' +
                        '<span class="mgd-popup-icon">🌐</span>' +
                        '<span class="mgd-popup-label">Show Translation</span>' +
                        '<div class="mgd-popup-toggle ' + (this._translateEnabled ? 'mgd-active' : '') + '"></div>' +
                        '</div>');
                    $item.on('click', function () {
                        self._translateEnabled = !self._translateEnabled;
                        $(this).find('.mgd-popup-toggle').toggleClass('mgd-active', self._translateEnabled);

                        if (self._translateEnabled) {
                            self._showTranslatePanel();
                        } else {
                            self._hideTranslatePanel();
                        }

                        self._savePersistedState();
                    });
                    break;

                default:
                    return null;
            }

            return $item;
        }

        _showPopup(x, y) {
            if (!this.$popup) return;

            // Hide keyboard first (conflict resolution)
            this._hideKeyboard();
            this._hideSuggestions();

            // Update toggle states in popup
            this._updatePopupStates();

            const ww = $(window).width();
            const wh = $(window).height();
            const pw = this.$popup.outerWidth() || 200;
            const ph = this.$popup.outerHeight() || 300;

            // Adjust position
            if (x + pw > ww - 10) x = ww - pw - 10;
            if (y + ph > wh - 10) y = wh - ph - 10;
            if (x < 10) x = 10;
            if (y < 10) y = 10;

            // Mobile: bottom sheet
            if ($(window).width() <= 480) {
                this.$popup.css({ left: 0, right: 0, top: 'auto', bottom: 0 });
                this._showOverlay();
            } else {
                this.$popup.css({ left: x, top: y, bottom: 'auto', right: 'auto' });
            }

            this.$popup.addClass('mgd-popup-visible');
        }

        _hidePopup() {
            if (this.$popup) {
                this.$popup.removeClass('mgd-popup-visible');
            }
            this._hideOverlay();
        }

        _updatePopupStates() {
            if (!this.$popup) return;

            // Update mode badge
            const $modeBadge = this.$popup.find('[data-action="mode"] .mgd-mode-badge');
            if ($modeBadge.length) {
                $modeBadge.removeClass('mgd-mode-en mgd-mode-hi')
                    .addClass('mgd-mode-' + this.mode)
                    .text(this.mode === 'en' ? 'EN' : 'हि');
            }

            // Update toggles
            this.$popup.find('[data-action="keyboard"] .mgd-popup-toggle')
                .toggleClass('mgd-active', this._keyboardEnabled);
            this.$popup.find('[data-action="suggestions"] .mgd-popup-toggle')
                .toggleClass('mgd-active', this._suggestionsEnabled);
            this.$popup.find('[data-action="translate"] .mgd-popup-toggle')
                .toggleClass('mgd-active', this._translateEnabled);
        }

        // ═══════════════════════════════════════════════════════════════════════
        // SUGGESTIONS
        // ═══════════════════════════════════════════════════════════════════════

        _createSuggestions() {
            const self = this;

            this.$suggestions = $('<div class="mgd-suggestions"></div>');
            this.$wrapper.append(this.$suggestions);

            // Prevent blur
            this.$suggestions.on('mousedown touchstart', function () {
                self._isClickingSuggestion = true;
            });

            this.$suggestions.on('mouseup touchend', function () {
                setTimeout(function () {
                    self._isClickingSuggestion = false;
                }, 100);
            });
        }

        _isSuggestionsVisible() {
            return this.$suggestions && this.$suggestions.hasClass('mgd-suggestions-visible');
        }

        _updateSuggestions() {
            if (!this._suggestionsEnabled || !this.$suggestions) return;

            const query = this.buffer.trim().toLowerCase();
            if (query.length < this.options.minSuggestionLength) {
                this._hideSuggestions();
                return;
            }

            // Get last word
            const words = query.split(/\s+/);
            const lastWord = words[words.length - 1];

            if (lastWord.length < this.options.minSuggestionLength) {
                this._hideSuggestions();
                return;
            }

            // Local suggestions
            const localMatches = this._getLocalSuggestions(lastWord);

            // API suggestions
            if (this.options.suggestionsApi) {
                this._fetchSuggestionsDebounced(lastWord, localMatches);
            } else {
                this._displaySuggestions(localMatches, lastWord);
            }
        }

        _getLocalSuggestions(query) {
            const matches = [];
            const maxResults = this.options.maxSuggestions;

            for (const [roman, hindi] of Object.entries(this._suggestionsData)) {
                if (roman.toLowerCase().startsWith(query)) {
                    matches.push({
                        roman: roman,
                        hindi: hindi,
                        gondi: transliterate(roman, 'en'),
                        source: 'local'
                    });
                    if (matches.length >= maxResults) break;
                }
            }

            return matches;
        }

        _fetchSuggestionsFromApi(query, localMatches) {
            const self = this;

            // Check cache
            if (this._suggestionsCache[query]) {
                const combined = this._combineSuggestions(localMatches, this._suggestionsCache[query]);
                this._displaySuggestions(combined, query);
                return;
            }

            const url = this.options.suggestionsApi;
            const method = this.options.suggestionsApiMethod;
            const param = this.options.suggestionsApiParam;

            const ajaxOptions = {
                url: method === 'GET' ?
                    url + (url.includes('?') ? '&' : '?') + param + '=' + encodeURIComponent(query) :
                    url,
                method: method,
                dataType: 'json'
            };

            if (method !== 'GET') {
                ajaxOptions.data = {};
                ajaxOptions.data[param] = query;
            }

            $.ajax(ajaxOptions)
                .done(function (response) {
                    let apiMatches = [];

                    if (typeof self.options.suggestionsApiTransform === 'function') {
                        apiMatches = self.options.suggestionsApiTransform(response);
                    } else if (Array.isArray(response)) {
                        apiMatches = response.map(function (item) {
                            if (typeof item === 'string') {
                                return {
                                    roman: item,
                                    hindi: '',
                                    gondi: transliterate(item, 'en'),
                                    source: 'api'
                                };
                            }
                            return {
                                roman: item.roman || item.word || item.text || '',
                                hindi: item.hindi || item.devanagari || '',
                                gondi: item.gondi || transliterate(item.roman || item.word || '', 'en'),
                                source: 'api'
                            };
                        });
                    }

                    self._suggestionsCache[query] = apiMatches;
                    const combined = self._combineSuggestions(localMatches, apiMatches);
                    self._displaySuggestions(combined, query);
                })
                .fail(function () {
                    self._displaySuggestions(localMatches, query);
                });
        }

        _combineSuggestions(local, api) {
            const combined = [...local];
            const existing = new Set(local.map(m => m.roman.toLowerCase()));

            for (const match of api) {
                if (!existing.has(match.roman.toLowerCase())) {
                    combined.push(match);
                    if (combined.length >= this.options.maxSuggestions) break;
                }
            }

            return combined.slice(0, this.options.maxSuggestions);
        }

        _displaySuggestions(matches, query) {
            if (matches.length === 0) {
                this._hideSuggestions();
                return;
            }

            this._renderSuggestions(matches, query);
            this._showSuggestions();
        }

        _renderSuggestions(matches, query) {
            const self = this;
            this.$suggestions.empty();
            this._selectedSuggestionIndex = -1;

            matches.forEach(function (match, index) {
                const sourceClass = match.source === 'api' ? 'mgd-suggestion-api' : '';
                const $item = $('<div class="mgd-suggestion-item ' + sourceClass + '" data-index="' + index + '" data-roman="' + match.roman + '">' +
                    '<span class="mgd-suggestion-gondi">' + match.gondi + '</span>' +
                    '<span class="mgd-suggestion-roman">' + match.roman + '</span>' +
                    (match.hindi ? '<span class="mgd-suggestion-hindi">' + match.hindi + '</span>' : '') +
                    '</div>');

                $item.on('click', function () {
                    self._selectSuggestion(index);
                });

                $item.on('mouseenter', function () {
                    self._selectedSuggestionIndex = index;
                    self.$suggestions.find('.mgd-suggestion-item').removeClass('mgd-selected');
                    $(this).addClass('mgd-selected');
                });

                self.$suggestions.append($item);
            });
        }

        _showSuggestions() {
            if (!this.$suggestions) return;

            // Position
            if ($(window).width() > 480) {
                this.$suggestions.css({
                    top: this.$el.outerHeight() + 5,
                    left: 0
                });
            }

            this.$suggestions.addClass('mgd-suggestions-visible');
        }

        _hideSuggestions() {
            if (this.$suggestions) {
                this.$suggestions.removeClass('mgd-suggestions-visible');
            }
            this._selectedSuggestionIndex = -1;
        }

        _navigateSuggestion(direction) {
            if (!this.$suggestions) return;

            const $items = this.$suggestions.find('.mgd-suggestion-item');
            const count = $items.length;
            if (count === 0) return;

            $items.removeClass('mgd-selected');
            this._selectedSuggestionIndex += direction;

            if (this._selectedSuggestionIndex < 0) {
                this._selectedSuggestionIndex = count - 1;
            } else if (this._selectedSuggestionIndex >= count) {
                this._selectedSuggestionIndex = 0;
            }

            $items.eq(this._selectedSuggestionIndex).addClass('mgd-selected');
        }

        _selectSuggestion(index) {
            const $item = this.$suggestions.find('.mgd-suggestion-item').eq(index);
            if (!$item.length) return;

            const roman = $item.data('roman');
            const words = this.buffer.trim().split(/\s+/);
            words[words.length - 1] = roman;
            this.buffer = words.join(' ') + ' ';

            this._update();
            this._hideSuggestions();
            this.$el.focus();

            if (typeof this.options.onSuggestionSelect === 'function') {
                this.options.onSuggestionSelect.call(this, roman);
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // TRANSLATE PANEL
        // ═══════════════════════════════════════════════════════════════════════

        _createTranslatePanel() {
            const self = this;

            this.$translatePanel = $(`
                <div class="mgd-translate-panel">
                    <div class="mgd-translate-header">
                        <span class="mgd-translate-title">🌐 Translation</span>
                        <button type="button" class="mgd-translate-close">×</button>
                    </div>
                    <div class="mgd-translate-content">
                        <div class="mgd-translate-row">
                            <span class="mgd-translate-label">Input</span>
                            <span class="mgd-translate-value mgd-translate-input"></span>
                        </div>
                        <div class="mgd-translate-row">
                            <span class="mgd-translate-label">Gondi</span>
                            <span class="mgd-translate-value mgd-gondi mgd-translate-gondi"></span>
                        </div>
                        <div class="mgd-translate-row mgd-translate-hindi-row">
                            <span class="mgd-translate-label">Hindi</span>
                            <span class="mgd-translate-value mgd-translate-hindi"></span>
                        </div>
                    </div>
                </div>
            `);

            this.$wrapper.append(this.$translatePanel);

            // Close button
            this.$translatePanel.find('.mgd-translate-close').on('click', function () {
                self._hideTranslatePanel();
                self._translateEnabled = false;
                self._savePersistedState();
            });

            // Prevent blur
            this.$translatePanel.on('mousedown touchstart', function () {
                self._isClickingTranslate = true;
            });

            this.$translatePanel.on('mouseup touchend', function () {
                setTimeout(function () {
                    self._isClickingTranslate = false;
                }, 100);
            });
        }

        _showTranslatePanel() {
            if (!this.$translatePanel) return;

            this._updateTranslatePanel();

            if ($(window).width() > 480) {
                this.$translatePanel.css({
                    top: this.$el.outerHeight() + 5,
                    left: 0
                });
            }

            this.$translatePanel.addClass('mgd-translate-visible');
        }

        _hideTranslatePanel() {
            if (this.$translatePanel) {
                this.$translatePanel.removeClass('mgd-translate-visible');
            }
        }

        _updateTranslatePanel() {
            if (!this.$translatePanel || !this._translateEnabled) return;

            const input = this.buffer || '';
            const gondi = this.getGondiValue();

            this.$translatePanel.find('.mgd-translate-input').text(input || '—');
            this.$translatePanel.find('.mgd-translate-gondi').text(gondi || '—');

            // Show Hindi if mode is English
            if (this.mode === 'en') {
                this.$translatePanel.find('.mgd-translate-hindi-row').show();
                // For Hindi, we'd need a dictionary or API
                // For now, just show placeholder
                this.$translatePanel.find('.mgd-translate-hindi').text('—');
            } else {
                this.$translatePanel.find('.mgd-translate-hindi-row').hide();
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // CORE OPERATIONS
        // ═══════════════════════════════════════════════════════════════════════

        _type(text) {
            if (this.options.maxLength) {
                const currentLen = this._prefixGondi.length + transliterate(this.buffer, this.mode).length;
                const available = this.options.maxLength - currentLen;
                if (available <= 0) return;
                text = text.substring(0, available);
            }

            this.buffer += text;
            this._update();
            this._updateSuggestions();
            this._updateTranslatePanel();

            if (typeof this.options.onInput === 'function') {
                this.options.onInput.call(this, text, this.buffer, this.getGondiValue());
            }
        }

        _backspace() {
            if (this.buffer.length > 0) {
                this.buffer = this.buffer.slice(0, -1);
                this._update();
                this._updateSuggestions();
                this._updateTranslatePanel();
            } else if (this._prefixGondi.length > 0) {
                this._prefixGondi = this._prefixGondi.slice(0, -1);
                this._update();
            }
        }

        _deleteSelection(selStart, selEnd, valLength) {
            if (valLength === 0) return;

            if (this._prefixGondi && this._isEditMode) {
                const prefixLen = this._prefixGondi.length;

                if (selEnd <= prefixLen) {
                    this._prefixGondi = this._prefixGondi.substring(0, selStart) +
                        this._prefixGondi.substring(selEnd);
                    this._update();
                    return;
                }

                if (selStart < prefixLen) {
                    this._prefixGondi = this._prefixGondi.substring(0, selStart);
                    const bufferDeleteEnd = selEnd - prefixLen;
                    const gondiFromBuffer = transliterate(this.buffer, this.mode);
                    const bufferGondiLen = gondiFromBuffer.length;

                    if (bufferGondiLen > 0) {
                        const removeRatio = bufferDeleteEnd / bufferGondiLen;
                        const bufferCharsToRemove = Math.ceil(this.buffer.length * removeRatio);
                        this.buffer = this.buffer.substring(bufferCharsToRemove);
                    }
                    this._update();
                    return;
                }

                const bufferSelStart = selStart - prefixLen;
                const bufferSelEnd = selEnd - prefixLen;
                const gondiFromBuffer = transliterate(this.buffer, this.mode);
                const bufferGondiLen = gondiFromBuffer.length;

                if (bufferGondiLen > 0) {
                    const startRatio = bufferSelStart / bufferGondiLen;
                    const endRatio = bufferSelEnd / bufferGondiLen;
                    const bufferStart = Math.floor(this.buffer.length * startRatio);
                    const bufferEnd = Math.ceil(this.buffer.length * endRatio);
                    this.buffer = this.buffer.substring(0, bufferStart) +
                        this.buffer.substring(bufferEnd);
                }
                this._update();
                return;
            }

            const gondi = transliterate(this.buffer, this.mode);
            const gondiLen = gondi.length;

            if (gondiLen === 0 || this.buffer.length === 0) return;

            const startRatio = selStart / gondiLen;
            const endRatio = selEnd / gondiLen;
            const bufferStart = Math.floor(this.buffer.length * startRatio);
            const bufferEnd = Math.ceil(this.buffer.length * endRatio);

            this.buffer = this.buffer.substring(0, bufferStart) +
                this.buffer.substring(bufferEnd);

            this._update();
            this._updateSuggestions();
        }

        _clearAll() {
            this.buffer = '';
            this._prefixGondi = '';
            this._isEditMode = false;
            this._update();
            this._hideSuggestions();
            this._updateTranslatePanel();
        }

        _copy() {
            const text = this.getGondiValue();
            if (text && navigator.clipboard) {
                navigator.clipboard.writeText(text);
            }
        }

        _cut() {
            this._copy();
            this._clearAll();
        }

        _paste() {
            const self = this;
            if (navigator.clipboard && navigator.clipboard.readText) {
                navigator.clipboard.readText().then(function (text) {
                    if (text) self._type(text);
                }).catch(function () {
                    self.$el.focus();
                });
            } else {
                this.$el.focus();
            }
        }

        _toggleMode() {
            this.mode = this.mode === 'en' ? 'hi' : 'en';
            this._update();
            this._savePersistedState();

            // Switch keyboard layout based on mode
            const newLayout = this.mode === 'hi' ? 'hindi' : 'itrans';
            if (this.options.keyboardLayout !== newLayout) {
                this._rebuildKeyboard(newLayout);
            }

            if (typeof this.options.onModeChange === 'function') {
                this.options.onModeChange.call(this, this.mode);
            }
        }

        _update() {
            const newGondi = transliterate(this.buffer, this.mode);
            const fullGondi = this._prefixGondi + newGondi;

            if (this.hasTarget) {
                this.$el.val(this.buffer);
                if (this.$target.is('input, textarea')) {
                    this.$target.val(fullGondi);
                } else {
                    this.$target.text(fullGondi);
                }
            } else {
                this.$el.val(fullGondi);
            }


            if (this.options.ipa && this.hasIpaTarget) {
                const ipaText = gondiToIPA(fullGondi);

                // First try to update Alpine model directly
                let alpineUpdated = false;
                if (window.Alpine && this.$ipaTarget[0]) {
                    let element = this.$ipaTarget[0];
                    while (element && element !== document.body) {
                        if (element.hasAttribute && element.hasAttribute('x-data')) {
                            const component = window.Alpine.$data(element);
                            if (component && component.formData && component.formData.pronunciation !== undefined) {
                                component.formData.pronunciation = ipaText;
                                alpineUpdated = true;
                                break;
                            }
                        }
                        element = element.parentElement;
                    }
                }

                // If Alpine update didn't work, update the input directly
                if (!alpineUpdated) {
                    if (this.$ipaTarget.is('input, textarea')) {
                        this.$ipaTarget.val(ipaText);

                        // Force the value to stick
                        setTimeout(() => {
                            this.$ipaTarget.val(ipaText);
                        }, 0);
                    } else {
                        this.$ipaTarget.text(ipaText);
                    }
                    this.$ipaTarget.trigger('input');
                }
            }

            // Position cursor at end
            const el = this.$el[0];
            const len = this.$el.val().length;
            if (el.setSelectionRange) {
                setTimeout(function () {
                    el.setSelectionRange(len, len);
                }, 0);
            }

            if (typeof this.options.onChange === 'function') {
                this.options.onChange.call(this, this.buffer, fullGondi);
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // PUBLIC API
        // ═══════════════════════════════════════════════════════════════════════

        // Values
        getValue() { return this.buffer; }
        getRomanValue() { return this.buffer; }
        getGondiValue() { return this._prefixGondi + transliterate(this.buffer, this.mode); }
        getFullGondiValue() { return this.getGondiValue(); }
        getPrefixGondi() { return this._prefixGondi; }

        setValue(v) {
            this.buffer = v || '';
            this._update();
            return this;
        }

        setGondiValue(v) {
            this._prefixGondi = v || '';
            this.buffer = '';
            this._isEditMode = true;
            this._update();
            return this;
        }

        setRomanValue(v) {
            this._prefixGondi = '';
            this._isEditMode = false;
            this.buffer = v || '';
            this._update();
            return this;
        }

        // Mode
        setMode(m) {
            this.mode = m;
            this._update();
            this._savePersistedState();
            return this;
        }

        getMode() { return this.mode; }

        // Clear & Focus
        clear() {
            this._clearAll();
            return this;
        }

        focus() {
            this.$el.focus();
            return this;
        }

        // Keyboard
        showKeyboard() {
            this._keyboardEnabled = true;
            this._showKeyboard();
            this._savePersistedState();
            return this;
        }

        hideKeyboard() {
            this._hideKeyboard();
            return this;
        }

        toggleKeyboard() {
            if (this._keyboardVisible) {
                this._hideKeyboard();
            } else {
                this._keyboardEnabled = true;
                this._showKeyboard();
            }
            this._savePersistedState();
            return this;
        }

        isKeyboardVisible() { return this._keyboardVisible; }
        isKeyboardEnabled() { return this._keyboardEnabled; }

        enableKeyboard() {
            this._keyboardEnabled = true;
            this._savePersistedState();
            return this;
        }

        disableKeyboard() {
            this._keyboardEnabled = false;
            this._hideKeyboard();
            this._savePersistedState();
            return this;
        }

        // Popup
        showPopup(x, y) {
            x = x || this.$el.offset().left;
            y = y || this.$el.offset().top + this.$el.outerHeight();
            this._showPopup(x, y);
            return this;
        }

        hidePopup() {
            this._hidePopup();
            return this;
        }

        // Suggestions
        showSuggestions() {
            this._suggestionsEnabled = true;
            this._updateSuggestions();
            this._savePersistedState();
            return this;
        }

        hideSuggestions() {
            this._hideSuggestions();
            return this;
        }

        enableSuggestions() {
            this._suggestionsEnabled = true;
            this._savePersistedState();
            return this;
        }

        disableSuggestions() {
            this._suggestionsEnabled = false;
            this._hideSuggestions();
            this._savePersistedState();
            return this;
        }

        isSuggestionsEnabled() { return this._suggestionsEnabled; }

        addSuggestion(roman, hindi) {
            this._suggestionsData[roman] = hindi;
            return this;
        }

        addSuggestions(data) {
            $.extend(this._suggestionsData, data);
            return this;
        }

        clearSuggestionsCache() {
            this._suggestionsCache = {};
            return this;
        }

        setSuggestionsApi(url, options) {
            this.options.suggestionsApi = url;
            if (options) {
                if (options.method) this.options.suggestionsApiMethod = options.method;
                if (options.param) this.options.suggestionsApiParam = options.param;
                if (options.transform) this.options.suggestionsApiTransform = options.transform;
            }
            return this;
        }

        // Translate
        showTranslate() {
            this._translateEnabled = true;
            this._showTranslatePanel();
            this._savePersistedState();
            return this;
        }

        hideTranslate() {
            this._hideTranslatePanel();
            return this;
        }

        enableTranslate() {
            this._translateEnabled = true;
            this._savePersistedState();
            return this;
        }

        disableTranslate() {
            this._translateEnabled = false;
            this._hideTranslatePanel();
            this._savePersistedState();
            return this;
        }

        isTranslateEnabled() { return this._translateEnabled; }

        // State
        getState() {
            return {
                mode: this.mode,
                keyboardEnabled: this._keyboardEnabled,
                keyboardVisible: this._keyboardVisible,
                suggestionsEnabled: this._suggestionsEnabled,
                translateEnabled: this._translateEnabled
            };
        }

        setState(state) {
            if (state.mode) this.mode = state.mode;
            if (typeof state.keyboardEnabled === 'boolean') this._keyboardEnabled = state.keyboardEnabled;
            if (typeof state.suggestionsEnabled === 'boolean') this._suggestionsEnabled = state.suggestionsEnabled;
            if (typeof state.translateEnabled === 'boolean') this._translateEnabled = state.translateEnabled;
            this._update();
            this._savePersistedState();
            return this;
        }

        // Destroy
        destroy() {
            this.$el.off('.' + this.uid);
            $(document).off('.' + this.uid);

            if (this.$keyboard) this.$keyboard.remove();
            if (this.$popup) this.$popup.remove();
            if (this.$suggestions) this.$suggestions.remove();
            if (this.$translatePanel) this.$translatePanel.remove();
            if (this.$overlay) this.$overlay.remove();

            if (this.$wrapper && this.$wrapper.hasClass('mgd-wrapper')) {
                this.$el.unwrap();
            }

            this.$el.removeData('masaramGondi');
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JQUERY PLUGIN
    // ═══════════════════════════════════════════════════════════════════════════

    $.fn.masaramGondi = function (options) {
        const args = Array.prototype.slice.call(arguments, 1);

        if (typeof options === 'string') {
            let result;
            this.each(function () {
                const instance = $(this).data('masaramGondi');
                if (instance && typeof instance[options] === 'function') {
                    result = instance[options].apply(instance, args);
                }
            });
            return result !== undefined ? result : this;
        }

        return this.each(function () {
            if (!$(this).data('masaramGondi')) {
                new MasaramGondi(this, options);
            }
        });
    };

    // ═══════════════════════════════════════════════════════════════════════════
    // AUTO-INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    function autoInit() {
        $('[data-masaram-gondi]').each(function () {
            const $el = $(this);
            if ($el.data('masaramGondi')) {
                console.log('Element already initialized, skipping');
                return;
            }

            const options = {
                mode: $el.data('mode') || 'en',
                target: $el.data('target') || null,
                placeholder: $el.data('placeholder') || $el.attr('placeholder') || '',
                maxLength: parseInt($el.data('maxlength') || $el.attr('maxlength'), 10) || null,
                keyboard: $el.data('keyboard') !== undefined && $el.data('keyboard') !== false,
                keyboardLayout: $el.data('keyboard-layout') || 'itrans',
                keyboardPosition: $el.data('keyboard-position') || 'bottom',
                keyboardAutoShow: $el.data('keyboard-auto-show') !== false,
                keyboardAutoHide: $el.data('keyboard-auto-hide') !== false,
                popup: $el.data('popup') !== false,
                suggestions: $el.data('suggestions') !== false,
                suggestionsApi: $el.data('suggestions-api') || null,
                translate: $el.data('translate') === true,
                preserveExisting: $el.data('preserve-existing') !== false,
                initialValue: $el.data('initial-value') || '',
                persistState: $el.data('persist-state') !== false,
                persistKey: $el.data('persist-key') || $el.attr('id') || 'default',
                ipa: $el.data('ipa') === true,
                ipaTarget: $el.data('ipa-target') || null
            };

            $el.masaramGondi(options);
        });
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATIC API
    // ═══════════════════════════════════════════════════════════════════════════

    $.masaramGondi = $.extend({}, Core, {
        version: '5.7.0',
        init: autoInit,
        refresh: autoInit,
        MasaramGondi: MasaramGondi
    });

    // Auto-init on DOM ready
    $(autoInit);

    // MutationObserver for dynamic content
    if (typeof MutationObserver !== 'undefined') {
        $(function () {
            new MutationObserver(function (mutations) {
                let shouldInit = false;
                mutations.forEach(function (mutation) {
                    mutation.addedNodes.forEach(function (node) {
                        if (node.nodeType === 1) {
                            if ($(node).is('[data-masaram-gondi]') ||
                                $(node).find('[data-masaram-gondi]').length) {
                                shouldInit = true;
                            }
                        }
                    });
                });
                if (shouldInit) autoInit();
            }).observe(document.body, { childList: true, subtree: true });
        });
    }

})(jQuery);