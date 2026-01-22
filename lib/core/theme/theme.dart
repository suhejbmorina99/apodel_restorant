import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    onPrimary: Color.fromARGB(255, 33, 33, 33), // Te gjitha tekstet
    surface:
        Color.fromARGB(255, 245, 245, 245), // Te gjitha backgroundet kryesore
    inversePrimary: Color.fromARGB(
        255, 255, 255, 255), // Per navigation bottom bar e kom perdor
    primaryContainer:
        Color.fromARGB(255, 255, 255, 255), // Per card background color
    surfaceTint:
        Color.fromARGB(255, 255, 229, 169), // Per modal overlay app bar
    secondary: Colors.black38, // Per text si disabled
    primary: Colors.black12, // Per buttons ne exercises
    onSecondary: Colors.black, // Per buttons ne exercises
    onSurfaceVariant:
        Color.fromARGB(255, 238, 238, 238), // Per questions border
    tertiary: Colors.black54, // Per reverse icon ne exercise detail
    primaryFixed: Colors.white, // Per apple login icon
    tertiaryFixed: Color.fromARGB(220, 92, 92, 92),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    onPrimary: Color.fromARGB(255, 255, 255, 255), // Te gjitha tekstet
    surface: Color.fromARGB(255, 33, 33, 33), // Te gjitha backgroundet kryesore
    inversePrimary: Color.fromARGB(
        255, 41, 41, 41), // Per navigation bottom bar e kom perdor
    primaryContainer:
        Color.fromARGB(255, 41, 41, 41), // Per card background color
    surfaceTint: Color.fromARGB(255, 41, 41, 41), // Per modal overlay app bar
    secondary: Colors.white38, // Per text si disabled
    primary: Colors.white24, // Per buttons ne exercises
    onSecondary: Colors.white, // Per buttons ne exercises
    onSurfaceVariant: Color.fromARGB(80, 255, 245, 222), // Per questions border
    tertiary: Color.fromARGB(
        255, 255, 255, 255), // Per reverse icon ne exercise detail
    primaryFixed: Colors.black,
    tertiaryFixed: Color.fromARGB(220, 255, 255, 255), // Per apple login icon
  ),
);
