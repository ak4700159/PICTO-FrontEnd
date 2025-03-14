import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../screens/login/login_view_model.dart';
import '../screens/map/sub_screen/google_map_view_model.dart';
import '../screens/splash/splash_view_model.dart';
import '../services/session_scheduler_service/handler.dart';

class AppConfig {
  // 192.168.255.10 : LAB
  // bogota.iptime.org : HOME
  static final ip = "192.168.255.10";
  static final httpUrl = "http://$ip";
  static final wsUrl = "ws://$ip";

  // 최대 지연 시간
  static const int maxLatency = 3;

  // 1초마다 API 호출 허용
  static const int debounceSec = 1;

  // 화면 정지
  static const int stopScreenSec = 3;

  static const int socketConnectionWaitSec = 1;

  // theme data
  static const Color primarySeedColor = Color(0xFF6750A4);
  static const Color secondarySeedColor = Color(0xFF3871BB);
  static const Color tertiarySeedColor = Color(0xFF6CA450);

  // global
  static const Color backgroundColor = Colors.white;
  static const Color mainColor = Color(0xff7038ff);

  // GetX 등록
  static void enrollGetxController (){
    final sessionController = Get.put<SessionSchedulerHandler>(SessionSchedulerHandler());
    final splashController = Get.put<SplashViewModel>(SplashViewModel());
    final googleMapController = Get.put<GoogleMapViewModel>(GoogleMapViewModel());
    final loginController = Get.put<LoginViewModel>(LoginViewModel());
  }
}