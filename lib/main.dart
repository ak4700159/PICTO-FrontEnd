import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/models/chatbot_msg.dart';
import 'package:picto_frontend/models/photo_data.dart';
import 'package:picto_frontend/page_router.dart';
import 'package:picto_frontend/push_notification.dart';
import 'package:picto_frontend/theme.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;

import 'config/app_config.dart';
import 'firebase_options.dart';
import 'models/chatbot_room.dart';
import 'models/comfyui_result_photo.dart';

// 반드시 main 함수 외부에 작성합니다. (= 최상위 수준 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print("Notification Received!");
  }
}

// 푸시 알림 메시지와 상호작용을 정의합니다.
Future<void> setupInteractedMessage() async {
  //앱이 종료된 상태에서 열릴 때 getInitialMessage 호출
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  //앱이 백그라운드 상태일 때, 푸시 알림을 탭할 때 RemoteMessage 처리
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

// FCM에서 전송한 data를 처리합니다. /message 페이지로 이동하면서 해당 데이터를 화면에 보여줍니다.
void _handleMessage(RemoteMessage message) {
  Future.delayed(const Duration(seconds: 1), () {
    Get.toNamed("/folder/invite", arguments: message);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 이미 초기화된 앱이 있는지 확인
  FirebaseApp app;
  try {
    app = Firebase.app(); // 기존 앱 존재 여부 확인
  } catch (e) {
    app = await Firebase.initializeApp(
      name: "PICTO-FRONTEND",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  //FCM 푸시 알림 관련 초기화
  PushNotification.init();

  //flutter_local_notifications 패키지 관련 초기화
  PushNotification.localNotiInit();

  //백그라운드 알림 수신 리스너
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //포그라운드 알림 수신 리스너
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print('Got a message in foreground');
    if (message.notification != null) {
      //flutter_local_notifications 패키지 사용
      PushNotification.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  //메시지 상호작용 함수 호출
  setupInteractedMessage();

  // 앱의 문서 디렉토리 경로 가져오기
  Directory dir = await getApplicationDocumentsDirectory();
  // hive 내장 데이터베이스 연동
  var path = dir.path;
  Hive
    ..init(path)
    ..registerAdapter((ChatbotRoomAdapter()))
    ..registerAdapter((PhotoDataAdapter()))
    ..registerAdapter(ChatbotMsgAdapter())
    ..registerAdapter(ComfyuiResultPhotoAdapter())
    ..registerAdapter(ComfyuiPhotoTypeAdapter())
    ..registerAdapter(ChatbotStatusAdapter());

  // 환경 설정 파일 로드
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // 달력 지역화
  await initializeDateFormatting();
  // 상단 상태바, 하단 네비게이션 바 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.grey.shade100,
      systemNavigationBarIconBrightness: Brightness.dark,
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
    // FCM 서버에 저장
    return GetMaterialApp(
      title: 'PICTO APP',
      theme: PictoThemeData.init(),
      getPages: PageRouter.getPages(),
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,
    );
  }
}
