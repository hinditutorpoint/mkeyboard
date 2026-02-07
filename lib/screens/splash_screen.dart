import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../main.dart'; // For HomeNavigator

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Minimum splash time (so it doesn't flicker)
    final minTime = Future.delayed(const Duration(milliseconds: 1500));

    // 2. Initialize Hive
    try {
      setState(() {
        _status = 'Loading database...';
        _progress = 0.3;
      });

      await HiveService.ensureInitialized();
      debugPrint('✓ Hive initialized in Splash');

      setState(() {
        _status = 'Preparing editor...';
        _progress = 0.8;
      });
    } catch (e) {
      debugPrint('✗ Error initializing Hive in Splash: $e');
      // Continue anyway, maybe show error?
      // For now, let's proceed so user isn't stuck.
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Initialization warning: $e')));
      }
    }

    // Wait for min time
    await minTime;

    setState(() => _progress = 1.0);

    // 3. Navigate to Home
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeNavigator()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.keyboard, size: 60, color: Colors.orange),
            ),
            const SizedBox(height: 32),

            // App Name
            const Text(
              'Hindi & Gondi Keyboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Editor & Settings',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 48),

            // Progress
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
