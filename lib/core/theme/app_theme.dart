import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Application theme — maps normative design tokens (DesignTokens) to
/// Material [ThemeData]. Every widget MUST consume tokens, never raw hex.
abstract final class AppTheme {
  /// Light theme: govBlue primary (AI agent), warningYellow secondary
  /// (calibration warnings), safetyRed error (SoD lockouts), safeGreen
  /// tertiary (authorized access). Touch targets >= 48dp for industrial
  /// tablets (tactileMinSize).
  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.govBlue,
      primary: DesignTokens.govBlue,
      secondary: DesignTokens.warningYellow,
      error: DesignTokens.safetyRed,
      tertiary: DesignTokens.safeGreen,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Padded tap targets guarantee the 48x48dp Material minimum; combined
      // with the button minimum below, every interactive atom stays >= 48dp.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.square(DesignTokens.tactileMinSize),
        ),
      ),
    );
  }
}
