import 'dart:async';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/socket_function_controller.dart';


// 1. 내부에 저장된 이메일, 비밀번호, 사용자 식별키, 엑세스 토큰, 리프레쉬 토큰을 로딩
// 2. 사용자 프로필 호출 -> 이때 리프레쉬 토큰까지 만료되었다면 재로그인.
// 3. 지도 로딩 전 필요한 사진 데이터 로딩
// 4. 세션 스케줄러와 연결
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

  // step0. 내장 데이터 로딩(사용자 아이디, 토큰), api 리스너 등록
  @override
  void onInit() async {
    userSettingThrottle.values.listen((event) {
      logging();
    });
    preferences = await SharedPreferences.getInstance();
    userId = preferences.getInt("User-Id");
    accessToken = preferences.getString("Access-Token");
    refreshToken = preferences.getString("Refresh-Token");
    super.onInit();
  }

  Future<void> logging() async {
    // step1. 위치 권환 획득
    final googleMapController = Get.find<GoogleMapViewModel>();
    await googleMapController.getPermission();

    // step2. 첫번째 접속 확인
    if (await checkNullLoginData()) {return;}

    // step3. 토큰 이용해 사용자 api 호출 -> 사용자 정보 초기화
    try {
      // step3-1. 엑세스 토큰으로 접근.
      print("[INFO]엑세트 토큰 인증 시도");
      await setUserConfigThroughToken(isAccessToken: true);
    } on DioException catch (e) {
      try {
        // step3-2. 리프레시 토큰으로 접근
        print("[WARN]엑세트 토큰 인증 실패");
        await setUserConfigThroughToken(isAccessToken: false);
      } on DioException catch (e) {
        await recoverAccessToken(e);
      }
    }
  }

  Future<void> setUserConfigThroughToken({required bool isAccessToken}) async {
    statusMsg.value = isAccessToken ? "엑세스 토큰 전달..." : "리프레쉬 트콘 전달...";
    await UserManagerHandler().setUserAllInfo(isAccessToken);
    await Future.delayed(Duration(seconds: AppConfig.maxLatency));
    // 엑세스 토큰 정상 작동
    socketInterceptor.callSession(connected: true);
    Get.offNamed('/map');
  }

          // 현재 가장 큰 문제 : 해당 로직 작동 X
          // 에러를 처리하는 것이 아니라 정상 반환을 통해 처리하는 것이 맞아보임
          // -> 엑세스 토큰 만료시 리프레쉬 토큰으로 복구가 안됨
  Future<void> recoverAccessToken(DioException e) async {
    print("[DEBUG]${e.response?.data} ---[DEBUG END]\n");
    if (e.message?.contains("[TOKEN]") ?? false) {
      // 다시 발급 받은 엑세스 토큰 저장
      final preferences = await SharedPreferences.getInstance();
      String newAccessToken = e.message!.substring("[TOKEN]".length);
      UserManagerHandler().accessToken = newAccessToken;
      await preferences.setString("Access-Token", newAccessToken);
      setUserConfigThroughToken(isAccessToken: true);
      await Future.delayed(Duration(seconds: AppConfig.maxLatency));
      Get.offNamed('/map');
    } else {
      // 리프레쉬 토큰 만료
      Get.offNamed('/login');
    }
  }

  // return true = 처음 접속
  // return false = 이전에 로그인한 적이 있음
  Future<bool> checkNullLoginData() async {
    await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));
    if (userId == null || accessToken == null || refreshToken == null) {
      statusMsg.value = "처음 접속하시네요! 반가워요.";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));

      statusMsg.value = "로그인 화면으로 이동";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));

      Get.offNamed('/login');
      return true;
    }
    // 이전에 로그인한 정보를 바탕으로 api 토큰 세팅
    UserManagerHandler().initSettings(accessToken, refreshToken, userId);
    return false;
  }
}
