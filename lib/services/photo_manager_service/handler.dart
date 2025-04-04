import 'package:dio/dio.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class PhotoManagerHandler {
  PhotoManagerHandler._();

  static final PhotoManagerHandler _handler = PhotoManagerHandler._();

  factory PhotoManagerHandler() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8083/photo-manager";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 10000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 10000)),
  )..interceptors.add(CustomInterceptor());

  // 반경 3km 내 주변 사진 조회
  Future<List<Photo>> getAroundPhotos() async {
    String hostUrl = "$baseUrl/photos/around";
    try {
      final response = await dio.get(hostUrl, data: {"senderId": UserManagerHandler().ownerId});
      List<dynamic> photos = response.data;
      return photos.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      print('[ERROR] around photo error : $e');
    }
    return <Photo>[];
  }

  // 지역별 대표 사진 조회
  Future<List<Photo>> getRepresentative(
      {String? eventType, String? locationType, String? locationName, required int count}) async {
    String hostUrl = "$baseUrl/photos/representative";
    try {
      final response = await dio.get(hostUrl, data: {
        "senderId" : UserManagerHandler().ownerId,
        "eventType": eventType,
        "locationType": locationType,
        "locationName": locationName,
        "count": count,
      });
      List<dynamic> photos = response.data;
      return photos.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      print('[ERROR] representative photo error' + e.toString());
    }
    return <Photo>[];
  }
}
