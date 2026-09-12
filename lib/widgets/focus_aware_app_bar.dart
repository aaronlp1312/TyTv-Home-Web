*** Begin Patch
*** Update File: lib/widgets/focus_aware_app_bar.dart
@@
-import 'package:flauncher/l10n/app_localizations.dart';
+import 'package:flauncher/l10n/app_localizations.dart';
+import 'package:flauncher/browser.dart';
@@
-              ,
+              ,
+              IconButton(
+                icon: const Icon(Icons.web),
+                tooltip: 'Browser',
+                onPressed: () {
+                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => BrowserScreen()));
+                },
+              ),
*** End Patch