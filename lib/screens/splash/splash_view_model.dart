import 'dart:async';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import '../map/google_map/google_map_view_model.dart';

// 1. 내부에 저장된 이메일, 비밀번호, 사용자 식별키, 엑세스 토큰, 리프레쉬 토큰을 로딩
// 2. 사용자 프로필 호출 -> 이때 리프레쉬 토큰까지 만료되었다면 재로그인.
// 3. 지도 로딩 전 필요한 사진 데이터 로딩
// 4. 세션 스케줄러와 연결
class SplashViewModel extends GetxController {
  Debouncer userSettingDebouncer = Debouncer(
    const Duration(seconds: AppConfig.throttleSec),
    initialValue: null,
    checkEquality: false,
  );
  RxString statusMsg = "로딩중...".obs;

  @override
  void onInit() async {
    userSettingDebouncer.values.listen((event) {
      logging();
    });
    super.onInit();
  }

  Future<void> logging() async {
    // step1. 위치 권환 획득
    final googleMapController = Get.find<GoogleMapViewModel>();
    await googleMapController.getPermission();

    // step2. 첫번째 접속 확인
    if (await _checkNullLoginData()) {
      print("[INFO] first connection");
      Get.offNamed('/login');
      return;
    }

    // step3. 토큰 이용해 사용자 api 호출 -> 사용자 정보 초기화
    await UserManagerApi().setUserAllInfo();
    // Get.find<FolderViewModel>().initFolder();
  }

  // 현재 가장 큰 문제 : 해당 로직 작동 X
  // 에러를 처리하는 것이 아니라 정상 반환을 통해 처리하는 것이 맞아보임
  // -> 엑세스 토큰 만료시 리프레쉬 토큰으로 복구가 안됨


  // return true = 처음 접속
  // return false = 이전에 로그인한 적이 있음
  Future<bool> _checkNullLoginData() async {
    try {
      await UserManagerApi().init();
    } catch (e) {
      statusMsg.value = "안녕하세요! 처음 접속하시네요 반가워요!";
      await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));
      // 가이드 화면으로 이동
      Get.offNamed('/login');
      return true;
    }
    return false;
  }
}
