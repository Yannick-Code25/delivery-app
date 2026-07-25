import 'package:flutter/material.dart';

/// Colors extracted from ref/extracted/.../vibrant_velocity/DESIGN.md
/// Keep this file in sync with DESIGN.md if the design system changes.
class AppColors {
  AppColors._();

  static const surface = Color(0xFFF8FAFB);
  static const surfaceDim = Color(0xFFD8DADB);
  static const surfaceBright = Color(0xFFF8FAFB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F5);
  static const surfaceContainer = Color(0xFFECEEEF);
  static const surfaceContainerHigh = Color(0xFFE6E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF504534);
  static const inverseSurface = Color(0xFF2E3132);
  static const inverseOnSurface = Color(0xFFEFF1F2);
  static const outline = Color(0xFF827562);
  static const outlineVariant = Color(0xFFD4C4AE);
  static const surfaceTint = Color(0xFF7C5800);

  static const primary = Color(0xFF7C5800);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFC244);
  static const onPrimaryContainer = Color(0xFF715000);
  static const inversePrimary = Color(0xFFF9BD3F);

  static const secondary = Color(0xFF595F6A);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFDDE2F0);
  static const onSecondaryContainer = Color(0xFF5F6570);

  static const tertiary = Color(0xFF006B56);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF66E1BF);
  static const onTertiaryContainer = Color(0xFF00624F);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF8FAFB);
  static const onBackground = Color(0xFF191C1D);

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
  );
}
