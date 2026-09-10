import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/molecules/login_form.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// IOC web login — shared LoginForm (user/password) fed by the AuthBloc;
/// authentication errors surface inline via the form errorMessage.
class IocLoginPage extends StatefulWidget {
  const IocLoginPage({super.key});

  @override
  State<IocLoginPage> createState() => _IocLoginPageState();
}

class _IocLoginPageState extends State<IocLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Card(
            margin: EdgeInsets.zero,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(DesignTokens.spaceXl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: DesignTokens.govBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 48,
                      color: DesignTokens.govBlue,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  const Text(
                    'Edge AI Governance',
                    style: TextStyle(
                      fontSize: DesignTokens.textXl2,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.govBlue,
                    ),
                  ),
                  Text(
                    'IAM & SoD System',
                    style: TextStyle(
                      fontSize: DesignTokens.textMd,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      return LoginForm(
                        variant: LoginVariant.userPassword,
                        isLoading: state is AuthLoading,
                        errorMessage: state is AuthError ? state.message : null,
                        onUserPasswordSubmit: (username, password) {
                          context.read<AuthBloc>().add(
                                LoginRequested(
                                  username: username,
                                  password: password,
                                ),
                              );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}