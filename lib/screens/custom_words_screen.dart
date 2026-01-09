import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/custom_word.dart';
import '../models/keyboard_language.dart';
import '../providers/settings_provider.dart';

class CustomWordsScreen extends ConsumerStatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  ConsumerState<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends ConsumerState<CustomWordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customWordsNotifier = ref.read(customWordsProvider.notifier);
    final allWords = ref.watch(allCustomWordsProvider);
    final hindiWords = ref.watch(customWordsByLanguageProvider(1));
    final gondiWords = ref.watch(customWordsByLanguageProvider(2));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Words'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.list), text: 'All (${allWords.length})'),
            Tab(
              icon: const Icon(Icons.abc),
              text: 'Hindi (${hindiWords.length})',
            ),
            Tab(
              icon: const Text('𑴎𑴟', style: TextStyle(fontSize: 20)),
              text: 'Gondi (${gondiWords.length})',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(value, customWordsNotifier),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add Word'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWordList(ref, null),
                _buildWordList(ref, 1), // Hindi
                _buildWordList(ref, 2), // Gondi
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, customWordsNotifier),
        icon: const Icon(Icons.add),
        label: const Text('Add Word'),
      ),
    );
  }

  Widget _buildWordList(WidgetRef ref, int? languageIndex) {
    List<CustomWord> words;

    if (_searchQuery.isEmpty) {
      if (languageIndex == null) {
        words = ref.watch(allCustomWordsProvider);
      } else {
        words = ref.watch(customWordsByLanguageProvider(languageIndex));
      }
    } else {
      words = ref.watch(
        searchCustomWordsProvider((_searchQuery, languageIndex)),
      );
    }

    if (words.isEmpty) {
      return _buildEmptyState(languageIndex);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final customWordsNotifier = ref.read(customWordsProvider.notifier);
        return _buildWordCard(words[index], customWordsNotifier);
      },
    );
  }

  Widget _buildEmptyState(int? languageIndex) {
    String message = 'No custom words yet';
    if (_searchQuery.isNotEmpty) {
      message = 'No results found for "$_searchQuery"';
    }

    final customWordsNotifier = ref.read(customWordsProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(
                context,
                customWordsNotifier,
                defaultLanguageIndex: languageIndex,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add First Word'),
            ),
        ],
      ),
    );
  }

  Widget _buildWordCard(
    CustomWord word,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    final theme = Theme.of(context);
    final language = KeyboardLanguage.values[word.languageIndex];
    final fontFamily = language.fontFamily;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: word.isPinned
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: word.isPinned
              ? Icon(Icons.push_pin, color: theme.colorScheme.primary)
              : Text(
                  word.englishWord[0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
        ),
        title: Text(word.englishWord),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.translatedWord,
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamily,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${word.usageCount} uses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      language.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            final customWordsNotifier = ref.read(customWordsProvider.notifier);
            switch (value) {
              case 'pin':
                customWordsNotifier.togglePinned(word);
                break;
              case 'edit':
                _showEditDialog(context, word, customWordsNotifier);
                break;
              case 'delete':
                _showDeleteDialog(context, word, customWordsNotifier);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: Row(
                children: [
                  Icon(
                    word.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  ),
                  const SizedBox(width: 8),
                  Text(word.isPinned ? 'Unpin' : 'Pin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _handleMenuAction(
    String action,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    switch (action) {
      case 'add':
        _showAddDialog(context, notifier);
        break;
      case 'import':
        _showImportDialog(context, notifier);
        break;
      case 'export':
        _showExportDialog(context, notifier);
        break;
      case 'clear':
        _showClearDialog(context, notifier);
        break;
    }
  }

  void _showAddDialog(
    BuildContext context,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier, {
    int? defaultLanguageIndex,
  }) {
    final englishController = TextEditingController();
    final translatedController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int selectedLanguage = defaultLanguageIndex ?? 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final language = KeyboardLanguage.values[selectedLanguage];

          return AlertDialog(
            title: const Text('Add Custom Word'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('हिंदी (Hindi)'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('𑴎𑴟𑴤𑴦 (Gondi)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedLanguage = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: englishController,
                      decoration: const InputDecoration(
                        labelText: 'English Word/Phrase',
                        hintText: 'e.g., namaste',
                        prefixIcon: Icon(Icons.abc),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter English text';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: translatedController,
                      decoration: InputDecoration(
                        labelText: '${language.displayName} Translation',
                        hintText: language == KeyboardLanguage.hindi
                            ? 'e.g., नमस्ते'
                            : 'e.g., 𑴕𑴽𑴎𑴦𑴢',
                        prefixIcon: const Icon(Icons.translate),
                      ),
                      style: TextStyle(
                        fontFamily: language.fontFamily,
                        fontSize: 18,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter translation';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final customWordsNotifier = notifier as CustomWordsNotifier;
                    final success = await customWordsNotifier.addCustomWord(
                      englishController.text,
                      translatedController.text,
                      selectedLanguage,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Word added successfully'
                                : 'Word already exists',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    CustomWord word,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    final englishController = TextEditingController(text: word.englishWord);
    final translatedController = TextEditingController(
      text: word.translatedWord,
    );
    final formKey = GlobalKey<FormState>();
    final language = KeyboardLanguage.values[word.languageIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Custom Word'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: englishController,
                decoration: const InputDecoration(
                  labelText: 'English Word/Phrase',
                  prefixIcon: Icon(Icons.abc),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter English text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: translatedController,
                decoration: InputDecoration(
                  labelText: '${language.displayName} Translation',
                  prefixIcon: const Icon(Icons.translate),
                ),
                style: TextStyle(fontFamily: language.fontFamily, fontSize: 18),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter translation';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final customWordsNotifier = notifier as CustomWordsNotifier;
                customWordsNotifier.updateCustomWord(
                  word,
                  englishController.text,
                  translatedController.text,
                );
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Word updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CustomWord word,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Word'),
        content: Text('Delete "${word.englishWord} → ${word.translatedWord}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final customWordsNotifier = notifier as CustomWordsNotifier;
              customWordsNotifier.deleteCustomWord(word);
              Navigator.pop(context);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Word deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(
    BuildContext context,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Words'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Format: english=translation|language\nLanguage: 1=Hindi, 2=Gondi\n\nExample:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'namaste=नमस्ते|1\njokhar=𑴕𑴽𑴎𑴦𑴢|2',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final lines = controller.text.split('\n');
              int imported = 0;
              final customWordsNotifier = notifier as CustomWordsNotifier;

              for (var line in lines) {
                if (line.contains('=') && line.contains('|')) {
                  final parts = line.split('|');
                  if (parts.length == 2) {
                    final wordParts = parts[0].split('=');
                    final languageIndex = int.tryParse(parts[1].trim());

                    if (wordParts.length == 2 && languageIndex != null) {
                      final success = await customWordsNotifier.addCustomWord(
                        wordParts[0].trim(),
                        wordParts[1].trim(),
                        languageIndex,
                      );
                      if (success) imported++;
                    }
                  }
                }
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Imported $imported words')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(
    BuildContext context,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    final customWordsNotifier = notifier as CustomWordsNotifier;
    final words = customWordsNotifier.getAllWords();
    final exportText = words
        .map((w) => '${w.englishWord}=${w.translatedWord}|${w.languageIndex}')
        .join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Words'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Copy the text below:'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(child: SelectableText(exportText)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(
    BuildContext context,
    StateNotifier<AsyncValue<List<CustomWord>>> notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Words'),
        content: const Text(
          'This will delete ALL custom words. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final customWordsNotifier = notifier as CustomWordsNotifier;
              customWordsNotifier.clearAll();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All words cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
