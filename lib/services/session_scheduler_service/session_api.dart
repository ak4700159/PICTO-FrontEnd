import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/models/notice.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class SessionApi {
  SessionApi._();

  static final SessionApi _handler = SessionApi._();

  factory SessionApi() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8084/session-scheduler";
  // final String baseUrl = "http://${dotenv.env['PROCESSOR_IP']}:8084/session-scheduler";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 1),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 1)),
  )..interceptors.add(CustomInterceptor());

  void sendSharedPhoto({required double lat, required double lng, required int photoId}) async {
    try {
      final response = await dio.post('$baseUrl/shared', data: {
        "messageType" : "SHARE",
        "sendDatetime" : DateTime.now().millisecondsSinceEpoch,
        "photoId" : photoId,
        "lat" : lat,
        "lng" : lng,
        "senderId" : UserManagerApi().ownerId,
      });
    } catch(e) {
      showErrorPopup(e.toString());
    }
  }
}
