import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Status badge tones mapped to design tokens.
enum StatusTone { success, warning, danger, neutral, brand }

/// Pill-shaped status indicator — tone background at 10% alpha with the
/// tone as foreground. Used for connection states, security alerts, etc.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;

  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
  });

  Color get _toneColor {
    switch (tone) {
      case StatusTone.success:
        return DesignTokens.safeGreen;
      case StatusTone.warning:
        return DesignTokens.warningYellow;
      case StatusTone.danger:
        return DesignTokens.safetyRed;
      case StatusTone.neutral:
        return Colors.grey;
      case StatusTone.brand:
        return DesignTokens.govBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _toneColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: DesignTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: DesignTokens.textSm,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}