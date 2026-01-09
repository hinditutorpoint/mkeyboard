import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/keyboard_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/keyboard_preview.dart';

class ThemeSelectorScreen extends ConsumerStatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  ConsumerState<ThemeSelectorScreen> createState() =>
      _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends ConsumerState<ThemeSelectorScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final currentTheme = ref.read(settingsProvider).themeName;
    _selectedIndex = KeyboardTheme.allThemes.indexWhere(
      (theme) => theme.name == currentTheme,
    );
    if (_selectedIndex == -1) _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Themes'),
        actions: [
          TextButton(
            onPressed: () {
              final selectedTheme = KeyboardTheme.allThemes[_selectedIndex];
              // ✅ Update via Riverpod
              ref
                  .read(settingsProvider.notifier)
                  .setThemeName(selectedTheme.name);
              Navigator.pop(context);
            },
            child: const Text('APPLY'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            color: Colors.grey[200],
            child: Center(
              child: KeyboardPreview(
                theme: KeyboardTheme.allThemes[_selectedIndex],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            KeyboardTheme.allThemes[_selectedIndex].name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorChip(
                  'Background',
                  KeyboardTheme.allThemes[_selectedIndex].backgroundColor,
                ),
                const SizedBox(width: 12),
                _buildColorChip(
                  'Keys',
                  KeyboardTheme.allThemes[_selectedIndex].keyColor,
                ),
                const SizedBox(width: 12),
                _buildColorChip(
                  'Accent',
                  KeyboardTheme.allThemes[_selectedIndex].accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: KeyboardTheme.allThemes.length,
              itemBuilder: (context, index) {
                final theme = KeyboardTheme.allThemes[index];
                final isSelected = _selectedIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: theme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: theme.keyColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildMiniColorCircle(
                                      theme.backgroundColor,
                                    ),
                                    _buildMiniColorCircle(theme.keyColor),
                                    _buildMiniColorCircle(theme.accentColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            )
                          else
                            const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMiniColorCircle(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
    );
  }
}
