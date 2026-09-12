*** Begin Patch
*** Update File: lib/flauncher.dart
@@
-import 'models/app.dart';
-import 'models/category.dart';
+import 'models/app.dart';
+import 'models/category.dart';
+import 'package:flauncher/widgets/favorites_row.dart';
@@
-          if (favoriteApps.isNotEmpty)
-            SliverToBoxAdapter(
-              child: KeyedSubtree(
-                key: _dockKey,
-                child: Padding(
-                  padding: _kDockOuterPadding,
-                  child: _dock(
-                    context,
-                    favoritesCategory!,
-                    favoriteApps,
-                    appsService,
-                    handleUpNavigationToSettings: !reserveWatchNextSpace,
-                  ),
-                ),
-              ),
-            ),
+          if (favoriteApps.isNotEmpty)
+            SliverToBoxAdapter(
+              child: KeyedSubtree(
+                key: _dockKey,
+                child: Padding(
+                  padding: _kDockOuterPadding,
+                  child: _dock(
+                    context,
+                    favoritesCategory!,
+                    favoriteApps,
+                    appsService,
+                    handleUpNavigationToSettings: !reserveWatchNextSpace,
+                  ),
+                ),
+              ),
+            ),
+          // FavoritesRow: pinned web shortcuts (TV browser)
+          SliverToBoxAdapter(
+            child: Padding(
+              padding: const EdgeInsets.symmetric(horizontal: kLauncherSectionHorizontalPadding),
+              child: FavoritesRow(),
+            ),
+          ),
*** End Patch