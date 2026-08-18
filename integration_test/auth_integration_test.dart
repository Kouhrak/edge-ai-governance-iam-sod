import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:edge_ai_governance_iam_sod/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    testWidgets('complete login flow', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Navigate to login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byKey(Key('username_field')), 'test_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Assert - Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome, test_user'), findsOneWidget);
    });

    testWidgets('logout flow', (WidgetTester tester) async {
      // Arrange - Login first
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username_field')), 'test_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Act - Logout
      await tester.tap(find.byKey(Key('logout_button')));
      await tester.pumpAndSettle();

      // Assert - Should return to login
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('role-based access control', (WidgetTester tester) async {
      // Arrange - Login as different roles
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Test as Tecnico
      await tester.enterText(find.byKey(Key('username_field')), 'tecnico_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Assert - Tecnico should see Loader but not Studio admin
      expect(find.text('Loader'), findsOneWidget);
      expect(find.text('Studio Admin'), findsNothing);

      // Logout
      await tester.tap(find.byKey(Key('logout_button')));
      await tester.pumpAndSettle();

      // Test as Administrador
      await tester.enterText(find.byKey(Key('username_field')), 'admin_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Assert - Administrador should see both
      expect(find.text('Loader'), findsOneWidget);
      expect(find.text('Studio Admin'), findsOneWidget);
    });
  });

  group('SoD Validation Integration Tests', () {
    testWidgets('blocked action shows SoD violation', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Login as Tecnico
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username_field')), 'tecnico_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Act - Try to perform blocked action
      await tester.tap(find.byKey(Key('inject_firmware_button')));
      await tester.pumpAndSettle();

      // Assert - Should show SoD violation
      expect(find.text('SoD Violation'), findsOneWidget);
      expect(find.text('Self-approval not allowed'), findsOneWidget);
    });

    testWidgets('allowed action proceeds normally', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Login as Tecnico
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username_field')), 'tecnico_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Act - Perform allowed action
      await tester.tap(find.byKey(Key('scan_ble_button')));
      await tester.pumpAndSettle();

      // Assert - Should proceed to BLE scanning
      expect(find.text('Scanning for devices...'), findsOneWidget);
    });
  });

  group('Performance Integration Tests', () {
    testWidgets('login completes within 2 seconds', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username_field')), 'test_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('SoD validation completes within 150ms', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('username_field')), 'test_user');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Act
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.byKey(Key('validate_sod_button')));
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(150));
    });
  });
}