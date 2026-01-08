import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _totalKeyPresses = 0;
  Map<String, int> _topKeys = {};
  List<Map<String, dynamic>> _wordStats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _totalKeyPresses = HiveService.getTotalKeyPresses();
      _topKeys = HiveService.getTopKeys(limit: 10);
      _wordStats = _getWordStatistics();
    });
  }

  List<Map<String, dynamic>> _getWordStatistics() {
    final words = HiveService.getAllCustomWords();

    // Calculate statistics
    final hindiWords = words.where((w) => w.languageIndex == 1).length;
    final gondiWords = words.where((w) => w.languageIndex == 2).length;
    final pinnedWords = words.where((w) => w.isPinned).length;

    // Most used words
    final sortedByUsage = words.toList()
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

    final mostUsed = sortedByUsage.take(10).toList();

    return [
      {
        'totalWords': words.length,
        'hindiWords': hindiWords,
        'gondiWords': gondiWords,
        'pinnedWords': pinnedWords,
        'mostUsed': mostUsed,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wordData = _wordStats.isNotEmpty ? _wordStats[0] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Overview',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildStatRow(
                      'Total Key Presses',
                      _totalKeyPresses.toString(),
                      Icons.keyboard,
                      theme,
                    ),
                    if (wordData != null) ...[
                      _buildStatRow(
                        'Custom Words',
                        wordData['totalWords'].toString(),
                        Icons.library_books,
                        theme,
                      ),
                      _buildStatRow(
                        'Hindi Words',
                        wordData['hindiWords'].toString(),
                        Icons.translate,
                        theme,
                      ),
                      _buildStatRow(
                        'Gondi Words',
                        wordData['gondiWords'].toString(),
                        Icons.language,
                        theme,
                      ),
                      _buildStatRow(
                        'Pinned Words',
                        wordData['pinnedWords'].toString(),
                        Icons.push_pin,
                        theme,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Top Keys
            if (_topKeys.isNotEmpty) ...[
              Text(
                'Most Pressed Keys',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _topKeys.entries.map((entry) {
                      final maxValue = _topKeys.values.reduce(math.max);
                      final percentage = (entry.value / maxValue * 100).round();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.value} times',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 8,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Most Used Words
            if (wordData != null && wordData['mostUsed'].isNotEmpty) ...[
              Text(
                'Most Used Custom Words',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...wordData['mostUsed'].map<Widget>((word) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        word.usageCount.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(word.englishWord),
                    subtitle: Text(
                      word.translatedWord,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: word.languageIndex == 1
                            ? 'NotoSansDevanagari'
                            : 'NotoSansMasaramGondi',
                      ),
                    ),
                    trailing: Text(
                      '${word.usageCount} uses',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 24),

            // Insights
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Insights',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (wordData != null) ...[
                      _buildInsight(_getInsightMessage(wordData), theme),
                    ] else
                      _buildInsight(
                        'Start using the keyboard to see insights!',
                        theme,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsight(String message, ThemeData theme) {
    return Text(
      message,
      style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
    );
  }

  String _getInsightMessage(Map<String, dynamic> data) {
    final totalWords = data['totalWords'] as int;
    final hindiWords = data['hindiWords'] as int;
    final gondiWords = data['gondiWords'] as int;
    final pinnedWords = data['pinnedWords'] as int;

    if (totalWords == 0) {
      return 'Add custom words to improve your typing experience!';
    } else if (totalWords < 10) {
      return 'You have $totalWords custom words. Add more to get better suggestions!';
    } else if (hindiWords > gondiWords * 2) {
      return 'You use Hindi more than Gondi. Consider adding more Gondi words!';
    } else if (pinnedWords == 0) {
      return 'Pin your favorite words for quick access!';
    } else if (_totalKeyPresses > 1000) {
      return 'Wow! You\'ve pressed $_totalKeyPresses keys. You\'re a power user! 🎉';
    } else {
      return 'Great job! Keep typing to improve your keyboard experience.';
    }
  }
}
