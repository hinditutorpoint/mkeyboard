import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'screens/text_editor_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/settings_screen.dart';
import 'keyboard/keyboard_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive in background
  try {
    await HiveService.init();
    debugPrint('✓ Hive initialized');
  } catch (e) {
    debugPrint('✗ Error initializing Hive: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

@pragma('vm:entry-point')
Future<void> imeMain() async {
  debugPrint('IME: Entry point started');

  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.ensureInitialized();
  // Start app after Hive is initialized
  debugPrint('IME: Starting app...');
  runApp(const ProviderScope(child: _ImeApp()));
  debugPrint('IME: ✓ App started');
}

class _ImeApp extends StatelessWidget {
  const _ImeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        canvasColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(alignment: Alignment.bottomCenter, child: KeyboardWidget()),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hindi & Gondi Keyboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'NotoSansDevanagari',
        fontFamilyFallback: const ['NotoSansMasaramGondi', 'Roboto'],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const HomeNavigator(),
    );
  }
}

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TextEditorScreen(),
    SetupScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit), label: 'Editor'),
          NavigationDestination(icon: Icon(Icons.keyboard), label: 'Keyboard'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Helper to avoid linting warnings
void unawaited(Future<void> future) {}
