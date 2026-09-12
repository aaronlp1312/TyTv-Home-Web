import 'package:flutter/material.dart';
import 'package:flauncher/browser.dart';
import 'package:flauncher/browser_favorites.dart';

class FavoritesRow extends StatefulWidget {
  const FavoritesRow({Key? key}) : super(key: key);

  @override
  State<FavoritesRow> createState() => _FavoritesRowState();
}

class _FavoritesRowState extends State<FavoritesRow> {
  List<PinnedItem> _pinned = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await BrowserFavorites.getPinned();
    setState(() => _pinned = p);
  }

  @override
  Widget build(BuildContext context) {
    if (_pinned.isEmpty) {
      return SizedBox.shrink();
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          final item = _pinned[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowserScreen(initialUrl: item.url)));
            },
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _faviconWidget(item.favicon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title.isNotEmpty ? item.title : item.url,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.url,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: _pinned.length,
      ),
    );
  }

  Widget _faviconWidget(String favicon) {
    if (favicon.isEmpty) {
      return const Icon(Icons.language, size: 48, color: Colors.white);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        favicon,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 48, color: Colors.white),
      ),
    );
  }
}
