import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Compact chip for identifiers/tokens — optional leading icon and an
/// optional delete affordance (onDeleted non-null).
class TokenChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onDeleted;

  const TokenChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final Color chipColor = color ?? DesignTokens.govBlue;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: DesignTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: DesignTokens.textMd, color: chipColor),
            const SizedBox(width: DesignTokens.spaceXs),
          ],
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: DesignTokens.textSm,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: DesignTokens.spaceXs),
            InkWell(
              onTap: onDeleted,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Icon(
                Icons.close,
                size: DesignTokens.textMd,
                color: chipColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}