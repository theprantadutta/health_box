import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class Material3Theme {
  static const Color _fallbackSeedColor = Color(0xFF2196F3);

  static Future<ColorScheme> generateDynamicColorScheme({
    Brightness brightness = Brightness.light,
    Color? seedColor,
  }) async {
    Color finalSeedColor = seedColor ?? _fallbackSeedColor;

    try {
      if (seedColor == null) {
        final dynamicColors = await _getDynamicColorsFromSystem();
        if (dynamicColors != null) {
          finalSeedColor = brightness == Brightness.light
              ? dynamicColors.light.primary
              : dynamicColors.dark.primary;
        }
      }
    } catch (e) {
      debugPrint('Failed to get dynamic colors: $e');
    }

    return ColorScheme.fromSeed(
      seedColor: finalSeedColor,
      brightness: brightness,
    );
  }

  static Future<({ColorScheme light, ColorScheme dark})?> _getDynamicColorsFromSystem() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        return (
          light: corePalette.toColorScheme(brightness: Brightness.light),
          dark: corePalette.toColorScheme(brightness: Brightness.dark),
        );
      }
    } catch (e) {
      debugPrint('Error getting system core palette: $e');
    }
    return null;
  }

  static ThemeData createMaterial3Theme({
    required ColorScheme colorScheme,
    String? fontFamily,
  }) {
    final brightness = colorScheme.brightness;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: brightness == Brightness.light ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: colorScheme.surfaceTint,
        color: colorScheme.surface,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          minimumSize: const Size(64, 40),
          maximumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surface,
          surfaceTintColor: colorScheme.surfaceTint,
          shadowColor: colorScheme.shadow,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          minimumSize: const Size(64, 40),
          maximumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
        ),
      ),

      // Note: filledButtonThemeData is not available in current Flutter version

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          minimumSize: const Size(64, 40),
          maximumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(48, 40),
          maximumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: colorScheme.primary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondaryContainer,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainerHigh),
        surfaceTintColor: WidgetStateProperty.all(colorScheme.surfaceTint),
        overlayColor: WidgetStateProperty.all(colorScheme.surface),
        shadowColor: WidgetStateProperty.all(colorScheme.shadow),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return 3;
          }
          return 1;
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: colorScheme.surfaceTint,
        modalBackgroundColor: colorScheme.surfaceContainerLow,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        deleteIconColor: colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        brightness: brightness,
        elevation: 0,
        pressElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.surface;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return null;
          }
          return colorScheme.outline;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),
    );
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle(ColorScheme colorScheme) {
    final brightness = colorScheme.brightness;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness == Brightness.light ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: colorScheme.surface,
      systemNavigationBarIconBrightness: brightness == Brightness.light ? Brightness.dark : Brightness.light,
      systemNavigationBarDividerColor: brightness == Brightness.light 
          ? colorScheme.outlineVariant 
          : Colors.transparent,
    );
  }
}

class DynamicColorPlugin {
  static const MethodChannel _channel = MethodChannel('dynamic_color');

  static Future<CorePalette?> getCorePalette() async {
    try {
      final result = await _channel.invokeMethod('getCorePalette');
      if (result != null) {
        return CorePalette.fromList(List<int>.from(result));
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get core palette: $e');
    }
    return null;
  }
}

extension CorePaletteExtension on CorePalette {
  ColorScheme toColorScheme({required Brightness brightness}) {
    return ColorScheme.fromSeed(
      seedColor: Color(primary.get(40)),
      brightness: brightness,
    );
  }
}