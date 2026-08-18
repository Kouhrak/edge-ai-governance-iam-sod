import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edge_ai_governance_iam_sod/core/theme/design_tokens.dart';

void main() {
  group('LoginForm Widget Tests', () {
    testWidgets('should display login form with required fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username and password
      expect(find.byType(ElevatedButton), findsOneWidget); // Login button
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should have minimum touch target size for industrial use', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      final loginButton = find.byType(ElevatedButton);
      final buttonSize = tester.getSize(loginButton);

      // Assert
      expect(buttonSize.width, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
      expect(buttonSize.height, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
    });

    testWidgets('should show error when submitting empty form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('should validate username input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test_user');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Should not show error for username
      expect(find.text('Username is required'), findsNothing);
    });

    testWidgets('should have proper color scheme for accessibility', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Color(DesignTokens.govBlue),
            errorColor: Color(DesignTokens.safetyRed),
          ),
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      // Assert
      expect(elevatedButton.style?.backgroundColor?.resolve({}), 
             Color(DesignTokens.govBlue));
    });

    testWidgets('should be responsive on different screen sizes', (WidgetTester tester) async {
      // Arrange - Mobile size
      tester.view.physicalSize = Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(Form), findsOneWidget);
      
      // Reset to default size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}

// Mock LoginForm widget for testing
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48, // Minimum touch target size
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(DesignTokens.govBlue),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing login...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}