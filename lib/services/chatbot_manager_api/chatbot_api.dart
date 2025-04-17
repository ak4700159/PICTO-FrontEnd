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
  Future<String> sendPrompt(String query, File? file1, File? file2 ) async {
    MultipartFile? sendFile1; MultipartFile? sendFile2;
    try {
      if(file1 != null) {
        final fileName = file1.path.split('/').last;
        final mimeType = lookupMimeType(file1.path) ?? 'application/octet-stream';
        sendFile1 = await MultipartFile.fromFile(file1.path, filename: fileName, contentType: MediaType.parse(mimeType));
      }
      if(file2 != null) {
        final fileName = file2.path.split('/').last;
        final mimeType = lookupMimeType(file2.path) ?? 'application/octet-stream';
        sendFile2= await MultipartFile.fromFile(file2.path, filename: fileName, contentType: MediaType.parse(mimeType));
      }
      final formData = FormData.fromMap({
        "text" : query,
        if(sendFile1 != null) "image1" : sendFile1,
        if(sendFile2 != null) "image2" : sendFile2,
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