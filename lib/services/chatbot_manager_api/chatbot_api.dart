import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class ChatbotAPI {
  ChatbotAPI._();

  static final ChatbotAPI _handler = ChatbotAPI._();

  factory ChatbotAPI() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8089";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 10)),
  )..interceptors.add(CustomInterceptor());

  // 프롬프트 전달
  Future<String> sendPrompt(String query, List<File>? files ) async {
    List<MultipartFile> sendFiles = [];
    try {
      if(files != null) {
        for(File file in files) {
          final fileName = file.path.split('/').last;
          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          sendFiles.add(await MultipartFile.fromFile(file.path, filename: fileName, contentType: MediaType.parse(mimeType)));
        }
      }
      final formData = FormData.fromMap({
        "text" : query,
        if (sendFiles.isNotEmpty && files != null) "image1": sendFiles[0],
        if (sendFiles.length > 1 && files != null) "image2": sendFiles[1],
      });
      final response = await dio.post("$baseUrl/process",  data: formData);
      String data = response.data["response"];
      return data;
    } catch(e) {
      showErrorPopup(e.toString());
    }
    return "잘못된 양식입니다.";
  }
}