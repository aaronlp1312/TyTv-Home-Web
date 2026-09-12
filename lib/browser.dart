import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowserScreen extends StatefulWidget {
  final String? initialUrl;
  const BrowserScreen({Key? key, this.initialUrl}) : super(key: key);

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
        onPageStarted: (_) => setState(() => _isLoading = true),
      ));

    final startUrl = widget.initialUrl ?? 'https://www.google.com';
    _urlController.text = startUrl;
    _controller.loadRequest(Uri.parse(startUrl));
  }

  Future<void> _saveRecent(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final recents = prefs.getStringList('tytv_recents') ?? [];
    recents.remove(url);
    recents.insert(0, url);
    if (recents.length > 10) recents.removeLast();
    await prefs.setStringList('tytv_recents', recents);
  }

  void _goToUrl(String url) {
    final uri = Uri.tryParse(url);
    final target = (uri != null && uri.scheme.isNotEmpty) ? url : 'https://$url';
    _controller.loadRequest(Uri.parse(target));
    _saveRecent(target);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Focus(
          child: TextField(
            controller: _urlController,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText: 'Enter URL',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _goToUrl(_urlController.text.trim()),
              ),
            ),
            onSubmitted: (v) => _goToUrl(v.trim()),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => _controller.goBack(),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () => _controller.goForward(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
