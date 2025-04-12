import 'package:dio/dio.dart';
import 'package:picto_frontend/models/folder.dart';
import 'package:picto_frontend/models/notice.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../config/app_config.dart';
import '../http_interceptor.dart';

class FolderManagerApi {
  FolderManagerApi._();

  static final FolderManagerApi _handler = FolderManagerApi._();

  factory FolderManagerApi() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8082/folder-manager";
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 1000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 3000)),
  )..interceptors.add(CustomInterceptor());

  // 폴더 생성
  Future<Folder?> createFolder({required String folderName, required String content}) async {
    try {
      final response = await dio.post(
        '$baseUrl/folders',
        data: {
          "generatorId": UserManagerApi().ownerId,
          "name": folderName,
          "content": content,
        },
      );
      Map<String, dynamic> data = response.data;
      return Folder.fromJson(data);
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return null;
  }

  // 폴더 삭제
  Future<bool> removeFolder({required int folderId}) async {
    try {
      final response = await dio.delete(
        '$baseUrl/folders/$folderId',
        queryParameters: {"generatorId": UserManagerApi().ownerId},
      );
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // 폴더 목록 조회
  Future<List<Folder>> getFoldersByOwnerId() async {
    try {
      final response = await dio.get('$baseUrl/folders/shares/users/${UserManagerApi().ownerId}');
      List<dynamic> data = response.data;
      return data.map((json) => Folder.fromJson(json)).toList();
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return [];
  }

  // 공유 폴더 사용자 조회
  Future<List<User>> getUsersInFolder({required int folderId}) async {
    try {
      final response = await dio.get('$baseUrl/folders/shares/$folderId',
          queryParameters: {"userId": UserManagerApi().ownerId});
      List<dynamic> data = response.data;
      List<User> users = [];
      for (var json in data) {
        int userId = json["userId"];
        User? add = await UserManagerApi().getUserInfo(userId: userId);
        if (add != null) {
          users.add(add);
        }
      }
      return users;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return <User>[];
  }

  // 폴더 안 전체 사진 조회
  Future<List<Photo>> getPhotosInFolder({required int folderId}) async {
    try {
      final response = await dio.get('$baseUrl/folders/$folderId/photos',
          queryParameters: {"userId": UserManagerApi().ownerId});
      List<dynamic> data = response.data;
      return data.map((json) => Photo.fromJson(json)).toList();
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return [];
  }

  // 공유 폴더 초대 전송
  Future<bool> sendFolderInvitation(
      {required int folderId, required int senderId, required int receiverId}) async {
    try {
      final response = await dio.post('$baseUrl/folders/shares', data: {
        "folderId": folderId,
        "senderId": senderId,
        "receiverId": receiverId,
      });
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

// 공유 폴더 초대 조회
  Future<List<Notice>> getFolderInvitations({required int receiverId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/folders/shares/notices',
        queryParameters: {"receiverId": receiverId},
      );
      List<dynamic> data = response.data;
      return data.map((json) => Notice.fromJson(json)).toList();
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return [];
  }

  // 공유 폴더 초대 수락/거절
  Future<bool> eventFolderInvitation(
      {required bool isAccept, required int receiverId, required int noticeId}) async {
    try {
      final response = await dio.post(
        '$baseUrl/folders/shares/notices/$noticeId',
        data: {
          "receiverId": receiverId,
          "accept": isAccept,
        },
      );
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }
}
