import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final BoxDecoration backgroundGradient = const BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xFFEFBF04), Color(0xFFCEBA6B)], // light cream to yellow
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
);

final BoxDecoration whiteCard = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.r),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withAlpha(51),
      blurRadius: 34,
      offset: const Offset(0, 22),
    ),
  ],
);

final ThemeData campusQuestTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Anuphan',
  scaffoldBackgroundColor: Colors.transparent,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFEFBF04),
    primary: const Color(0xFFEFBF04),
    secondary: const Color(0xFFceba6b),
    error: const Color(0xFFcc3333),
    onPrimary: Colors.black,
    surface: Colors.white,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[200], // ⬅️ light grey AppBar from your CSS
    foregroundColor: Colors.black,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.black,
      fontFamily: 'Anuphan',
    ),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEFBF04),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFEFBF04),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF555555),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.r),
      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.r),
      borderSide: const BorderSide(color: Color(0xFFEFBF04), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: const TextStyle(color: Color(0xFFEFBF04)),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFFEFBF04),
    ), // label when focused
    hintStyle: const TextStyle(color: Colors.white70),
  ),

  iconTheme: const IconThemeData(color: Colors.black87),
);
