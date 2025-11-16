import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// Premium Material You theme configuration
class AppTheme {
  // Brand colors - will be used as seeds for Material You
  static const Color brandPrimary = Color(0xFF6750A4); // Material Purple
  static const Color brandSecondary = Color(0xFF625B71); // Material Purple variant
  static const Color brandTertiary = Color(0xFF7D5260); // Material Pink

  // Custom surface colors for enhanced backgrounds
  static const Color lightSurfaceTint = Color(0xFFFAF9FE);
  static const Color darkSurfaceTint = Color(0xFF1C1B1F);

  /// Generate Material You theme with dynamic colors
  static Future<ThemeData> dynamicLightTheme(BuildContext context, [Color? accentColor]) async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    final primary = accentColor ?? brandPrimary;

    return _buildLightTheme(
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
    );
  }

  static Future<ThemeData> dynamicDarkTheme(BuildContext context, [Color? accentColor]) async {
    final corePalette = await DynamicColorPlugin.getCorePalette();
    final primary = accentColor ?? brandPrimary;

    return _buildDarkTheme(
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
    );
  }

  /// Light theme with Material You design
  static ThemeData lightTheme([Color? primaryColor]) {
    final primary = primaryColor ?? brandPrimary;

    return _buildLightTheme(
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
    );
  }

  /// Dark theme with Material You design
  static ThemeData darkTheme([Color? primaryColor]) {
    final primary = primaryColor ?? brandPrimary;

    return _buildDarkTheme(
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _buildLightTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Premium typography with perfect hierarchy
      textTheme: _buildTextTheme(Brightness.light),

      // Elevated surface with subtle tint
      scaffoldBackgroundColor: colorScheme.surface,

      // App bar with surface tint
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
      ),

      // Modern cards with surface tint
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: colorScheme.surfaceTint,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Material You navigation bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 80,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurface,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              size: 24,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return IconThemeData(
            size: 24,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Material You FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Enhanced chips
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Modern input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Premium buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          surfaceTintColor: colorScheme.surfaceTint,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData _buildDarkTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Premium typography with perfect hierarchy
      textTheme: _buildTextTheme(Brightness.dark),

      // Deep background
      scaffoldBackgroundColor: colorScheme.surface,

      // App bar with surface tint
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: colorScheme.onSurface,
        ),
      ),

      // Modern cards with surface tint
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: colorScheme.surfaceTint,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Material You navigation bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 80,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: colorScheme.onSurface,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              size: 24,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return IconThemeData(
            size: 24,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Material You FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Enhanced chips
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Modern input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Premium buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.primary,
          surfaceTintColor: colorScheme.surfaceTint,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // List tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Premium typography system matching Play Store apps
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? const Color(0xFF1C1B1F)
        : const Color(0xFFE6E1E5);

    return TextTheme(
      // Display styles - for hero sections
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: baseColor,
      ),

      // Headline styles - for sections
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.29,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: baseColor,
      ),

      // Title styles - for list items, cards
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: baseColor,
      ),

      // Body styles - for paragraphs
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: baseColor,
      ),

      // Label styles - for buttons, tabs
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
        color: baseColor,
      ),
    );
  }
}
