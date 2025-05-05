import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/models/photo_data.dart';
import 'package:picto_frontend/page_router.dart';
import 'package:picto_frontend/theme.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

import 'config/app_config.dart';
import 'models/chatbot_room.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 앱의 문서 디렉토리 경로 가져오기
  Directory dir = await getApplicationDocumentsDirectory();
  // hive 내장 데이터베이스 연동
  var path = dir.path;
  Hive
    ..init(path)
    ..registerAdapter((ChatbotRoomAdapter()))
    ..registerAdapter((PhotoDataAdapter()))
    ..registerAdapter(ChatbotMsgAdapter());

  // 환경 설정 파일 로드
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 상단 상태바, 하단 네비게이션 바 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.grey.shade100,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
  //   SystemUiOverlay.top,
  //   SystemUiOverlay.bottom,
  // ]);
  runApp(Picto());
}

class Picto extends StatelessWidget {
  Picto({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX 컨트롤러 등록
    AppConfig.enrollGetxController();
    return GetMaterialApp(
      title: 'PICTO APP',
      theme: PictoThemeData.init(),
      getPages: PageRouter.getPages(),
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,
    );
  }
}
