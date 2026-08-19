import 'package:flutter/material.dart';

/// Normative visual atoms. Single source of truth — the visual layer MUST NOT
/// alter security semantics (SoD lockouts etc.), only consume these tokens.
abstract final class DesignTokens {
  // Semantic palette (Penpot-derived). Names/semantics UNCHANGED.
  static const Color govBlue = Color(0xFFFC7E6C); // AI identity/brand -> Penpot coral
  static const Color safetyRed = Color(0xFFD32F2F); // SoD lockouts -> Penpot red
  static const Color warningYellow = Color(0xFFB7BE3A); // calibration warnings -> Penpot olive
  static const Color safeGreen = Color(0xFF00A461); // authorized access -> Penpot green
  // Surfaces (Penpot identity palette).
  static const Color surfaceCream = Color(0xFFFFF3D8);
  static const Color surfaceTan = Color(0xFFE5BE9D);
  // Scales.
  static const double spaceXs = 4, spaceSm = 8, spaceMd = 16, spaceLg = 24, spaceXl = 32;
  static const double radiusSm = 4, radiusMd = 8, radiusLg = 12;
  static const double textXs = 10, textSm = 12, textMd = 14, textLg = 16, textXl = 20, textXl2 = 24;
  static const double tactileMinSize = 48.0; // industrial tablets, >= 48dp
}