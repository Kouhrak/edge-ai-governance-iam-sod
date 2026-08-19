import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text_field.dart';
import '../atoms/status_badge.dart';

/// Login variants: user+password (web/desktop) and single token (mobile).
enum LoginVariant { userPassword, token }

/// Shared login molecule — controlled (no bloc import). Renders the
/// user+password or token form per [variant], validates locally, and
/// surfaces [errorMessage] inline via a danger StatusBadge.
class LoginForm extends StatefulWidget {
  final LoginVariant variant;
  final bool isLoading;
  final String? errorMessage;
  final void Function(String user, String pass)? onUserPasswordSubmit;
  final void Function(String token)? onTokenSubmit;
  final String buttonLabel;

  const LoginForm({
    super.key,
    this.variant = LoginVariant.userPassword,
    this.isLoading = false,
    this.errorMessage,
    this.onUserPasswordSubmit,
    this.onTokenSubmit,
    this.buttonLabel = 'Iniciar Sesión',
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();

  bool get _isTokenVariant => widget.variant == LoginVariant.token;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isTokenVariant) {
      widget.onTokenSubmit?.call(_tokenController.text);
    } else {
      widget.onUserPasswordSubmit?.call(
        _usernameController.text,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isTokenVariant)
            AppTextField(
              controller: _tokenController,
              label: 'Token',
              hint: 'Ingrese su token de acceso',
              prefixIcon: Icons.key,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su token';
                }
                return null;
              },
            )
          else ...[
            AppTextField(
              controller: _usernameController,
              label: 'Usuario',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su usuario';
                }
                return null;
              },
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            AppTextField(
              controller: _passwordController,
              label: 'Contraseña',
              obscureText: true,
              prefixIcon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su contraseña';
                }
                return null;
              },
            ),
          ],
          if (widget.errorMessage != null) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            StatusBadge(
              label: widget.errorMessage!,
              tone: StatusTone.danger,
            ),
          ],
          const SizedBox(height: DesignTokens.spaceLg),
          AppButton(
            label: widget.buttonLabel,
            onPressed: _submit,
            loading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}