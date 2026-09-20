import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme =
      ThemeData(
    useMaterial3: true,

    colorScheme:
        ColorScheme.fromSeed(
      seedColor:
          const Color(0xFF14532D),
    ),

    scaffoldBackgroundColor:
        const Color(0xFFF7FAF8),

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          Color(0xFF14532D),

      foregroundColor:
          Colors.white,

      centerTitle: false,
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,

      fillColor:
          Colors.white,

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.all(
          Radius.circular(12),
        ),

        borderSide:
            BorderSide.none,
      ),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
        minimumSize:
            const Size(
          double.infinity,
          52,
        ),

        backgroundColor:
            const Color(0xFF14532D),

        foregroundColor:
            Colors.white,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    ),
  );
}