import 'package:flutter_test/flutter_test.dart';
import 'package:edge_ai_governance_iam_sod/core/theme/design_tokens.dart';

void main() {
  group('DesignTokens', () {
    test('should have correct color values', () {
      // Arrange & Act & Assert
      expect(DesignTokens.safetyRed, 0xFFDC3545);
      expect(DesignTokens.warningYellow, 0xFFFFC107);
      expect(DesignTokens.govBlue, 0xFF0D6EFD);
      expect(DesignTokens.safeGreen, 0xFF198754);
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

    test('should have proper opacity for blocked elements', () {
      // Verify that blocked elements have reduced opacity
      expect(DesignTokens.blockedOpacity, lessThan(1.0));
      expect(DesignTokens.blockedOpacity, greaterThanOrEqualTo(0.3));
    });
  });

  group('AppTheme', () {
    test('should create valid ThemeData', () {
      // Arrange
      final theme = AppTheme.light();
      
      // Act & Assert
      expect(theme, isNotNull);
      expect(theme.primaryColor, isNotNull);
      expect(theme.errorColor, isNotNull);
      expect(theme.colorScheme, isNotNull);
    });

    test('should have proper color mappings', () {
      // Arrange
      final theme = AppTheme.light();
      
      // Act & Assert
      expect(theme.primaryColor.value, DesignTokens.govBlue);
      expect(theme.errorColor.value, DesignTokens.safetyRed);
    });

    test('should have accessible touch targets', () {
      // Arrange
      final theme = AppTheme.light();
      
      // Act & Assert - Check button theme has minimum size
      expect(
        theme.materialButtonTheme.style?.minimumSize?.resolve({})?.width,
        greaterThanOrEqualTo(DesignTokens.tactileMinSize),
      );
      expect(
        theme.materialButtonTheme.style?.minimumSize?.resolve({})?.height,
        greaterThanOrEqualTo(DesignTokens.tactileMinSize),
      );
    });
  });
}