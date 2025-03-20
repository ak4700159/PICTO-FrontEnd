import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/screens/map/map_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/marker_converter.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';

import '../screens/login/login_view_model.dart';
import '../screens/map/sub_screen/google_map/google_map_view_model.dart';
import '../screens/map/sub_screen/selection_bar_view_model.dart';
import '../screens/splash/splash_view_model.dart';
import '../services/session_scheduler_service/handler.dart';

class AppConfig {
  // bogota.iptime.org : HOME
  // 192.168.255.10 : LAB
  static final ip = "bogota.iptime.org";
  static final httpUrl = "http://$ip";
  static final wsUrl = "ws://$ip";

  // 최대 지연 시간
  static const int maxLatency = 3;

  // 1초마다 API 호출 허용
  static const int throttleSec = 3;

  // 화면 정지
  static const int stopScreenSec = 3;

  static const int socketConnectionWaitSec = 1;

  // location send period
  static const int locationSendPeriod = 10;

  // theme data
  static const Color primarySeedColor = Color(0xFF6750A4);
  static const Color secondarySeedColor = Color(0xFF3871BB);
  static const Color tertiarySeedColor = Color(0xFF6CA450);

  // global
  static const Color backgroundColor = Colors.white;
  static const Color mainColor = Color(0xff7038ff);

  // GetX 등록
  static void enrollGetxController () {
    // 필수 컨트롤러 ----------------------
    final sessionHandler = Get.put<SessionSchedulerHandler>(SessionSchedulerHandler());
    final splashViewModel = Get.put<SplashViewModel>(SplashViewModel());
    final googleViewModel = Get.put<GoogleMapViewModel>(GoogleMapViewModel());
    final loginViewModel = Get.put<LoginViewModel>(LoginViewModel());

    // 로그인 이후 사용될 컨트롤러 ----------------------
    final selectionViewModel = Get.put<SelectionBarViewModel>(SelectionBarViewModel());
    final mapViewModel = Get.put<MapViewModel>(MapViewModel());

    // 사용자 정보 ----------------------
    final profileViewModel = Get.put<ProfileViewModel>(ProfileViewModel());
    final userConfig = Get.put<UserConfig>(UserConfig());
  }
}