import "package:flutter/material.dart";

ThemeData getTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.amber,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black54,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(10),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.fromMap(
          {
            WidgetState.disabled: Colors.grey.shade600,
            WidgetState.any: Colors.purple.shade400,
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        elevation: const WidgetStateProperty.fromMap(
          {
            WidgetState.disabled: 0,
            WidgetState.any: 6,
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.fromMap(
          {
            WidgetState.disabled: Colors.grey.shade500,
            WidgetState.any: Colors.purple,
          },
        ),
        iconColor: WidgetStateProperty.fromMap(
          {
            WidgetState.disabled: Colors.grey.shade500,
            WidgetState.any: Colors.purple,
          },
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        overlayColor:
            WidgetStateProperty.all<Color>(Colors.purple.withAlpha(26)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.fromMap(
          {
            WidgetState.disabled: Colors.grey.shade500,
            WidgetState.any: Colors.purple,
          },
        ),
        side: WidgetStateProperty.fromMap(
          {
            WidgetState.disabled: BorderSide(color: Colors.grey.shade500),
            WidgetState.any: const BorderSide(color: Colors.purple),
          },
        ),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        overlayColor: WidgetStateProperty.all<Color>(
          Colors.purple.withAlpha(26),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          width: 2,
        ),
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      labelStyle: const TextStyle(
        color: Colors.black,
      ),
      floatingLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
