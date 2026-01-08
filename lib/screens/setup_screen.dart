import 'package:flutter/material.dart';
import '../keyboard/keyboard_controller.dart';
import 'settings_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _isEnabled = false;
  bool _isSelected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkKeyboardStatus();
  }

  Future<void> _checkKeyboardStatus() async {
    setState(() => _isLoading = true);

    final enabled = await KeyboardController.isKeyboardEnabled();
    final selected = await KeyboardController.isKeyboardSelected();

    setState(() {
      _isEnabled = enabled;
      _isSelected = selected;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hindi & Gondi Keyboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkKeyboardStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              _isSelected
                                  ? Icons.check_circle
                                  : _isEnabled
                                  ? Icons.keyboard
                                  : Icons.warning,
                              size: 80,
                              color: _isSelected
                                  ? Colors.green
                                  : _isEnabled
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSelected
                                  ? '✓ Keyboard is Ready!'
                                  : _isEnabled
                                  ? 'Almost There!'
                                  : 'Setup Required',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSelected
                                  ? 'You can now use this keyboard in any app'
                                  : _isEnabled
                                  ? 'Select the keyboard to start using it'
                                  : 'Follow the steps below to enable the keyboard',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Features
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      Icons.language,
                      'Multiple Languages',
                      'English, हिंदी (Hindi), and 𑴎𑴟𑴤𑴦 (Gondi)',
                    ),
                    _buildFeatureCard(
                      Icons.auto_awesome,
                      'Smart Suggestions',
                      'Custom words with usage tracking',
                    ),
                    _buildFeatureCard(
                      Icons.palette,
                      'Beautiful Themes',
                      '7 stunning color themes to choose from',
                    ),
                    _buildFeatureCard(
                      Icons.settings,
                      'Highly Customizable',
                      'Adjust size, spacing, feedback, and more',
                    ),

                    const SizedBox(height: 32),

                    // Setup Steps
                    const Text(
                      'Setup Instructions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Step 1: Enable Keyboard
                    _buildSetupStep(
                      step: 1,
                      title: 'Enable Keyboard',
                      description:
                          'Go to Settings → System → Languages & Input → On-screen Keyboard → Manage Keyboards',
                      isCompleted: _isEnabled,
                      buttonText: 'Open Settings',
                      onTap: () async {
                        await KeyboardController.openKeyboardSettings();
                        Future.delayed(
                          const Duration(seconds: 1),
                          _checkKeyboardStatus,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Step 2: Select Keyboard
                    _buildSetupStep(
                      step: 2,
                      title: 'Select Keyboard',
                      description:
                          'Tap on any text field and choose "Hindi Keyboard" from the keyboard picker',
                      isCompleted: _isSelected,
                      isEnabled: _isEnabled,
                      buttonText: 'Select Keyboard',
                      onTap: () async {
                        await KeyboardController.openInputMethodPicker();
                        Future.delayed(
                          const Duration(seconds: 1),
                          _checkKeyboardStatus,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Step 3: Test
                    _buildSetupStep(
                      step: 3,
                      title: 'Test Keyboard',
                      description:
                          'Try typing in the field below to test the keyboard',
                      isCompleted: false,
                      isEnabled: _isSelected,
                      showButton: false,
                    ),

                    if (_isSelected) ...[
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Test your keyboard here',
                          hintText: 'Type "namaste" to see नमस्ते',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '💡 Tip: Tap the language key (हि/EN/𑴎𑴟) to switch between languages',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Refresh button
                    OutlinedButton.icon(
                      onPressed: _checkKeyboardStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    if (_isSelected) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Customize Keyboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildSetupStep({
    required int step,
    required String title,
    required String description,
    required bool isCompleted,
    bool isEnabled = true,
    bool showButton = true,
    String? buttonText,
    VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Card(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCompleted
                        ? Colors.green
                        : isEnabled
                        ? Colors.orange
                        : Colors.grey,
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white)
                        : Text(
                            step.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showButton && isEnabled) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    child: Text(isCompleted ? 'Change' : buttonText ?? 'Setup'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
