import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edge_ai_iam_sod/core/platform/platform_detector.dart';

void main() {
  group('PlatformDetector.currentPlatform', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('should map desktop platforms to PlatformType.desktop', () {
      // Arrange & Act & Assert
      for (final platform in [
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(PlatformDetector.currentPlatform, PlatformType.desktop);
      }
    });

    test('should map mobile platforms to PlatformType.mobile', () {
      // Arrange & Act & Assert
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        expect(PlatformDetector.currentPlatform, PlatformType.mobile);
      }
    });

    test('should expose PlatformType through re-export', () {
      // Arrange & Act & Assert
      expect(
        PlatformType.values,
        [PlatformType.web, PlatformType.desktop, PlatformType.mobile],
      );
    });
  });
}