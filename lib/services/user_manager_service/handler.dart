import 'dart:convert';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/services/custom_interceptor.dart';

class UserManagerHandler {
  final String baseUrl = "bogota.iptime.org:8081/user-manager/";
  final Dio dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(milliseconds: 1000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(milliseconds: 3000)),
  )..interceptors.add(CustomInterceptor());

  // 회원가입
  Future<void> signup(User newUser) async {}

  // 로그인
  Future<void> signin(String email, String passwd) async {}

  // 사용자 정보 조회 -> 프로필 조회
  Future<User> getUserInfo(int userId, String accessToken) async {
    String hostUrl = "$baseUrl/$userId";
    final response = await dio.get(hostUrl);
    User user = User.fromJson(response.data);
    return user;
  }

  // 토큰 검증
  Future<String> validateToken(int userId, String accessToken, String refreshToken) async {
    String hostUrl = "$baseUrl/token";
    try {
      final response = await dio.get(
        hostUrl,
        options: Options(
          headers: {
            "Access-Token" : accessToken,
            "Refresh-Token" : refreshToken,
          },
        ),
      );
    } on DioException catch(e) {
      if(e.message!.contains("[INFO]")){
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
