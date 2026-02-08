import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mkeyboard/screens/help_select_screen.dart';
import 'screens/text_editor_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't await Hive here, let SplashScreen do it to avoid white screen
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hindi & Gondi Keyboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBF360C),
        ), // Terracotta
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Light Beige
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFBF360C),
          foregroundColor: Colors.white,
        ),
        listTileTheme: const ListTileThemeData(iconColor: Color(0xFFBF360C)),
        fontFamily: 'NotoSansDevanagari',
        fontFamilyFallback: const [
          'NotoSansMasaramGondi',
          'NotoSansGunjalaGondi',
          'Roboto',
        ],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFBF360C),
        ),
      ),
      // Start with Splash to init DB
      home: const SplashScreen(),
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
    HelpSelectScreen(),
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
          NavigationDestination(icon: Icon(Icons.info), label: 'Typing Help'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Helper to avoid linting warnings
void unawaited(Future<void> future) {}
