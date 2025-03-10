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
  // 유저 세팅 함수 최적화
  final userSettingDebouncer = Debouncer(
    const Duration(seconds: AppConfig.debounceSec),
    initialValue: null,
    checkEquality: false,
  );
  late SharedPreferences preferences;
  var statusMsg = "로딩중...".obs;
  int? userId;
  String? accessToken;
  String? refreshToken;

  @override
  void onInit() async {
    preferences = await SharedPreferences.getInstance();

    super.onInit();
  }

  // 뷰모델 생성자
  SplashViewModel() {
    // 로그인 api 호출 및 상태 변화 처리 리스너 등록
    userSettingDebouncer.values.listen((event) async {
      SocketFunctionController interceptor = SocketFunctionController();

      // 사용자 정보(태그, 사진, 기본 설정) 블러오기
      try {
        statusMsg.value = "엑세스 토큰 전달...";
        await UserManagerHandler().setUserAllInfo(true);
        // 엑세스 토큰 정상 작동
        interceptor.execSession(connected: true);
        await Future.delayed(Duration(seconds: AppConfig.maxLatency));
        Get.offNamed('/map');
        return;
      } on DioException catch (e) {
        try {
          print("[WARN]엑세트 토큰 인증 실패");
          statusMsg.value = "리프레쉬 토큰 전달...";
          await UserManagerHandler().setUserAllInfo(false);
        } on DioException catch (e) {
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
            interceptor.execSession(connected: true);
            await Future.delayed(Duration(seconds: AppConfig.maxLatency));
            Get.offNamed('/map');
            return;
          }
        }
        // 리프레쉬 토큰 만료
        Get.offNamed('/login');
        return;
      }
    });
  }

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
    await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));
    if (userId == null || accessToken == null || refreshToken == null) {
      statusMsg.value = "자동 로그인 실패";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));

      statusMsg.value = "로그인 화면으로 이동";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));

      Get.offNamed('/login');
      return;
    }
    //
    userSettingDebouncer.setValue(null);
  }

  // 엑세스 토큰 사용

  // 리프레쉬 토큰 사용

  // 토큰 복구
}
