import 'package:flutter_test/flutter_test.dart';
import 'package:edge_ai_iam_sod/core/theme/design_tokens.dart';
import 'package:edge_ai_iam_sod/core/theme/app_theme.dart';

void main() {
  group('DesignTokens', () {
    test('should have correct Penpot color values', () {
      // Arrange & Act & Assert
      expect(DesignTokens.govBlue.toARGB32(), 0xFFFC7E6C);
      expect(DesignTokens.safetyRed.toARGB32(), 0xFFD32F2F);
      expect(DesignTokens.warningYellow.toARGB32(), 0xFFB7BE3A);
      expect(DesignTokens.safeGreen.toARGB32(), 0xFF00A461);
      expect(DesignTokens.surfaceCream.toARGB32(), 0xFFFFF3D8);
      expect(DesignTokens.surfaceTan.toARGB32(), 0xFFE5BE9D);
    });

    test('should have correct spacing and radius scales', () {
      // Arrange & Act & Assert
      expect(DesignTokens.spaceXs, 4);
      expect(DesignTokens.spaceSm, 8);
      expect(DesignTokens.spaceMd, 16);
      expect(DesignTokens.spaceLg, 24);
      expect(DesignTokens.spaceXl, 32);
      expect(DesignTokens.radiusSm, 4);
      expect(DesignTokens.radiusMd, 8);
      expect(DesignTokens.radiusLg, 12);
    });

    test('should have correct text scale', () {
      // Arrange & Act & Assert
      expect(DesignTokens.textXs, 10);
      expect(DesignTokens.textSm, 12);
      expect(DesignTokens.textMd, 14);
      expect(DesignTokens.textLg, 16);
      expect(DesignTokens.textXl, 20);
      expect(DesignTokens.textXl2, 24);
    });

    test('should have minimum tactile size for industrial tablets', () {
      // Arrange & Act & Assert
      expect(DesignTokens.tactileMinSize, greaterThanOrEqualTo(48.0));
    });

    test('should have consistent color semantics', () {
      // Semantic colors plus Penpot surface tokens are all defined
      expect(DesignTokens.safetyRed, isNotNull);
      expect(DesignTokens.warningYellow, isNotNull);
      expect(DesignTokens.govBlue, isNotNull);
      expect(DesignTokens.safeGreen, isNotNull);
      expect(DesignTokens.surfaceCream, isNotNull);
      expect(DesignTokens.surfaceTan, isNotNull);
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

    test('should use cream surface as scaffold background', () {
      // Arrange
      final theme = AppTheme.light();

      // Act & Assert
      expect(
        theme.scaffoldBackgroundColor.toARGB32(),
        DesignTokens.surfaceCream.toARGB32(),
      );
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