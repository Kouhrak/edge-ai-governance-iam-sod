import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Progress indicator atom wrapping [LinearProgressIndicator]. Defaults to
/// safeGreen; callers may override color/minHeight per context.
class ProgressBar extends StatelessWidget {
  final double? value;
  final Color? color;
  final double? minHeight;

  const ProgressBar({
    super.key,
    this.value,
    this.color,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: minHeight ?? 8,
      color: color ?? DesignTokens.safeGreen,
      backgroundColor: Colors.grey.withValues(alpha: 0.2),
    );
  }
}