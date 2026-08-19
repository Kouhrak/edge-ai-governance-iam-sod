import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Side navigation entry — selected state renders a white background tint.
/// Minimum 48dp height for tactile targets.
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DesignTokens.tactileMinSize,
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: DesignTokens.textXl,
                  color: selected ? Colors.white : Colors.white70,
                ),
                const SizedBox(width: DesignTokens.spaceMd),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: DesignTokens.textMd,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceXs,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: DesignTokens.textXl,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.safetyRed,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLg),
                    ),
                    child: Text(
                      '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.textSm,
                        fontWeight: FontWeight.bold,
                      ),
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