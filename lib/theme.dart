import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

class PictoThemeData {
  static const Color primarySeedColor = Color(0xFF6750A4);
  static const Color secondarySeedColor = Color(0xFF3871BB);
  static const Color tertiarySeedColor = Color(0xFF6CA450);
  static const Color backgroundColor = Colors.white;
  static const Color mainColor = Color(0xff7038ff);

  // 시드를 통해 전역적으로 사용될 컬러 테마 자동 생성
  static final kColorScheme = SeedColorScheme.fromSeeds(
    brightness: Brightness.light,
    primaryKey: primarySeedColor,
    secondaryKey: secondarySeedColor,
    tertiaryKey: tertiarySeedColor,
    tones: FlexTones.vivid(Brightness.light),
  );

  // primary :  메인 색상
  // secondary : 보조 색상
  static ThemeData init() {
    return ThemeData().copyWith(
      scaffoldBackgroundColor: kColorScheme.onPrimary,
      colorScheme: kColorScheme,
      // appBarTheme: const AppBarTheme().copyWith(
      //   backgroundColor: kColorScheme.onPrimaryContainer,
      //   foregroundColor: kColorScheme.primaryContainer,
      // ),
      // cardTheme: CardTheme().copyWith(
      //   color: kColorScheme.secondaryContainer,
      //   margin: const EdgeInsets.symmetric(
      //     horizontal: 16,
      //     vertical: 8,
      //   ),
      // ),
      // elevatedButtonTheme: ElevatedButtonThemeData(
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: kColorScheme.primaryContainer,
      //   ),
      // ),
    );
  }
}
