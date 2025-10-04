import 'package:flutter/material.dart';

ThemeData buildTheme() {
  const seed = Color(0xFF9C2B31);
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFFFFAF4),
    colorScheme: scheme.copyWith(surfaceTint: Colors.transparent),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF2A1B1A),
      displayColor: const Color(0xFF2A1B1A),
      fontFamily: 'Roboto',
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: Colors.white,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      selectedColor: scheme.primary.withOpacity(0.15),
      side: BorderSide(color: scheme.primary.withOpacity(0.25)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      labelStyle: base.textTheme.labelLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      filled: true,
      fillColor: Colors.white,
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
    ),
  );
}
