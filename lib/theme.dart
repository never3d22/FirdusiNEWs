import 'package:flutter/material.dart';

ThemeData buildTheme() {
  const seed = Color(0xFFE0493E);
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

  final textTheme = base.textTheme.apply(
    bodyColor: const Color(0xFF241919),
    displayColor: const Color(0xFF241919),
    fontFamily: 'Roboto',
  ).copyWith(
    headlineLarge: base.textTheme.headlineLarge?.copyWith(letterSpacing: -0.6),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(letterSpacing: -0.4),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      letterSpacing: -0.2,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
  );

  return base.copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xFFFEF8F2),
    colorScheme: scheme.copyWith(surfaceTint: Colors.transparent),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textTheme.titleLarge?.color,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.85),
      indicatorColor: scheme.primary.withOpacity(0.15),
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      elevation: 0,
      labelTextStyle: MaterialStateProperty.resolveWith(
        (states) {
          final isSelected = states.contains(MaterialState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? scheme.primary
                : textTheme.labelMedium?.color?.withOpacity(0.7),
          );
        },
      ),
      iconTheme: MaterialStateProperty.resolveWith(
        (states) {
          final baseColor = states.contains(MaterialState.selected)
              ? scheme.primary
              : textTheme.bodyMedium?.color?.withOpacity(0.7);
          return IconThemeData(color: baseColor, size: 26);
        },
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      selectedColor: scheme.primary.withOpacity(0.12),
      backgroundColor: Colors.white.withOpacity(0.7),
      side: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      labelStyle: textTheme.labelLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        shadowColor: scheme.primary.withOpacity(0.35),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: textTheme.titleMedium,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: textTheme.titleMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: textTheme.titleMedium,
        side: BorderSide(color: scheme.primary.withOpacity(0.4), width: 1.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      filled: true,
      fillColor: Colors.white,
      hintStyle: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    ),
    cardTheme: base.cardTheme.copyWith(
      color: Colors.white,
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.white,
      selectedTileColor: scheme.primary.withOpacity(0.1),
      iconColor: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: scheme.outlineVariant.withOpacity(0.35),
      thickness: 0.8,
    ),
    progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
      color: scheme.primary,
      circularTrackColor: scheme.primary.withOpacity(0.2),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.primary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
