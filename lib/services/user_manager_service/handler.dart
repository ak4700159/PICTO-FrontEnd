import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/http_interceptor.dart';
import 'package:picto_frontend/services/user_manager_service/signin_response.dart';

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

  void initSettings(
      String? localAccessToken, String? localRefreshToken, int? localOwnerId) {
    accessToken = localAccessToken;
    refreshToken = localRefreshToken;
    ownerId = localOwnerId;
  }

  // 회원가입
  Future<void> signup(User newUser, double lat, double lng) async {
    String hostUrl = "$baseUrl/signup";
    final response = await dio.post(hostUrl, data: {
      'email': newUser.email,
      'password': newUser.password,
      'name': newUser.name,
      'lat': lat,
      'lng': lng,
    });
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
      // 토큰 저장
      rethrow;
    }
    // response["user"]; >
    // response["filter"]; >
    // response["userSetting"]; >
    // response["tags"]; >
    // response["titles"];
    // response["folders"]; >
    // response["photos"]; >
    // response["marks"];
    // response["blocks"];
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
    Map result = jsonDecode(response.data.toString());
    if (result["result"] == "true") {
      return Future<bool>.value(true);
    }
    return Future<bool>.value(false);
  }

// 사용자 정보 수정

// 태그 수정

// 즐겨찾기 추가, 해제

// 차단 추가, 해제

// 탈퇴
}
