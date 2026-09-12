import 'package:shared_preferences/shared_preferences.dart';

class BrowserFavorites {
  static const _pinnedKey = 'tytv_pinned_urls';
  static const _recentsKey = 'tytv_recents';

  static Future<List<String>> getPinned() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pinnedKey) ?? [];
  }

  static Future<void> setPinned(List<String> urls) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedKey, urls);
  }

  static Future<void> addPinned(String url) async {
    final list = await getPinned();
    list.remove(url);
    list.insert(0, url);
    await setPinned(list);
  }

  static Future<void> removePinned(String url) async {
    final list = await getPinned();
    list.remove(url);
    await setPinned(list);
  }

  static Future<List<String>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentsKey) ?? [];
  }

  static Future<void> addRecent(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final recents = prefs.getStringList(_recentsKey) ?? [];
    recents.remove(url);
    recents.insert(0, url);
    if (recents.length > 10) recents.removeLast();
    await prefs.setStringList(_recentsKey, recents);
  }
}
