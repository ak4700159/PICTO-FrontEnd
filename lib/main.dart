import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/page_router.dart';
import 'package:picto_frontend/theme.dart';

import 'config/app_config.dart';
import 'models/chatbot_list.dart';

void main() async {
  // hive 내장 데이터베이스 연동
  var path = Directory.current.path;
  Hive
    ..init(path)
    ..registerAdapter((ChatbotListAdapter()))
    ..registerAdapter(ChatbotMsgAdapter());
  // 데이터를 사용할 때 박스(DB) 오픈 -> 메모리 로딩
  var box = await Hive.openLazyBox('chatbot');

  // 환경 설정 파일 로드
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 상단 상태바, 하단 네비게이션 바 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppConfig.mainColor,
    ),
  );
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
