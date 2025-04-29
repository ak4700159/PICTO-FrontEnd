import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/services/comfyui_manager_service/comfyui_response.dart';
import 'package:picto_frontend/utils/popup.dart';

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
        connectTimeout: const Duration(seconds: 120),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 120)),
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
        'categories':
            MultipartFile.fromString(prompt, contentType: MediaType('application', 'json')),
      });
      final response = await dio.post("$baseUrl/upload/inpaint", data: formData);
      if (response.data["success"] == true) {
        result = await downloadImageBytes("$baseUrl/static/results/${response.data["result"]}");
        print("[INFO] result image bytes : ${result.lengthInBytes}");
      }
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
      print("[INFO] original image bytes : ${originalData.lengthInBytes}");
      final response = await dio.post("$baseUrl/upload/upscale", data: formData);
      if (response.data["success"] == true) {
        result = await downloadImageBytes("$baseUrl/static/results/${response.data["result"]}");
        print("[INFO] result image bytes : ${result.lengthInBytes}");
      }
    } catch (e) {
      showErrorPopup(e.toString());
      rethrow;
    }
    return ComfyuiResponse(result: result, original: originalData);
  }

  // 이미지 url에서 사진 데이터만 받아오기
  Future<Uint8List> downloadImageBytes(String imageUrl) async {
    try {
      Dio dio = Dio();

      // `ResponseType.bytes` 로 설정해야 바이너리 응답을 받을 수 있음
      final response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      } else {
        showErrorPopup("Image download failed: ${response.statusCode}");
      }
    } catch (e) {
      showErrorPopup(e.toString());
      rethrow;
    }
    return Uint8List(0);
  }
}

/*  < comfy ui api 명세서 >
    2. 이미지 인페인팅 업로드("/upload/inpaint"): POST

    file: 업로드할 이미지 파일
    categories: 객체 탐지를 위한 카테고리
    (ex: 개, 고양이 등등 이걸로 객체 인식)

    3. 이미지 업스케일 업로드("/upload/upscale"): POST

    file: 업로드할 이미지 파일

    4. 업로드된 원본 이미지 접근("/static/uploads/<filename>"): GET

    5. 처리된 결과 이미지 반환
    ("/static/results/<filename>"):  GET

    <인페인팅>
    const formData = new FormData();
    formData.append("file", fileInput.files[0]);
    formData.append("categories", "고양이, 사람");

    <인페인팅 response 값>
    {
    "success": true,
    "original": "abc123.png", //원래 이미지파일
    "result": "result_456xyz.png", //결과 이미지파일
    "translated_categories": "cat,person" // 카테고리
    }

    <업스케일링>
    formData.append("file", fileInput.files[0]);

    <response 값>
    {
    "success": true,
    "original": "up_abc.png", //원래 이미지
    "result": "upscaled_xyz.png" //결과 값
    }

    * 응답에서 받은 result 값을 기반으로 이미지 URL 생성:

    const imageUrl = `http://localhost:5001/static/results/${data.result}`;
 */
