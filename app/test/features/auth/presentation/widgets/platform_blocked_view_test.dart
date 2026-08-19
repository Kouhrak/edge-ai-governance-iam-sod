import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edge_ai_iam_sod/features/auth/presentation/widgets/platform_blocked_view.dart';

void main() {
  group('PlatformBlockedView', () {
    testWidgets('shows username and denial message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlatformBlockedView(
            username: 'admin_principal',
            message:
                'Acceso denegado: su rol no está autorizado en la plataforma mobile.',
            onLogout: () {},
          ),
        ),
      );

      expect(find.text('admin_principal'), findsOneWidget);
      expect(
        find.text(
          'Acceso denegado: su rol no está autorizado en la plataforma mobile.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('fires onLogout when logout button is tapped', (WidgetTester tester) async {
      var loggedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PlatformBlockedView(
            username: 'admin_principal',
            message: 'Acceso denegado',
            onLogout: () => loggedOut = true,
          ),
        ),
      );

      await tester.tap(find.text('Cerrar Sesión'));
      await tester.pump();

      expect(loggedOut, isTrue);
    });
  });
}