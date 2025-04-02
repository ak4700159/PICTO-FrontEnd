import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/screens/map/selection_bar_view_model.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/http_interceptor.dart';
import 'package:picto_frontend/services/user_manager_service/signin_response.dart';

import '../../config/user_config.dart';
import '../../screens/map/google_map/google_map_view_model.dart';

class UserManagerHandler {
  // private 생성자 선언 -> 외부에서 해당 클래스의 생성자 생성을 막는다.
  UserManagerHandler._();

  static final UserManagerHandler _handler = UserManagerHandler._();

  factory UserManagerHandler() {
    return _handler;
  }

  final String baseUrl = "${AppConfig.httpUrl}:8081/user-manager";
  String? accessToken;
  String? refreshToken;
  int? ownerId;
  Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 1000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 3000)),
  )..interceptors.add(CustomInterceptor());

  void initSettings(String? localAccessToken, String? localRefreshToken, int? localOwnerId) {
    accessToken = localAccessToken;
    refreshToken = localRefreshToken;
    ownerId = localOwnerId;
  }

  // 회원가입
  Future<void> signup({required User newUser, required double lat, required double lng}) async {
    String hostUrl = "$baseUrl/signup";
    final response = await dio.post(hostUrl, data: jsonEncode({
      'email': newUser.email,
      'password': newUser.password,
      'name': newUser.name,
      'lat': lat,
      'lng': lng,
    }));
    return;
  }

  // 로그인
  Future<SigninResponse> signin(String email, String passwd) async {
    String hostUrl = "$baseUrl/signin";
    final response = await dio.post(
      hostUrl,
      data: {
        "email": email,
        "password": passwd,
      },
    );
    final result = SigninResponse.fromJson(response.data);
    refreshToken = result.refreshToken;
    accessToken = result.accessToken;
    ownerId = result.userId;
    return result;
  }

  // 사용자 전체 정보 조회
  Future<void> setUserAllInfo(bool isAccessToken) async {
    String hostUrl = "$baseUrl/user-all/$ownerId";
    final response;
    if (isAccessToken) {
      print("[INFO]엑세스토큰으로 전체 정보 조회\n");
    } else {
      print("[INFO]리프레쉬토큰으로 전체 정보 조회\n");
    }

    try {
      response = await dio.get(
        hostUrl,
        options: isAccessToken
            ? Options(
                headers: {
                  "Access-Token": accessToken,
                  "User-Id": ownerId,
                },
              )
            : Options(headers: {
                "Refresh-Token": refreshToken,
                "User-Id": ownerId,
              }),
      );
    } on DioException catch (e) {
      rethrow;
    }
    // 불러온 데이터를 view model에 입력
    final selectionViewModel = Get.find<SelectionBarViewModel>();
    selectionViewModel.convertFromJson(response.data["filter"]);

    final profileViewModel = Get.find<ProfileViewModel>();
    profileViewModel.convertFromJson(response.data["user"]);

    final userConfig = Get.find<UserConfig>();
    userConfig.convertFromJson(response.data["userSetting"]);

    // 내 사진 + 공유 폴더 사진 전부 로딩
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    googleMapViewModel.initPhotos(response.data["folderPhotos"]);
  }

  // 토큰 검증
  Future<String> validateToken(int userId) async {
    String hostUrl = "$baseUrl/token";
    try {
      final response = await dio.get(
        hostUrl,
        options: Options(
          headers: {
            "Access-Token": accessToken,
            "Refresh-Token": refreshToken,
          },
        ),
      );
    } on DioException catch (e) {
      if (e.message!.contains("[INFO]")) {
        String newAccessToken = e.message!.substring(5);
        return newAccessToken;
      }
      return "login";
    }
    return "pass";
  }

  // 이메일 중복 여부 확인
  Future<bool> duplicatedEmail(String email) async {
    String hostUrl = "$baseUrl/email/$email";
    final response = await dio.get(hostUrl);
    if (jsonDecode(response.data) == true) {
      return Future<bool>.value(true);
    }
    return Future<bool>.value(false);
  }

  // 태그 수정
  Future<void> modifiedTag(List<String> tagNames) async {
    String hostUrl = "$baseUrl/tag";
    try {
      final response = await dio.patch(
        hostUrl,
        data: jsonEncode(
          {
            "userId": ownerId,
            "tagNames": tagNames,
          },
        ),
      );
    } on DioException catch (e) {
      print("[ERROR] modified tag http error");
    }
  }

  // 필터 수정
  Future<void> modifiedFilter(String sort, String period) async {
    String hostUrl = "$baseUrl/filter";
    try {
      final response = await dio.patch(
        hostUrl,
        data: jsonEncode(
          {
            "userId": ownerId,
            "sort": sort,
            "period": period,
          },
        ),
      );
    } on DioException catch(e) {
      print("[ERROR] modified filter http error");
    }
  }

// 즐겨찾기 추가, 해제

// 차단 추가, 해제

// 탈퇴
}
