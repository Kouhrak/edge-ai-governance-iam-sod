import 'package:flutter/material.dart';

/// Normative visual atoms. Single source of truth — the visual layer MUST NOT
/// alter security semantics (SoD lockouts etc.), only consume these tokens.
abstract final class DesignTokens {
  static const Color safetyRed = Color(0xFFDC3545); // SoD lockouts
  static const Color warningYellow = Color(0xFFFFC107); // calibration warnings
  static const Color govBlue = Color(0xFF0D6EFD); // AI agent identity
  static const Color safeGreen = Color(0xFF198754); // authorized access
  static const double tactileMinSize = 48.0; // industrial tablets, >= 48dp
}
