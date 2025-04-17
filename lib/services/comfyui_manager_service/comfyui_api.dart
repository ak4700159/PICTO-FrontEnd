import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class ComfyuiAPI{
  ComfyuiAPI._();

  static final ComfyuiAPI _handler = ComfyuiAPI._();

  factory ComfyuiAPI() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8090";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 10)),
  )..interceptors.add(CustomInterceptor());
}