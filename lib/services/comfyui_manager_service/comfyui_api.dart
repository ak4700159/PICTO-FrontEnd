import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/services/comfyui_manager_service/comfyui_response.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class ComfyuiAPI {
  ComfyuiAPI._();

  static final ComfyuiAPI _handler = ComfyuiAPI._();

  factory ComfyuiAPI() {
    return _handler;
  }

  // final String baseUrl = "${AppConfig.httpUrl}:8090";
  final String baseUrl = "http://${dotenv.env['PROCESSOR_IP']}:8086";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 10)),
  )..interceptors.add(CustomInterceptor());

  Future<ComfyuiResponse> removePhoto({required String prompt, required XFile original}) async {
    final originalData = await original.readAsBytes();
    Uint8List result = Uint8List(0);
    try {
      final fileName = original.path.split('/').last;
      final mimeType = lookupMimeType(original.path) ?? 'application/octet-stream';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          original.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
        'categories': MultipartFile.fromString(prompt, contentType: MediaType('application', 'json')),
      });
      final response = await dio.post(original.path, data: formData);
      // 데이터 담기
      // await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      showErrorPopup(e.toString());
      rethrow;
    }
    return ComfyuiResponse(result: result, original: originalData);
  }

  Future<ComfyuiResponse> upscalingPhoto({required XFile original}) async {
    final originalData = await original.readAsBytes();
    Uint8List result = Uint8List(0);
    try {
      final fileName = original.path.split('/').last;
      final mimeType = lookupMimeType(original.path) ?? 'application/octet-stream';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(original.path,
            filename: fileName, contentType: MediaType.parse(mimeType)),
      });
      final response = await dio.post(original.path, data: formData);
      // 데이터 담기
      // await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      showErrorPopup(e.toString());
      rethrow;
    }
    return ComfyuiResponse(result: result, original: originalData);
  }
}
