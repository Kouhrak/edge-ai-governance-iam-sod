import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

/// Defense-in-depth blocked screen: shown for login denial (PlatformBlocked)
/// and for Authenticated sessions whose platform does not match the role.
class PlatformBlockedView extends StatelessWidget {
  final String username;
  final String message;
  final VoidCallback onLogout;

  const PlatformBlockedView({
    super.key,
    required this.username,
    required this.message,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.surfaceCream,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Padding(
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
                    Icons.lock,
                    size: 48,
                    color: DesignTokens.govBlue,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: DesignTokens.textLg,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.govBlue,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: DesignTokens.textMd),
                ),
                const SizedBox(height: DesignTokens.spaceLg),
                SizedBox(
                  width: double.infinity,
                  height: DesignTokens.tactileMinSize,
                  child: ElevatedButton(
                    onPressed: onLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.govBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                    ),
                    child: const Text('Cerrar Sesión'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}