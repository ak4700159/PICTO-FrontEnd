import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:http_parser/http_parser.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/services/chatbot_manager_service/prompt_response.dart';
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
        connectTimeout: const Duration(seconds: 80),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 80)),
  )..interceptors.add(CustomInterceptor());

  // 프롬프트 전달
  Future<PromptResponse?> sendPrompt(String query, List<Uint8List> imagesData) async {
    List<MultipartFile> sendFiles = [];
    print("[INFO] image data length : ${imagesData.length}");
    try {
      for (int i = 0; i < imagesData.length; i++) {
        sendFiles.add(
          MultipartFile.fromBytes(
            imagesData[i] as List<int>,
            filename: 'image${i + 1}.jpg', // 적절한 이름 설정
            contentType: MediaType('image', 'jpeg'), // MIME 타입 설정
          ),
        );
      }
      print("[INFO] send files length : ${sendFiles.length}");
      final formData = FormData.fromMap({
        "text":
            "$query lat:${Get.find<GoogleMapViewModel>().currentLat.value} lng:${Get.find<GoogleMapViewModel>().currentLng.value}",
        if (sendFiles.isNotEmpty && imagesData.isNotEmpty) "image1": sendFiles[0],
        if (sendFiles.length > 1 && imagesData.isNotEmpty) "image2": sendFiles[1],
      });
      final response = await dio.post("$baseUrl/process", data: formData);
      Map<String, dynamic> data = response.data;
      return PromptResponse.fromJson(data);
    } catch (e) {
      showErrorPopup("프롬프트 오류 발생");
      rethrow;
    }
  }
}
