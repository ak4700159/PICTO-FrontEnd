import 'dart:convert';

import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/services/session_scheduler_service/location_message.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

// _stompClient.connected 의 네트워크 지연 때문에 값이 늦게 들어올 수 있다
class SessionSchedulerHandler extends GetxController {
  String baseUrl = "${AppConfig.httpUrl}:8084/session-scheduler";
  late StompClient _stompClient;
  RxBool connected = false.obs;
  Function? unsubscribeFunction;

  @override
  void onInit() {
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        reconnectDelay: Duration.zero,
        url: baseUrl,
        onConnect: _onConnect,
        onWebSocketError: _onError,
        // 서버에서 강제 종료된 경우 호출되는 콜백함수
        onWebSocketDone: _onDone,
      ),
    );
    super.onInit();
  }

  void connectWebSocket() async {
    if (_stompClient.connected) {
      print("[INFO] already connected\n");
      connected.value = true;
      return;
    }

    try {
      _stompClient.activate();
      await Future.delayed(Duration(seconds: AppConfig.socketConnectionWait));
      if (!_stompClient.connected) return;
      print("[INFO] web socket activate\n");
      connected.value = true;
    } catch (e) {
      print('[DEBUG] web socket server missing');
    }
  }

  void disconnectWebSocket() {  
    if (unsubscribeFunction != null) {
      unsubscribeFunction!();
      print("[INFO] session unsubscribed");
    }
    _stompClient.deactivate();
    connected.value = false;
    print("[INFO] web socket inactivate");
  }

  void _onError(err) {
    print("[ERROR]${err.toString()}\n");
    disconnectWebSocket();
    print("[WARN] socket exited");
  }

  void _onConnect(StompFrame frame) {
    unsubscribeFunction = _stompClient.subscribe(
      headers: {"User-Id": UserManagerHandler().ownerId.toString()},
      destination: '/session',
      callback: (StompFrame frame) => {
        // 구독한 세션으로부터 전달 받은 메시지 처리
        // -> 화면에 반영 -> photo view model 생성 -> 리스트 추가 -> 화면 반영
        print("[INFO]${frame.body}\n")
      },
    );
    print("[INFO] subscribe success\n");
  }

  void _onDone() {
    disconnectWebSocket();
  }

  // 위치 정보 전송 -> 세션 스케줄러에서 반영
  Future<void> sendLocation(int senderId, double lat, double lng) async {
    print('위치 전송 중 - 사용자: $senderId, 위도: $lat, 경도: $lng');

    try {
      final message = LocationMsg(
          messageType: "LOCATION",
          senderId: senderId,
          lat: lat,
          lng: lng,
          sendDatetime: DateTime.now().toUtc().millisecondsSinceEpoch);

      final destination = '/send/session/location';
      final body = jsonEncode(message.toJson());

      _stompClient.send(
        destination: destination,
        body: body,
      );
      print('[INFO] send location to session');
    } catch (e) {
      print('[ERROR] ${e.toString()}');
    }
  }
}
