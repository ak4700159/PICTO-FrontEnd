import 'package:flutter/material.dart';

class PictoThemeData {
  // 시드를 통해 전역적으로 사용될 컬러 테마 자동 생성
  static final kColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff7a38ff),
    brightness: Brightness.light,
  );

  // primary :  메인 색상
  // secondary : 보조 색상
  static ThemeData init() {
    return ThemeData().copyWith(
      scaffoldBackgroundColor: kColorScheme.onPrimary,
      colorScheme: kColorScheme,
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: kColorScheme.onPrimaryContainer,
        foregroundColor: kColorScheme.primaryContainer,
      ),
      cardTheme: CardTheme().copyWith(
        color: kColorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorScheme.primaryContainer,
        ),
      ),
      textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: kColorScheme.onSecondaryContainer,
              fontSize: 50,
            ),
          ),
    );
  }
}
