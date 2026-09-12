import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PinnedItem {
  final String url;
  final String title;
  final String favicon; // absolute URL or empty

  PinnedItem({required this.url, required this.title, required this.favicon});

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'favicon': favicon,
      };

  static PinnedItem fromJson(Map<String, dynamic> json) => PinnedItem(
        url: json['url'] as String? ?? '',
        title: json['title'] as String? ?? '',
        favicon: json['favicon'] as String? ?? '',
      );

  @override
  String toString() => jsonEncode(toJson());
}

class BrowserFavorites {
  static const _pinnedKey = 'tytv_pinned_urls';
  static const _recentsKey = 'tytv_recents';

  // pinned stored as JSON strings
  static Future<List<PinnedItem>> getPinned() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pinnedKey) ?? [];
    return raw.map((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return PinnedItem.fromJson(m);
      } catch (_) {
        return PinnedItem(url: s, title: s, favicon: '');
      }
    }).toList();
  }

  static Future<void> setPinnedObjects(List<PinnedItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = items.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList(_pinnedKey, raw);
  }

  static Future<void> addPinnedObject(PinnedItem item) async {
    final list = await getPinned();
    list.removeWhere((i) => i.url == item.url);
    list.insert(0, item);
    if (list.length > 20) list.removeRange(20, list.length);
    await setPinnedObjects(list);
  }

  static Future<void> removePinned(String url) async {
    final list = await getPinned();
    list.removeWhere((i) => i.url == url);
    await setPinnedObjects(list);
  }

  // recents (as plain URLs)
  static Future<List<String>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentsKey) ?? [];
  }

  static Future<void> addRecent(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final recents = prefs.getStringList(_recentsKey) ?? [];
    recents.remove(url);
    recents.insert(0, url);
    if (recents.length > 20) recents.removeLast();
    await prefs.setStringList(_recentsKey, recents);
  }
}
