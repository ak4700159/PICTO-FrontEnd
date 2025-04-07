import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class PreProcessorHandler {
  PreProcessorHandler._();

  static final PreProcessorHandler _handler = PreProcessorHandler._();

  factory PreProcessorHandler() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8081/user-manager";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 1000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 3000)),
  )..interceptors.add(CustomInterceptor());

  // 유효성 검사 및 사진 전송 api 호출
  Future<dynamic> savePhoto() async {
    return "";
  }
}
