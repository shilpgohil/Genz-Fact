import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luma/core/theme/luma_theme.dart';
import 'package:luma/models/app_models.dart';
import 'package:luma/widgets/empty_state.dart';
import 'package:luma/widgets/permission_panel.dart';
import 'package:luma/widgets/search_field.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: lumaTheme(brightness: Brightness.dark),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('empty state shows title and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        EmptyState(
          title: 'No photos yet',
          message: 'Grant access to begin.',
          actionLabel: 'Allow',
          onAction: () => tapped = true,
        ),
      ),
    );
    expect(find.text('No photos yet'), findsOneWidget);
    await tester.tap(find.text('Allow'));
    expect(tapped, isTrue);
  });

  testWidgets('permission panel explains local-only access', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PermissionPanel(
          permission: LumaPermission.notDetermined,
          onAllow: () {},
        ),
      ),
    );
    expect(find.textContaining('never leave the device'), findsOneWidget);
    expect(find.text('Allow photo access'), findsOneWidget);
  });

  testWidgets('permission panel explains browser session library', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PermissionPanel(
          permission: LumaPermission.notDetermined,
          accessMode: LibraryAccessMode.session,
          onAllow: () {},
        ),
      ),
    );
    expect(find.text('Choose photos'), findsOneWidget);
    expect(find.textContaining('never uploads'), findsOneWidget);
  });

  testWidgets('search field accepts input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(LumaSearchField(controller: controller)));
    await tester.enterText(find.byType(TextField), 'August');
    expect(controller.text, 'August');
  });
}
