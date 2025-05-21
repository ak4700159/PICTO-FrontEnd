import 'dart:convert';
import 'dart:typed_data';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:picto_frontend/screens/upload/upload_request.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../config/app_config.dart';
import '../../models/photo.dart';
import '../../utils/functions.dart';
import '../http_interceptor.dart';

class PhotoStoreApi {
  PhotoStoreApi._();

  static final PhotoStoreApi _handler = PhotoStoreApi._();

  factory PhotoStoreApi() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8086/photo-store";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 20)),
  )..interceptors.add(CustomInterceptor());

  // 사진 조회
  Future<Uint8List> downloadPhoto({required int photoId, required double scale}) async {
    final hostUrl = "$baseUrl/photos/download/$photoId";
    try {
      final response = await dio.get(hostUrl,
          options: Options(responseType: ResponseType.bytes), // 🔥 핵심 포인트
          queryParameters: {
            "scale": scale,
          });
      return response.data;
    } on DioException catch (e) {
      print("[ERROR]photo download error : ${e.message}");
    }
    return Uint8List(0);
  }

  Future<Uint8List> downloadUserProfile({required int userId, required double scale}) async {
    int? photoId = await UserManagerApi().getUserProfilePhoto(userId: userId);
    if (photoId == null) throw Exception("프로필 조회 실패");
    final hostUrl = "$baseUrl/photos/download/$photoId";
    try {
      final response = await dio.get(hostUrl,
          options: Options(responseType: ResponseType.bytes), // 🔥 핵심 포인트
          queryParameters: {
            "scale": scale,
          });
      return response.data;
    } catch (e) {
      // 에러
    }
    return Uint8List(0);
  }

  // 리사이징된 사진 조회
  // Future<Uint8List> downloadResizedPhoto(
  //     {required int photoId, required int height, required int width}) async {
  //   final hostUrl = "$baseUrl/photos/resize/$photoId";
  //   try {
  //     final response = await dio.get(
  //       hostUrl,
  //       queryParameters: {
  //         "width": width,
  //         "height": height,
  //       },
  //       options: Options(responseType: ResponseType.bytes), // 🔥 핵심 포인트
  //     );
  //     return response.data;
  //   } on DioException catch (e) {
  //     print("[ERROR]photo download error : ${e.message}");
  //   }
  //   return Uint8List(0);
  // }

  // 1. 갤러리에서 이미지 선택(XFile 객체, 추상화된 객체) =>  image_picker 패키지 사용
  // 2. XFile 객체의 이미지 경로 추출 후 File 객체로 생성(실제 로컬 파일 객체)
  // 3. FormData.fromMap를 이용해 "Content-Type" : "multipart/form-data" 구현
  // 4. file = MultipartFile.fromFile(File.path), mimeType = lookupMimeType(_selectedImage!.path) ?? 'application/octet-stream' 활용
  // 사진 업로드(파라미터 조심)
  Future<void> uploadPhoto(UploadRequest request) async {
    try {
      final hostUrl = "$baseUrl/photos";
      FormData formData;
      if (request.file != null) {
        final mimeType = lookupMimeType(request.file!.path) ?? 'application/octet-stream';
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(request.file!.path,
              filename: request.file!.path, contentType: MediaType.parse(mimeType)),
          'request': MultipartFile.fromString(request.toJson(),
              contentType: MediaType('application', 'json')),
        });
      } else {
        formData = FormData.fromMap({
          'request': MultipartFile.fromString(request.toJson(),
              contentType: MediaType('application', 'json')),
        });
      }
      final response = await dio.post(hostUrl, data: formData);
    } on DioException catch (e) {
      rethrow;
    }
  }

  // 사진 삭제
  Future<bool> deletePhoto(int photoId) async {
    try {
      final response = dio.delete('$baseUrl/photos/$photoId',
          queryParameters: {"userId": UserManagerApi().ownerId});
      return true;
    } catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // 액자 리스트 조회
  Future<List<Photo>> getFrames() async {
    try {
      final response = await dio
          .get('$baseUrl/photos/frames', queryParameters: {"userId": UserManagerApi().ownerId});
      List<Photo> photos = (response.data as List).map((json) => Photo.fromJson(json)).toList();
      return photos;
    } catch (e) {
      showErrorPopup(e.toString());
    }
    return [];
  }

  // 프레임 사진 업로드
  Future<bool> uploadPhotoInFrame({required int photoId, required Uint8List image}) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(image,
            contentType: MediaType('image', 'jpeg'), filename: "$photoId.jpg"),
        'request': MultipartFile.fromString(
            jsonEncode({"frameActive": false, "sharedActive": false}),
            contentType: MediaType('application', 'json')),
      });
      final response = await dio.patch('$baseUrl/photos/frame/$photoId', data: formData);
      return true;
    } catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }
}
