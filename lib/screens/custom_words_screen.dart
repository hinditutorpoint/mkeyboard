import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/custom_word.dart';
import '../models/keyboard_language.dart';

class CustomWordsScreen extends StatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  State<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends State<CustomWordsScreen>
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
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Custom Words'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.list),
                  text: 'All (${provider.getAllCustomWords().length})',
                ),
                Tab(
                  icon: const Icon(Icons.abc),
                  text:
                      'Hindi (${provider.getCustomWordsByLanguage(1).length})',
                ),
                Tab(
                  icon: const Text('𑴎𑴟', style: TextStyle(fontSize: 20)),
                  text:
                      'Gondi (${provider.getCustomWordsByLanguage(2).length})',
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, provider),
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
                    _buildWordList(provider, null),
                    _buildWordList(provider, 1), // Hindi
                    _buildWordList(provider, 2), // Gondi
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Add Word'),
          ),
        );
      },
    );
  }

  Widget _buildWordList(SettingsProvider provider, int? languageIndex) {
    List<CustomWord> words;

    if (_searchQuery.isEmpty) {
      words = languageIndex == null
          ? provider.getAllCustomWords()
          : provider.getCustomWordsByLanguage(languageIndex);
    } else {
      words = provider.searchCustomWords(
        _searchQuery,
        languageIndex: languageIndex,
      );
    }

    if (words.isEmpty) {
      return _buildEmptyState(languageIndex);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        return _buildWordCard(words[index], provider);
      },
    );
  }

  Widget _buildEmptyState(int? languageIndex) {
    String message = 'No custom words yet';
    if (_searchQuery.isNotEmpty) {
      message = 'No results found for "$_searchQuery"';
    }

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
                context.read<SettingsProvider>(),
                defaultLanguageIndex: languageIndex,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add First Word'),
            ),
        ],
      ),
    );
  }

  Widget _buildWordCard(CustomWord word, SettingsProvider provider) {
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
            switch (value) {
              case 'pin':
                provider.togglePinned(word);
                break;
              case 'edit':
                _showEditDialog(context, word, provider);
                break;
              case 'delete':
                _showDeleteDialog(context, word, provider);
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

  void _handleMenuAction(String action, SettingsProvider provider) {
    switch (action) {
      case 'add':
        _showAddDialog(context, provider);
        break;
      case 'import':
        _showImportDialog(context, provider);
        break;
      case 'export':
        _showExportDialog(context, provider);
        break;
      case 'clear':
        _showClearDialog(context, provider);
        break;
    }
  }

  void _showAddDialog(
    BuildContext context,
    SettingsProvider provider, {
    int? defaultLanguageIndex,
  }) {
    final englishController = TextEditingController();
    final translatedController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int selectedLanguage = defaultLanguageIndex ?? 1; // Default to Hindi

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
                    // Language selector
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

                    // English word
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

                    // Translated word
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
                    final success = await provider.addCustomWord(
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
    SettingsProvider provider,
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
                provider.updateCustomWord(
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
    SettingsProvider provider,
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
              provider.deleteCustomWord(word);
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

  void _showImportDialog(BuildContext context, SettingsProvider provider) {
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

              for (var line in lines) {
                if (line.contains('=') && line.contains('|')) {
                  final parts = line.split('|');
                  if (parts.length == 2) {
                    final wordParts = parts[0].split('=');
                    final languageIndex = int.tryParse(parts[1].trim());

                    if (wordParts.length == 2 && languageIndex != null) {
                      final success = await provider.addCustomWord(
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

  void _showExportDialog(BuildContext context, SettingsProvider provider) {
    final words = provider.getAllCustomWords();
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

  void _showClearDialog(BuildContext context, SettingsProvider provider) {
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
              provider.clearAllCustomWords();
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
