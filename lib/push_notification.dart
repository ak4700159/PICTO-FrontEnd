import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PushNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static String? _token;

  //권한 요청
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    _token = await _firebaseMessaging.getToken(); //토큰 얻기
    print("device token: ${_token ?? "emp"}");
  }

//   flutter_local_notifications 패키지 관련 초기화
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        // onDidReceiveLocalNotification: (id, title, body, payload) => null,
        );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);

    const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      'high_importance_channel', // 임의의 id
      'High Importance Notifications', // 설정에 보일 채널명
      description: 'This channel is used for important notifications.', // 설정에 보일 채널 설명
      importance: Importance.max,
    );

    // Notification Channel을 디바이스에 생성
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

//   포그라운드로 알림을 받아서 알림을 탭했을 때 페이지 이동
  static void onNotificationTap(NotificationResponse notificationResponse) {
    Get.toNamed("/folder/invite", arguments: notificationResponse);
  }

  //   포그라운드에서 푸시 알림을 전송받기 위한 패키지 푸시 알림 발송
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'pomo_timer_alarm_1', 'pomo_timer_alarm',
        channelDescription: '',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails,
        payload: payload);
  }
}
