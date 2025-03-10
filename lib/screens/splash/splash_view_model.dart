import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../services/socket_function_controller.dart';

/*
1. 내부에 저장된 이메일, 비밀번호, 사용자 식별키, 엑세스 토큰, 리프레쉬 토큰을 로딩
2. 사용자 프로필 호출 -> 이때 리프레쉬 토큰까지 만료되었다면 재로그인.
3. 지도 로딩 전 필요한 사진 데이터 로딩
4. 세션 스케줄러와 연결
 */

class SplashViewModel extends GetxController {
  SocketFunctionController socketInterceptor = SocketFunctionController();
  Throttle userSettingThrottle = Throttle(
    const Duration(seconds: AppConfig.debounceSec),
    initialValue: null,
    checkEquality: false,
  );

  late SharedPreferences preferences;

  RxString statusMsg = "로딩중...".obs;

  int? userId;
  String? accessToken;
  String? refreshToken;

  @override
  void onInit() async {
    preferences = await SharedPreferences.getInstance();
    userId = preferences.getInt("User-Id");
    accessToken = preferences.getString("Access-Token");
    refreshToken = preferences.getString("Refresh-Token");
    //
    userSettingThrottle.values.listen((event) {
      logging();
    });
    super.onInit();
  }

  Future<void> setUserConfigThroughToken({required bool isAccessToken}) async {
    statusMsg.value = isAccessToken ? "엑세스 토큰 전달..." : "리프레쉬 트콘 전달...";
    await Future.delayed(Duration(seconds: AppConfig.maxLatency));
    await UserManagerHandler().setUserAllInfo(isAccessToken);
    // 엑세스 토큰 정상 작동
    socketInterceptor.callSession(connected: true);
    Get.offNamed('/map');
  }

  Future<void> recoverAccessToken(DioException e) async {
    /*
          * 현재 가장 큰 문제 : 해당 로직 작동 X
          * 에러를 처리하는 것이 아니라 정상 반환을 통해 처리하는 것이 맞아보임
          * -> 엑세스 토큰 만료시 리프레쉬 토큰으로 복구가 안됨
          * */
    print("[DEBUG]${e.response?.data} ---[DEBUG END]\n");
    if (e.message?.contains("[token]") ?? false) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
          "Access-Token", e.message?.substring(8) ?? "");
      // 리프레쉬 토큰 정상 작동
      socketInterceptor.callSession(connected: true);
      await Future.delayed(Duration(seconds: AppConfig.maxLatency));
      Get.offNamed('/map');
    } else {
      // 리프레쉬 토큰 만료
      Get.offNamed('/login');
    }
  }

  Future<void> autoLogin() async {
    await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));
    if (userId == null || accessToken == null || refreshToken == null) {
      statusMsg.value = "자동 로그인 실패";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));

      statusMsg.value = "로그인 화면으로 이동";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));

      Get.offNamed('/login');
    }
  }

  Future<void> logging() async {
    await autoLogin();
    UserManagerHandler().initSettings(accessToken, refreshToken, userId);
    // userSettingThrottle.setValue(null);
    // 사용자 정보(태그, 사진, 기본 설정) 블러오기
    try {
      print("[INFO]엑세트 토큰 인증 시도");
      await setUserConfigThroughToken(isAccessToken: true);
    } on DioException catch (e) {
      try {
        print("[WARN]엑세트 토큰 인증 실패");
        await setUserConfigThroughToken(isAccessToken: false);
      } on DioException catch (e) {
        await recoverAccessToken(e);
      }
    }
  }
}
