import 'package:flutter/material.dart';
import 'typing_help_screen.dart';

class HelpSelectScreen extends StatelessWidget {
  const HelpSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Select'), elevation: 0),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Hindi Typing Help'),
            subtitle: const Text('Learn how to type in Hindi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TypingHelpScreen(
                    title: 'Hindi Typing Help',
                    assetPath: 'assets/help/hindi.html',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Masaram Gondi Typing Help'),
            subtitle: const Text('Learn how to type in Masaram Gondi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TypingHelpScreen(
                    title: 'Masaram Gondi Typing Help',
                    assetPath: 'assets/help/masaram.html',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Gunjala Gondi Typing Help'),
            subtitle: const Text('Learn how to type in Gunjala Gondi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TypingHelpScreen(
                    title: 'Gunjala Gondi Typing Help',
                    assetPath: 'assets/help/gunjala.html',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('OI Chiki (Santhali) Typing Help'),
            subtitle: const Text('Learn how to type in OI Chiki (Santhali)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TypingHelpScreen(
                    title: 'OI Chiki (Santhali) Typing Help',
                    assetPath: 'assets/help/chiki.html',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
