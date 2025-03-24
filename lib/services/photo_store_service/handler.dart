import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/services/photo_store_service/upload_request.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class PhotoStoreHandler {
  PhotoStoreHandler._();

  static final PhotoStoreHandler _handler = PhotoStoreHandler._();

  factory PhotoStoreHandler() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8086/photo-store";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 1000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 3000)),
  )
    ..interceptors.add(CustomInterceptor());


  // 사진 조회
  Future<Uint8List> downloadPhoto(int photoId) async {
    final hostUrl = "$baseUrl/photos/download/$photoId";
    try{
      final response = await dio.get(hostUrl);
      return response.data;
    } on DioException catch(e) {
      print("[ERROR]photo download error : ${e.message}");
    }
    return Uint8List(0);
  }

  // 1. 갤러리에서 이미지 선택(XFile 객체, 추상화된 객체) =>  image_picker 패키지 사용
  // 2. XFile 객체의 이미지 경로 추출 후 File 객체로 생성(실제 로컬 파일 객체)
  // 3. FormData.fromMap를 이용해 "Content-Type" : "multipart/form-data" 구현
  // 4. file = MultipartFile.fromFile(File.path), mimeType = lookupMimeType(_selectedImage!.path) ?? 'application/octet-stream' 활용
  // 사진 업로드(파라미터 조심)
  Future<void> uploadPhoto(UploadRequest request) async {
    final hostUrl = "$baseUrl/photos";
    final mimeType = lookupMimeType(request.file.path) ?? 'application/octet-stream';
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
          request.file.path, filename: request.file.path, contentType: MediaType.parse(mimeType)),
      'request': MultipartFile.fromString(request.toJson(), contentType: MediaType('application', 'json')),
    });

    try {
      final response = await dio.post(hostUrl, data:  formData);
    } on DioException catch (e) {
      print("[ERROR]photo upload error : ${e.message}");
    }
  }

}
