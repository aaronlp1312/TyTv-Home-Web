# Integration notes — where to wire the browser and favorites row

This file explains the small manual edits to integrate the prototype BrowserScreen and FavoritesRow into the existing ArcLauncher codebase. These edits are intentionally left as manual steps so you can review and adjust them in your development environment.

1) Add Browser import
---------------------
Open: lib/widgets/focus_aware_app_bar.dart and add near other imports:

import 'package:flauncher/browser.dart';

2) Add Browser button to the app bar
------------------------------------
Find the app bar action area in focus_aware_app_bar.dart and add an IconButton inside the actions list:

IconButton(
  icon: const Icon(Icons.web),
  tooltip: 'Browser',
  onPressed: () {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowserScreen()));
  },
),

Place this alongside other action buttons (settings, search, etc.). This makes the Browser available from the top app bar on every screen.

3) Add Favorites row to the home layout
---------------------------------------
Open: lib/flauncher.dart and add the FavoritesRow as a Sliver in _tvOSLayout. Example insertion (import the widget first):

import 'package:flauncher/widgets/favorites_row.dart';

Then inside the slivers list (for example just after the dock or favorites section):

SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: kLauncherSectionHorizontalPadding),
    child: FavoritesRow(),
  ),
),

Adjust position as you prefer (above or below watch-next / dock).

4) Update pubspec
-----------------
The repo root pubspec.yaml in this branch includes `webview_flutter: ^4.0.7`. Run `flutter pub get` after pulling the branch.

5) Pinning URLs & UI
--------------------
Use BrowserFavorites.addPinned(url) from BrowserScreen or a settings UI to let users add a pinned URL. The FavoritesRow reads pinned URLs from SharedPreferences and displays them.

6) Building & testing
---------------------
- On your development device (older/higher-powered), run `flutter pub get`, then `flutter run` targeting an Android TV device or emulator.
- To produce an APK: `flutter build apk --release` and install via adb on your TV.

License
-------
This fork keeps the original GPLv3 license. Any changes remain under GPLv3.

If you want me to apply these edits automatically in this repository (modify focus_aware_app_bar.dart and flauncher.dart), I can do that and push a follow-up commit — tell me and I will make the edits and push to branch tv-browser.