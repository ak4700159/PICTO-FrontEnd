import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/location_msg.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../models/photo.dart';
import '../../screens/main_frame_view_model.dart';
import '../../screens/map/google_map/marker/marker_converter.dart';

// _stompClient.connected 의 네트워크 지연 때문에 값이 늦게 들어올 수 있다
class SessionSocket extends GetxController {
  final String baseUrl = "${AppConfig.httpUrl}:8084/session-scheduler";
  // final String baseUrl = "http://${dotenv.env['PROCESSOR_IP']}:8084/session-scheduler";
  late StompClient _stompClient;
  late Timer _timer;
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
    // 접속 중인지 확인
    if (_stompClient.connected) {
      print("[INFO] already connected\n");
      connected.value = true;
      return;
    }

    // 연결 시도 및 타이머 등록
    try {
      _stompClient.activate();
      await Future.delayed(Duration(seconds: AppConfig.socketConnectionWaitSec));
      if (!_stompClient.connected) return;
      // 5초마다 위치 전송
      Timer.periodic(Duration(seconds: AppConfig.locationSendPeriod), (timer) async {
        _timer = timer;
        Position position = await Geolocator.getCurrentPosition();
        final mapViewModel = Get.find<MapViewModel>();
        if(mapViewModel.navigationBarCurrentIndex.value == 2) {
          sendLocation(UserManagerApi().ownerId!, position.latitude, position.longitude);
        }
      });
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
    _timer.cancel();
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
      headers: {"User-Id": UserManagerApi().ownerId.toString()},
      destination: '/session',
      callback: (StompFrame frame) {
        // 구독한 세션으로부터 전달 받은 메시지 처리
        // -> 화면에 반영 -> photo view model 생성 -> 리스트 추가 -> 화면 반영
        Photo sharedPhoto = Photo.fromJson(jsonDecode(frame.body!));
        MarkerConverter().addAroundPhoto(sharedPhoto);
        print("[INFO] ${frame.body}\n");
      },
    );
    print("[INFO] subscribe success\n");
  }

  void _onDone() {
    disconnectWebSocket();
  }

  // 위치 정보 전송 -> 세션 스케줄러에서 반영
  Future<void> sendLocation(int senderId, double lat, double lng) async {
    print('[INFO] sending location - USER ID: $senderId, lat: $lat, lng: $lng');
    try {
      final message = LocationMsg(
          messageType: "LOCATION",
          senderId: senderId,
          lat: lat,
          lng: lng,
          sendDatetime: DateTime.now().toUtc().millisecondsSinceEpoch,
      );

      final destination = '/send/session/location';
      final body = jsonEncode(message.toJson());

      _stompClient.send(
        destination: destination,
        body: body,
      );
      // print('[INFO] send location to session');
    } catch (e) {
      showErrorPopup(e.toString());
      // print('[ERROR] ${e.toString()}');
    }
  }
}
