import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Button variants shared across the design system.
enum AppButtonVariant { filled, outlined, text }

/// Tactile button atom — minimum 48x48dp tap target, radiusMd corners,
/// loading spinner state. Defaults to govBlue; color overrides allow
/// safeGreen/safetyRed semantics.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final Color? color;
  final bool enabled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = color ?? DesignTokens.govBlue;
    final VoidCallback? onTap =
        (enabled && !loading) ? onPressed : null;

    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: DesignTokens.textXl,
            height: DesignTokens.textXl,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.filled
                  ? Colors.white
                  : activeColor,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
        ] else if (icon != null) ...[
          Icon(icon, size: DesignTokens.textXl),
          const SizedBox(width: DesignTokens.spaceSm),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final ButtonStyle style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        const Size.square(DesignTokens.tactileMinSize),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
    );

    switch (variant) {
      case AppButtonVariant.filled:
        return ElevatedButton(
          onPressed: onTap,
          style: style.copyWith(
            backgroundColor: WidgetStatePropertyAll(activeColor),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onTap,
          style: style.copyWith(
            foregroundColor: WidgetStatePropertyAll(activeColor),
            side: WidgetStatePropertyAll(BorderSide(color: activeColor)),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onTap,
          style: style.copyWith(
            foregroundColor: WidgetStatePropertyAll(activeColor),
          ),
          child: child,
        );
    }
  }
}