import 'package:flutter_test/flutter_test.dart';
import 'package:edge_ai_iam_sod/core/theme/design_tokens.dart';
import 'package:edge_ai_iam_sod/core/theme/app_theme.dart';

void main() {
  group('DesignTokens', () {
    test('should have correct color values', () {
      // Arrange & Act & Assert
      expect(DesignTokens.safetyRed.toARGB32(), 0xFFDC3545);
      expect(DesignTokens.warningYellow.toARGB32(), 0xFFFFC107);
      expect(DesignTokens.govBlue.toARGB32(), 0xFF0D6EFD);
      expect(DesignTokens.safeGreen.toARGB32(), 0xFF198754);
    });

    test('should have minimum tactile size for industrial tablets', () {
      // Arrange & Act & Assert
      expect(DesignTokens.tactileMinSize, greaterThanOrEqualTo(48.0));
    });

    test('should have consistent color semantics', () {
      // SafetyRed should be for SoD lockouts
      expect(DesignTokens.safetyRed, isNotNull);

      // WarningYellow should be for calibration warnings
      expect(DesignTokens.warningYellow, isNotNull);

      // GovBlue should be for AI agent
      expect(DesignTokens.govBlue, isNotNull);

      // SafeGreen should be for authorized access
      expect(DesignTokens.safeGreen, isNotNull);
    });
  });

  group('AppTheme', () {
    test('should create valid ThemeData', () {
      // Arrange
      final theme = AppTheme.light();

      // Act & Assert
      expect(theme, isNotNull);
      expect(theme.primaryColor, isNotNull);
      expect(theme.colorScheme.error, isNotNull);
      expect(theme.colorScheme, isNotNull);
    });

    test('should have proper color mappings', () {
      // Arrange
      final theme = AppTheme.light();

      // Act & Assert
      expect(theme.primaryColor.toARGB32(), DesignTokens.govBlue.toARGB32());
      expect(theme.colorScheme.error.toARGB32(), DesignTokens.safetyRed.toARGB32());
    });

    test('should have accessible touch targets', () {
      // Arrange
      final theme = AppTheme.light();

      // Act & Assert - Check filled button theme has minimum size
      expect(
        theme.filledButtonTheme.style?.minimumSize?.resolve({})?.width,
        greaterThanOrEqualTo(DesignTokens.tactileMinSize),
      );
      expect(
        theme.filledButtonTheme.style?.minimumSize?.resolve({})?.height,
        greaterThanOrEqualTo(DesignTokens.tactileMinSize),
      );
    });
  });
}