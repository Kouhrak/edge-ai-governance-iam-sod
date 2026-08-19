import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../atoms/app_button.dart';

/// Bottom action bar — primary (filled) and optional secondary (outlined)
/// buttons, both >= 48dp.
class ActionBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool primaryEnabled;
  final Color? primaryColor;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const ActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.primaryColor,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (secondaryLabel != null && onSecondary != null) ...[
            Expanded(
              child: AppButton(
                label: secondaryLabel!,
                onPressed: onSecondary,
                variant: AppButtonVariant.outlined,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
          ],
          Expanded(
            flex: secondaryLabel != null ? 2 : 1,
            child: AppButton(
              label: primaryLabel,
              onPressed: onPrimary,
              enabled: primaryEnabled,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}