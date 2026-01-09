import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/keyboard_theme.dart';
import '../providers/settings_provider.dart';
import 'custom_words_screen.dart';
import 'theme_selector_screen.dart';
import 'statistics_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(context, notifier),
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance', Icons.palette),

          ListTile(
            leading: CircleAvatar(
              backgroundColor: KeyboardTheme.fromName(
                settings.themeName,
              ).accentColor,
              radius: 14,
            ),
            title: const Text('Keyboard Theme'),
            subtitle: Text(settings.themeName),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSelectorScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Font Size'),
            subtitle: Slider(
              value: settings.fontSize,
              min: 14,
              max: 28,
              divisions: 7,
              label: settings.fontSize.round().toString(),
              onChanged: (value) => notifier.setFontSize(value),
            ),
            trailing: Text(
              '${settings.fontSize.round()}',
              style: theme.textTheme.titleMedium,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.height),
            title: const Text('Key Height'),
            subtitle: Slider(
              value: settings.keyHeight,
              min: 40,
              max: 60,
              divisions: 4,
              label: settings.keyHeight.round().toString(),
              onChanged: (value) => notifier.setKeyHeight(value),
            ),
            trailing: Text(
              '${settings.keyHeight.round()}',
              style: theme.textTheme.titleMedium,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.space_bar),
            title: const Text('Key Spacing'),
            subtitle: Slider(
              value: settings.keySpacing,
              min: 2,
              max: 8,
              divisions: 6,
              label: settings.keySpacing.round().toString(),
              onChanged: (value) => notifier.setKeySpacing(value),
            ),
            trailing: Text(
              '${settings.keySpacing.round()}',
              style: theme.textTheme.titleMedium,
            ),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Layout', Icons.keyboard),

          SwitchListTile(
            secondary: const Icon(Icons.numbers),
            title: const Text('Show Number Row'),
            subtitle: const Text('Display numbers above letters'),
            value: settings.showNumberRow,
            onChanged: (value) => notifier.setShowNumberRow(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.preview),
            title: const Text('Key Preview'),
            subtitle: const Text('Show popup when key is pressed'),
            value: settings.showPreview,
            onChanged: (value) => notifier.setShowPreview(value),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Default Language'),
            subtitle: Text(settings.defaultLanguage.displayName),
            trailing: DropdownButton<int>(
              value: settings.defaultLanguageIndex,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 0, child: Text('English')),
                DropdownMenuItem(value: 1, child: Text('हिंदी')),
                DropdownMenuItem(value: 2, child: Text('𑴎𑴟')),
              ],
              onChanged: (value) {
                if (value != null) notifier.setDefaultLanguage(value);
              },
            ),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Feedback', Icons.vibration),

          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on key press'),
            value: settings.hapticFeedback,
            onChanged: (value) => notifier.setHapticFeedback(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sound on Key Press'),
            subtitle: const Text('Play sound when typing'),
            value: settings.soundOnKeyPress,
            onChanged: (value) => notifier.setSoundOnKeyPress(value),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Suggestions', Icons.lightbulb_outline),

          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text('Show Suggestions'),
            subtitle: const Text('Display word suggestions while typing'),
            value: settings.showSuggestions,
            onChanged: (value) => notifier.setShowSuggestions(value),
          ),

          if (settings.showSuggestions)
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Suggestion Count'),
              subtitle: Text(
                'Show up to ${settings.suggestionCount} suggestions',
              ),
              trailing: DropdownButton<int>(
                value: settings.suggestionCount,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('3')),
                  DropdownMenuItem(value: 5, child: Text('5')),
                  DropdownMenuItem(value: 7, child: Text('7')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                ],
                onChanged: (value) {
                  if (value != null) notifier.setSuggestionCount(value);
                },
              ),
            ),

          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Custom Words'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomWordsScreen()),
              );
            },
          ),

          const Divider(),

          _buildSectionHeader(context, 'Advanced', Icons.settings_suggest),

          SwitchListTile(
            secondary: const Icon(Icons.text_fields),
            title: const Text('Auto-Capitalize'),
            subtitle: const Text('Capitalize first letter of sentences'),
            value: settings.autoCapitalize,
            onChanged: (value) => notifier.setAutoCapitalize(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.swipe),
            title: const Text('Swipe to Delete'),
            subtitle: const Text('Swipe left on backspace to delete faster'),
            value: settings.swipeToDelete,
            onChanged: (value) => notifier.setSwipeToDelete(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.keyboard_backspace_sharp),
            title: const Text('Long Press for Symbols'),
            subtitle: const Text('Hold keys to access alternate characters'),
            value: settings.longPressForSymbols,
            onChanged: (value) => notifier.setLongPressForSymbols(value),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.gesture),
            title: const Text('Glide Typing (Beta)'),
            subtitle: const Text('Swipe across keys to type'),
            value: settings.enableGlideTyping,
            onChanged: (value) => notifier.setEnableGlideTyping(value),
          ),

          const Divider(),

          _buildSectionHeader(context, 'Usage', Icons.analytics),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            subtitle: const Text('View your typing stats'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),

          const Divider(),

          _buildSectionHeader(context, 'About', Icons.info_outline),

          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),

          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text('Developer'),
            subtitle: Text('Hindi & Gondi Keyboard'),
          ),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Licenses'),
            subtitle: const Text('Open source licenses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Hindi Keyboard',
                applicationVersion: '1.0.0',
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all keyboard settings to default values. Custom words will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
