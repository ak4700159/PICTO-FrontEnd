import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class SessionSchedulerHandler {
  String baseUrl = "ws://bogota.iptime.org/session-scheduler";
  late StompClient _stompClient;
  bool _connected = false;
  Function? unsubscribeFunction;

  // private 생성자 선언 -> 외부에서 해당 클래스의 생성자 생성을 막는다.
  SessionSchedulerHandler._();
  static final SessionSchedulerHandler _handler = SessionSchedulerHandler._();
  factory SessionSchedulerHandler() {
    return _handler;
  }

  void connectWebSocket() {
    if(_connected) return;
    _stompClient = StompClient(
      config: StompConfig(
        reconnectDelay: Duration.zero,
        url: baseUrl,
        onConnect: _onConnect,
        onWebSocketError: _onError,
      ),
    );
    _stompClient.activate();
    _connected = true;
    print("[INFO]WebSocket connected successfully");
  }

  void disconnectedWebSocket() {
    if (unsubscribeFunction != null) {
      unsubscribeFunction!();
    }
    _stompClient.deactivate();
  }

  void _onError(err) {
    print("[ERROR]${err.toString()}\n");
    disconnectedWebSocket();
    print("[WARN]socket exited");
  }

  void _onConnect(StompFrame frame) {
    unsubscribeFunction = _stompClient.subscribe(
      destination: '/session',
      callback: (StompFrame frame) => {
        // 구독한 세션으로부터 전달 받은 메시지 처리
        // -> 화면에 반영 -> photo view model 생성 -> 리스트 추가 -> 화면 반영
        print("[INFO]${frame.body}\n")
      },
    );
  }

  // 위치 정보 전송 -> 세션 스케줄러에서 반영
  Future<void> sendLocation(int senderId, double lat, double lng) async {
    print('위치 전송 중 - 사용자: $senderId, 위도: $lat, 경도: $lng');

    try {
      final message = <String, Object>{
        "messageType": 'LOCATION',
        "senderId": senderId,
        "lat": lat,
        "lng": lng,
        "sendDatetime": DateTime.now().toUtc().millisecondsSinceEpoch,
      };

      final destination = '/send/session/location';
      final body = jsonEncode(message);

      _stompClient.send(
        destination: destination,
        body: body,
      );
      print('위치 전송 성공');
    } catch (e) {
      // throw SessionServiceException('위치 전송 실패: ${e.toString()}');
    }
  }
}
