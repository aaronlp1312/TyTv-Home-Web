import 'package:flutter/material.dart';
import 'package:flauncher/browser.dart';
import 'package:flauncher/browser_favorites.dart';

class FavoritesRow extends StatefulWidget {
  const FavoritesRow({Key? key}) : super(key: key);

  @override
  State<FavoritesRow> createState() => _FavoritesRowState();
}

class _FavoritesRowState extends State<FavoritesRow> {
  List<String> _pinned = [];

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
          final url = _pinned[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowserScreen(initialUrl: url)));
            },
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.language, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    url,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
}
