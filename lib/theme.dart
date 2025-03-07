import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:picto_frontend/config/app_config.dart';

/*
* 03/07 : 현재는 테마 데이터를 활용하지 않고 있음
* 처음에 SeedColorScheme.fromSeeds를 통해 PICTO 메인 컬러만 지정해주면
* 자동으로 테마데이터를 생성할 줄 알았는데 아닌걸로 보임
* 공식 문서에서 보니깐 생성 가능한 시드가 정해져 있는걸로? 보임
* */


class PictoThemeData {
  // 시드를 통해 전역적으로 사용될 컬러 테마 자동 생성
  static final kColorScheme = SeedColorScheme.fromSeeds(
    brightness: Brightness.light,
    primaryKey: AppConfig.primarySeedColor,
    secondaryKey: AppConfig.secondarySeedColor,
    tertiaryKey: AppConfig.tertiarySeedColor,
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
