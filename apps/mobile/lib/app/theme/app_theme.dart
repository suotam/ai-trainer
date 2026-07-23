import 'package:flutter/material.dart';

/// Základní theme bootstrap. Není to produkční design system —
/// ten je mimo scope R0 (VSP §5 non-goals).
abstract final class AppTheme {
  static const Color _seedColor = Color(0xFF2E7D32);

  static ThemeData light() =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seedColor));

  static ThemeData dark() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );
}
