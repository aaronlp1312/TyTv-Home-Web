import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:flauncher/browser_favorites.dart';

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

  String? _currentTitle;
  String? _currentFavicon;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          setState(() => _isLoading = false);
          // try to extract page title and favicon
          try {
            final titleResult = await _controller.runJavaScriptReturningResult('document.title');
            if (titleResult != null) {
              // the returned value may be a quoted string or plain
              final t = titleResult.toString().replaceAll('"', '');
              setState(() => _currentTitle = t);
            }
          } catch (_) {}

          try {
            final favResult = await _controller.runJavaScriptReturningResult("(function(){var i=document.querySelector('link[rel~\\\"icon\\\"], link[rel=\\\"shortcut icon\\\"], link[rel=\\\"apple-touch-icon\\\"]'); if(i) return i.href; return '';})()");
            if (favResult != null) {
              final f = favResult.toString().replaceAll('"', '');
              if (f.isNotEmpty) setState(() => _currentFavicon = f);
            }
          } catch (_) {}

          // Save the finished URL into recents
          try {
            final current = await _controller.currentUrl();
            if (current != null && current.isNotEmpty) {
              BrowserFavorites.addRecent(current);
            }
          } catch (_) {}
        },
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

  Future<void> _pinCurrentPage() async {
    try {
      final current = await _controller.currentUrl();
      if (current == null || current.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No page to pin')));
        return;
      }
      final title = _currentTitle ?? current;
      final favicon = _currentFavicon ?? '';
      final item = PinnedItem(url: current, title: title, favicon: favicon);
      await BrowserFavorites.addPinnedObject(item);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pinned')));
      // optionally update a global state or notify favorites row; it reads from prefs on build
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pin failed: $e')));
    }
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
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              hintText: 'Enter URL',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _goToUrl(_urlController.text.trim()),
              ),
            ),
            onSubmitted: (v) => _goToUrl(v.trim()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin),
            tooltip: 'Pin this page',
            onPressed: _pinCurrentPage,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _controller.goBack(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
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
