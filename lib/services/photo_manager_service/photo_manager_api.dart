import 'package:dio/dio.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class PhotoManagerApi {
  PhotoManagerApi._();

  static final PhotoManagerApi _handler = PhotoManagerApi._();

  factory PhotoManagerApi() {
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
      final response = await dio.get(hostUrl, data: {"senderId": UserManagerApi().ownerId});
      List<dynamic> photos = response.data;
      return photos.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return <Photo>[];
  }

  // 지역별 대표 사진 조회
  Future<List<Photo>> getRepresentative(
      {String? eventType, String? locationType, String? locationName, required int count}) async {
    String hostUrl = "$baseUrl/photos/representative";
    try {
      final response = await dio.get(hostUrl, data: {
        "senderId": UserManagerApi().ownerId,
        "eventType": eventType,
        "locationType": locationType,
        "locationName": locationName,
        "count": count,
      });
      List<dynamic> photos = response.data;
      return photos.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return <Photo>[];
  }

  // 사진 조회
  Future<Photo?> getPhoto({required int photoId}) async {
    String hostUrl = "$baseUrl/photos";
    try {
      final response = await dio.get(hostUrl, data: {
        "senderId": UserManagerApi().ownerId,
        "eventType": "photo",
        "eventTypeId": photoId
      });
      List<dynamic> photo = response.data;
      return Photo.fromJson(photo[0]);
    } catch (e) {
      showErrorPopup(e.toString());
    }
    return null;
  }

  // 좋아요 누른 사진 전체 조회
  Future<List<Photo>> getLikePhotos() async {
    List<Photo> photos = [];
    try {
      final response = await dio
          .get("$baseUrl/photos/likes", queryParameters: {"userId": UserManagerApi().ownerId});
      List<dynamic> data = response.data;
      for (int photoId in data) {
        Photo? photo = await getPhoto(photoId: photoId);
        if (photo != null) {
          photos.add(photo);
        }
      }
    } catch (e) {
      showErrorPopup(e.toString());
      return [];
    }
    return photos;
  }

  // 좋아요
  Future<bool> clickLike({required int photoId}) async {
    try {
      final result = await dio.post("$baseUrl/photos/like", data: {
        "userId": UserManagerApi().ownerId,
        "photoId": photoId,
      });
      return true;
    } catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

// 특정 사진 좋아요 여부 확인
  Future<bool> checkPhotoLike({required int photoId}) async {
    try {
      final result = await dio.get("$baseUrl/photos/like", data: {
        "userId": UserManagerApi().ownerId,
        "photoId": photoId,
      });
      print("[INFO] photo is clicked : ${result.data}");
      return result.data;
    } catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // a
  Future<List<Photo>> getRandomPhotosByLocation(
      {required String locationName,
      required String locationType,
      required int count,
      required String eventType}) async {

    return [];
  }
}
