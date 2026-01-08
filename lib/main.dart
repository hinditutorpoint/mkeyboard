import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'providers/settings_provider.dart';
import 'screens/text_editor_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/settings_screen.dart';
import 'keyboard/keyboard_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> imeMain() async {
  debugPrint('IME: Entry point imeMain started');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('IME: WidgetsFlutterBinding initialized');
    await HiveService.init();
    debugPrint('IME: HiveService initialized');
    runApp(const _ImeApp());
    debugPrint('IME: runApp called');
  } catch (e, stack) {
    debugPrint('IME: Critical error in imeMain: $e\n$stack');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Init Error: $e'))),
      ),
    );
  }
}

class _ImeApp extends StatelessWidget {
  const _ImeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Ensure no material components inject background colors
        canvasColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent, // Crucial
        body: Builder(
          builder: (context) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                child: KeyboardWidget(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: MaterialApp(
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
          fontFamily: 'NotoSansDevanagari',
          fontFamilyFallback: const ['NotoSansMasaramGondi', 'Roboto'],
        ),
        home: const HomeNavigator(),
      ),
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

  final List<Widget> _screens = [
    const TextEditorScreen(),
    const SetupScreen(),
    const SettingsScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.edit),
            selectedIcon: Icon(Icons.edit),
            label: 'Editor',
          ),
          NavigationDestination(
            icon: Icon(Icons.keyboard),
            selectedIcon: Icon(Icons.keyboard),
            label: 'Keyboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
