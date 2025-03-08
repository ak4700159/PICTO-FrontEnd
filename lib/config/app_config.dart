import 'package:flutter/material.dart';

class AppConfig {
  static final ip = "192.168.1.3";
  static final httpUrl = "http://$ip";
  static final wsUrl = "ws://$ip";

  // 최대 지연 시간
  static const int maxLatency = 3;

  // 1초마다 API 호출 허용
  static const int debounceSec = 1;

  static const int socketConnectionWait = 1;

  // theme data
  static const Color primarySeedColor = Color(0xFF6750A4);
  static const Color secondarySeedColor = Color(0xFF3871BB);
  static const Color tertiarySeedColor = Color(0xFF6CA450);

  // global
  static const Color backgroundColor = Colors.white;
  static const Color mainColor = Color(0xff7038ff);
}