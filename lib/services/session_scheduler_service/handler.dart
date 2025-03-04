import 'package:stomp_dart_client/stomp_dart_client.dart';

class SessionSchedulerHandler {
  String baseUrl = "ws://bogota.iptime.org/session-scheduler";
  final StompClient stompClient = StompClient(
    config: StompConfig(
      url: baseUrl,
      onConnect: _onConnect,
    ),
  );

  void _onConnect(StompFrame frame) {

  }

  Future<void> sendLocation(int senderId, double lat, double lng) async {
    print('위치 전송 중 - 사용자: $senderId, 위도: $lat, 경도: $lng');

    try {
      final message = SessionMessage(
        messageType: 'LOCATION',
        senderId: senderId,
        lat: lat,
        lng: lng,
        sendDatetime: DateTime.now().toUtc().millisecondsSinceEpoch,
      );

      final destination = '/send/session/location';
      final body = jsonEncode(message.toJson());

      _stompClient?.send(
        destination: destination,
        body: body,
      );
      print('위치 전송 성공');
    } catch (e) {
      _logger.onError('위치 전송 실패: $e'); 
      throw SessionServiceException('위치 전송 실패: ${e.toString()}');
    }
  }
}
