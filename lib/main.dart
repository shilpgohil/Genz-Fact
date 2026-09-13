import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/luma_app.dart';
import 'services/create_media_library.dart';
import 'services/library_controller.dart';
import 'services/selection_controller.dart';
import 'services/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStore(prefs)..load();
  final library = LibraryController(
    library: createMediaLibrary(),
    settings: settings,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => SelectionController()),
        ChangeNotifierProvider.value(value: library),
      ],
      child: const LumaApp(),
    ),
  );
  await library.start();
}
