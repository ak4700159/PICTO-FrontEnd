import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/screens/upload/upload_request.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class PreProcessorApi {
  PreProcessorApi._();

  static final PreProcessorApi _handler = PreProcessorApi._();

  factory PreProcessorApi() {
    return _handler;
  }

  // final String baseUrl = "${AppConfig.httpUrl}:8087";
  final String baseUrl = "http://220.69.155.209:8087";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 15)),
  )..interceptors.add(CustomInterceptor());

  // 유효성 검사 및 사진 전송 api 호출
  Future<dynamic> validatePhoto({required UploadRequest request}) async {
    try {
      final fileName = request.file.path.split('/').last;
      final mimeType = lookupMimeType(request.file.path) ?? 'application/octet-stream';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(request.file.path,
            filename: fileName, contentType: MediaType.parse(mimeType)),
        'request': MultipartFile.fromString(request.toJson(),
            contentType: MediaType('application', 'json')),
      });
      final response = await dio.post('$baseUrl/validate', data: formData);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
