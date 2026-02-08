import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TypingHelpScreen extends StatefulWidget {
  final String title;
  final String assetPath;

  const TypingHelpScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<TypingHelpScreen> createState() => _TypingHelpScreenState();
}

class _TypingHelpScreenState extends State<TypingHelpScreen> {
  late final WebViewController _controller;
  bool _canGoBack = false;
  bool _canGoForward = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              final canBack = await _controller.canGoBack();
              final canFwd = await _controller.canGoForward();
              setState(() {
                _progress = 0; // Hide progress bar when done
                _canGoBack = canBack;
                _canGoForward = canFwd;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
    _initWebView();
  }

  Future<void> _initWebView() async {
    await _controller.loadFlutterAsset(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    // If we can go back in WebView, hijack the back button.
    // Otherwise, let the system handle it (pop the screen).
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
          bottom: _progress > 0 && _progress < 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2.0),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 2.0,
                    backgroundColor: Colors.transparent,
                  ),
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _canGoBack
                  ? () async {
                      if (await _controller.canGoBack()) {
                        await _controller.goBack();
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _canGoForward
                  ? () async {
                      if (await _controller.canGoForward()) {
                        await _controller.goForward();
                      }
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
