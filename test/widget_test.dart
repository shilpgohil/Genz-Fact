import 'package:flutter_test/flutter_test.dart';
import 'package:luma/app/luma_app.dart';
import 'package:luma/models/app_models.dart';
import 'package:luma/services/library_controller.dart';
import 'package:luma/services/selection_controller.dart';
import 'package:luma/services/settings_store.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_media_library.dart';
import 'helpers/media_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows permission copy when access is missing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsStore(prefs)..load();
    final library = LibraryController(
      library: FakeMediaLibrary(permission: LumaPermission.notDetermined),
      settings: settings,
    );

    await tester.pumpWidget(
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
    await tester.pumpAndSettle();
    expect(find.textContaining('Allow photo access'), findsOneWidget);
    library.dispose();
  });

  testWidgets('ready library shows Home wordmark', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsStore(prefs)..load();
    final library = LibraryController(
      library: FakeMediaLibrary(
        assets: [
          sampleAsset(id: '1', createdAt: DateTime(2025, 8, 18, 19)),
          sampleAsset(id: '2', createdAt: DateTime(2025, 8, 18, 19, 10)),
          sampleAsset(id: '3', createdAt: DateTime(2025, 8, 18, 19, 20)),
        ],
      ),
      settings: settings,
    );

    await tester.pumpWidget(
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
    await tester.pumpAndSettle();
    expect(find.text('Luma'), findsWidgets);
    expect(find.text('Moments'), findsOneWidget);
    library.dispose();
  });
}
