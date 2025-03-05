import 'dart:async';

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

    try {
      // 내부 저장된 데이터 로딩
      userId = preferences.getInt("userId");
      accessToken = preferences.getString("accessToken");
      refreshToken = preferences.getString("refreshToken");
      // 엑세스토큰 리프레쉬토큰 전달
      UserManagerHandler().initSettings(accessToken, refreshToken, userId);

      if (userId == null || accessToken == null || refreshToken == null) {
        // 로그인 화면으로 이동
        statusMsg.value = "로그인 페이지로 이동 중";
        // 토큰
        await Future.delayed(Duration(seconds: 5));
        Get.offNamed('/login');
      }

      _loadProfile();
      // _loadMapPhotos();
      _sessionConnect();
    } catch (e) {
      print("[ERROR] " + e.toString());
    }
  }

  void _loadProfile() async {

  }

  void _loadMapPhotos() async {
    // 지도 안에서 불러 올지는 대기
  }

  void _sessionConnect() async {
    SessionSchedulerHandler().connectWebSocket();
  }
}
