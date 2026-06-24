import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumio/core/lumio_controller.dart';
import 'package:lumio/data/firebase_lumio_repository.dart';
import 'package:lumio/features/lumio_app.dart';

void main() {
  testWidgets('signing in transitions from auth screen to dashboard cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FirebaseLumioRepository(
      client: MockClient((request) async {
        if (request.method == 'GET') {
          return http.Response('{"error":"Permission denied"}', 401);
        }
        return http.Response('{}', 200);
      }),
    );
    final controller = LumioController(repository: repository);

    await tester.pumpWidget(LumioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(
      find.text('Use a Lumio account to open the correct workspace.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sign In').last);
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Matchmaking'), findsOneWidget);
  });
}
