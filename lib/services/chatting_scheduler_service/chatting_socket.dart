import 'dart:async';
import 'dart:convert';

import 'package:picto_frontend/models/chatting_msg.dart';
import 'package:picto_frontend/utils/popup.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../config/app_config.dart';

// 채팅방마다 스케줄러 작동
class ChattingSocket {
  late int folderId;
  late StompClient _stompClient;

  final baseUrl = "${AppConfig.httpUrl}:8085/ws-connected";
  StompFrameCallback receive;
  Function? unsubscribeFunction;
  bool connected = false;

  ChattingSocket({required this.folderId, required this.receive}) {
    try {
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
      connectWebSocket();
      print("[INFO] chatting socket[$folderId] connected success");
    } catch(e) {
      showErrorPopup(e.toString());
    }
  }
  void connectWebSocket() async {
    if (_stompClient.connected) {
      print("[INFO] already connected\n");
      connected = true;
      return;
    }
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

  // 채팅 전송
  Future<void> sendChatMsg(ChatMsg msg) async {
    try {
      final destination = '/publish/chat.$folderId';
      final body = jsonEncode(msg.toJson());
      _stompClient.send(
        destination: destination,
        body: body,
      );
    } catch (e) {
      showErrorPopup(e.toString());
    }
  }
}
