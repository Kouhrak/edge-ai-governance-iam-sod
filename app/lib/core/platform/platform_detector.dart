import 'package:flutter/foundation.dart';

import 'platform_type.dart';

export 'platform_type.dart'; // detector exposes the enum (spec)

/// Resolves the current runtime platform to a [PlatformType].
/// Web-safe: uses foundation only (kIsWeb + defaultTargetPlatform),
/// never dart:io.
abstract final class PlatformDetector {
  static PlatformType get currentPlatform {
    if (kIsWeb) return PlatformType.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return PlatformType.desktop;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return PlatformType.mobile;
    }
  }
}