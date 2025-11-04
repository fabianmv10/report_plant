import 'package:flutter/material.dart';

/// Clase que contiene todos los estilos y temas de la aplicación
class AppTheme {
  // Evitar instanciación
  AppTheme._();

  // Colores primarios de la aplicación
  static const Color primaryColor = Color(0xFF00377A); // Azul industrial
  static const Color primaryColorLight = Color(0xFF1F84FF);
  static const Color primaryColorDark = Color(0xFF001229);

  // Colores secundarios
  static const Color secondaryColor = Color(0xFF26A69A); // Verde agua
  static const Color secondaryColorLight = Color(0xFFADD784);
  static const Color secondaryColorDark = Color(0xFF3D5C1E);

  // Colores de acento y acción
  static const Color accentColor = Color(0xFFFFA000); // Ámbar
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);

  // Colores neutros
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Colores de texto
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFF9E9E9E);
  static const Color textOnPrimaryColor = Colors.white;
  static const Color textOnSecondaryColor = Colors.white;

  // Colores para los turnos
  static final Map<String, Color> shiftColors = {
    'Mañana': const Color(0xFFF57F17), // Ámbar oscuro
    'Tarde': const Color(0xFF1565C0), // Azul oscuro
    'Noche': const Color(0xFF283593), // Índigo oscuro
  };

  // Colores para las plantas (manteniendo los originales para consistencia)
  static final Map<String, Color> plantColors = {
    '1': const Color(0xFF1E88E5), // Sulfato de Aluminio Tipo A
    '2': const Color(0xFF43A047), // Sulfato de Aluminio Tipo B
    '3': const Color(0xFFFFB300), // Banalum
    '4': const Color(0xFFE53935), // Bisulfito de Sodio
    '5': const Color(0xFF8E24AA), // Silicatos
    '6': const Color(0xFF00897B), // Policloruro de Aluminio
    '7': const Color(0xFF3949AB), // Polímeros Catiónicos
    '8': const Color(0xFFF4511E), // Polímeros Aniónicos
    '9': const Color(0xFF6D4C41), // Llenados
  };

  // Esquema de color para el tema claro
  static const ColorScheme lightColorScheme = ColorScheme(
    primary: primaryColor,
    primaryContainer: primaryColorLight,
    secondary: secondaryColor,
    secondaryContainer: secondaryColorLight,
    surface: surfaceColor,
    error: errorColor,
    onPrimary: textOnPrimaryColor,
    onSecondary: textOnSecondaryColor,
    onSurface: textPrimaryColor,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  // Esquema de color para el tema oscuro
  static const ColorScheme darkColorScheme = ColorScheme(
    primary: primaryColorLight,
    primaryContainer: primaryColor,
    secondary: secondaryColorLight,
    secondaryContainer: secondaryColor,
    surface: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    onError: Colors.black,
    brightness: Brightness.dark,
  );

  // Tema claro
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColorDark,
      elevation: 2,
      centerTitle: true,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textOnPrimaryColor,
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return textSecondaryColor;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColorLight.withValues(alpha: 0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: textOnPrimaryColor,
      unselectedLabelColor: textOnPrimaryColor.withValues(alpha: 0.7),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: primaryColorDark,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textOnPrimaryColor,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondaryColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
    ),
  );

  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    primaryColor: primaryColorLight,
    scaffoldBackgroundColor: darkColorScheme.surface,
    cardColor: darkColorScheme.surface,
    dividerColor: Colors.grey.shade800,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      color: darkColorScheme.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: darkColorScheme.onPrimary,
        backgroundColor: darkColorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        side: BorderSide(color: darkColorScheme.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkColorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkColorScheme.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary;
        }
        return Colors.grey.shade400;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary;
        }
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return darkColorScheme.primary.withValues(alpha: 0.5);
        }
        return Colors.grey.shade700;
      }),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: darkColorScheme.onSurface,
      unselectedLabelColor: darkColorScheme.onSurface.withValues(alpha: 0.7),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: darkColorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkColorScheme.surface,
      selectedItemColor: darkColorScheme.primary,
      unselectedItemColor: Colors.grey.shade400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkColorScheme.primary,
      foregroundColor: darkColorScheme.onPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkColorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkColorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkColorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkColorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkColorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: darkColorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: darkColorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: darkColorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: darkColorScheme.onSurface.withValues(alpha: 0.8),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkColorScheme.onSurface,
      ),
    ),
  );

  // Estilos reutilizables para tarjetas de reportes
  static BoxDecoration plantCardDecoration(String plantId) {
    final plantColor = plantColors[plantId] ?? primaryColor;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        colors: [plantColor, plantColor.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Estilos para los contenedores de turnos
  static BoxDecoration shiftContainerDecoration(String shift) {
    final shiftColor = shiftColors[shift] ?? primaryColor;
    return BoxDecoration(
      color: shiftColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: shiftColor,
        width: 1,
      ),
    );
  }

  // Estilo para encabezado de turnos
  static BoxDecoration shiftHeaderDecoration(String shift) {
    final shiftColor = shiftColors[shift] ?? primaryColor;
    return BoxDecoration(
      color: shiftColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    );
  }

  // TextStyles comunes
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle valueTextStyle = const TextStyle(
    fontSize: 14,
    color: textPrimaryColor,
  );

  static TextStyle shiftHeaderTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // Sombras
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];

  // Espaciado común
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;

  // Bordes redondeados
  static BorderRadius smallBorderRadius = BorderRadius.circular(8.0);
  static BorderRadius mediumBorderRadius = BorderRadius.circular(12.0);
  static BorderRadius largeBorderRadius = BorderRadius.circular(16.0);
}

/// Extensiones para facilitar el uso del tema
extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  // Acceso directo a colores principales
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).colorScheme.surface;
  Color get errorColor => Theme.of(this).colorScheme.error;
  
  // Dimensiones de pantalla
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  bool get isTablet => screenWidth >= 600;
  bool get isMobile => screenWidth < 600;
}