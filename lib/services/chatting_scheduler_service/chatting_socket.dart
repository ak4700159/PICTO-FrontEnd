import 'dart:async';

import 'package:get/get.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../config/app_config.dart';

// 채팅방마다 스케줄러 작동
class ChattingSocket {
  final baseUrl = "${AppConfig.httpUrl}:8085/ws-connected";
  bool connected = false;
  Function? unsubscribeFunction;
  StompFrameCallback receive;
  late int folderId;
  late StompClient _stompClient;

  ChattingSocket({required this.folderId, required this.receive}) {
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
  }

  void connectWebSocket() async {
    // 접속 중인지 확인
    if (_stompClient.connected) {
      print("[INFO] already connected\n");
      connected = true;
      return;
    }

    // 연결 시도 및 타이머 등록
    try {
      _stompClient.activate();
      connected = true;
    } catch (e) {
      print('[DEBUG] web socket server missing');
    }
  }

  void disconnectWebSocket() {
    if (unsubscribeFunction != null) {
      unsubscribeFunction!();
    }
    _stompClient.deactivate();
    connected = false;
  }

  void _onError(err) {
    disconnectWebSocket();
  }

  void _onConnect(StompFrame frame) {
    unsubscribeFunction = _stompClient.subscribe(
      destination: '/subscribe/chat.$folderId',
      callback: receive,
    );
    print("[INFO] folder$folderId subscribe success\n");
  }

  void _onDone() {
    disconnectWebSocket();
  }


}
