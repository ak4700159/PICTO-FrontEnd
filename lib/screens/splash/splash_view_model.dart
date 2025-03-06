import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

/*
1. 내부에 저장된 이메일, 비밀번호, 사용자 식별키, 엑세스 토큰, 리프레쉬 토큰을 로딩
2. 사용자 프로필 호출 -> 이때 리프레쉬 토큰까지 만료되었다면 재로그인.
3. 지도 로딩 전 필요한 사진 데이터 로딩
4. 세션 스케줄러와 연결
 */

class SplashViewModel extends GetxController {
  late SharedPreferences preferences;
  var statusMsg = "로딩중...".obs;
  User? owner;

  void initStatus() async {
    preferences = await SharedPreferences.getInstance();
    int? userId;
    String? accessToken;
    String? refreshToken;

    // 내부 저장된 데이터 로딩
    userId = preferences.getInt("User-Id");
    accessToken = preferences.getString("Access-Token");
    refreshToken = preferences.getString("Refresh-Token");

    // 엑세스토큰 리프레쉬토큰 세팅
    UserManagerHandler().initSettings(accessToken, refreshToken, userId);
    await Future.delayed(Duration(seconds: 3));
    if (userId == null || accessToken == null || refreshToken == null) {
      statusMsg.value = "자동 로그인 실패";
      await Future.delayed(Duration(seconds: 3));

      statusMsg.value = "로그인 화면으로 이동";
      await Future.delayed(Duration(seconds: 3));

      Get.offNamed('/login');
      return;
    }

    // 사용자 정보(태그, 사진, 기본 설정) 블러오기
    try {
      statusMsg.value = "엑세스 토큰 전달...";
      await Future.delayed(Duration(seconds: 3));
      UserManagerHandler().setUserAllInfo(true);
    } on DioException catch (e) {
      try {
        print("[WARN]엑세트 토큰 인증 실패");
        statusMsg.value = "리프레쉬 토큰 전달...";
        await Future.delayed(Duration(seconds: 3));
        UserManagerHandler().setUserAllInfo(false);
      } on DioException catch (e) {
        if (e.message?.contains("[token]") ?? false) {
          // 리프레쉬 토큰 정상 작동
          SessionSchedulerHandler().connectWebSocket();
          Get.offNamed('/map');
          return;
        }
      }

      // 리프레쉬 토큰 만료
      SessionSchedulerHandler().connectWebSocket();
      Get.offNamed('/login');
      return;
    }

    // 엑세스 토큰 정상 작동
    SessionSchedulerHandler().connectWebSocket();
    Get.offNamed('/map');
  }
}
