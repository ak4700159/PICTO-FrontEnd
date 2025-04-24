import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/user.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/login/login_view_model.dart';
import 'package:picto_frontend/screens/map/selection_bar_view_model.dart';
import 'package:picto_frontend/screens/map/tag/tag_selection_view_model.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/services/http_interceptor.dart';
import 'package:picto_frontend/services/user_manager_service/signin_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/user_config.dart';
import '../../screens/map/google_map/google_map_view_model.dart';
import '../../utils/popup.dart';
import '../socket_function_controller.dart';

// 구조 개선 ->
// 1. access token, refresh token, user id는 해당 서비스 계층에서 관리
// 2. 예외 처리 방식 : 해당 서비스 게층에서 발생한 예외는 여기서 처리하기
// 3. GetX controller에 의존적이지 않도록 코드 구성 : 콜백함수 등록(상태 메시지 변화)

class UserManagerApi {
  // private 생성자 선언 -> 외부에서 해당 클래스의 생성자 생성을 막는다.
  UserManagerApi._();

  static final UserManagerApi _handler = UserManagerApi._();

  factory UserManagerApi() {
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

  Future<void> init() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    accessToken = preferences.getString("access-token");
    refreshToken = preferences.getString("refresh-token");
    ownerId = preferences.getInt("owner-id");
    if (accessToken == null || refreshToken == null || ownerId == null) {
      throw Exception("first login");
    }
  }

  // 회원가입(인증x)
  Future<void> signup({required User newUser, required double lat, required double lng}) async {
    String hostUrl = "$baseUrl/signup";
    try {
      final response = await dio.post(hostUrl, data: {
        'email': newUser.email,
        'password': newUser.password,
        'accountName': newUser.accountName,
        'name': newUser.name,
        'lat': lat,
        'lng': lng,
      });
    } on DioException catch (e) {
      showErrorPopup(e.toString());
      rethrow;
    }
  }

  // 로그인(인증x)
  Future<void> signin(String email, String passwd) async {
    String hostUrl = "$baseUrl/signin";
    try {
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

      final SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("refresh-token", refreshToken!);
      preferences.setString("access-token", accessToken!);
      preferences.setInt("owner-id", ownerId!);
    } on DioException catch (e) {
      showErrorPopup(e.toString());
      rethrow;
    }
  }

  // 이메일 중복 여부 확인(인증X)
  Future<bool> duplicatedEmail(String email) async {
    String hostUrl = "$baseUrl/email/$email";
    final response = await dio.get(hostUrl);
    if (jsonDecode(response.data) == true) {
      return true;
    }
    return false;
  }

  // 엑세스 토큰 재발급(인증x)
  Future<void> republishAccessToken() async {
    try {
      final response = await dio.post(
        '$baseUrl/refresh-token',
        data: {
          "refreshToken": refreshToken,
        },
      );
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      accessToken = response.data['accessToken'];
      preferences.setString("access-token", accessToken!);
    } on DioException catch (e) {
      showErrorPopup(e.toString());
      Get.offNamed('/login');
      rethrow;
    }
  }

  // 사용자 전체 정보 조회
  Future<void> setUserAllInfo() async {
    String hostUrl = "$baseUrl/user-all/$ownerId";
    try {
      final response = await dio.get(hostUrl, options: _authOptions());
      _sendInitValue(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        print('[ERROR] access token fail');
        try {
          await republishAccessToken();
          final response = await dio.get(hostUrl, options: _authOptions());
          _sendInitValue(response);
        } catch (e) {
          print('[ERROR] refresh token fail');
          Get.find<LoginViewModel>().loginStatus.value = "fail";
        }
      } else {
        print('[ERROR] login server error');
        Get.find<LoginViewModel>().loginStatus.value = "fail";
        Get.offNamed('/login');
      }
    }
  }

  // 태그 수정
  Future<void> modifiedTag(List<String> tagNames) async {
    String hostUrl = "$baseUrl/tag";
    try {
      final response = await dio.put(
        hostUrl,
        options: _authOptions(),
        data: {
          "userId": ownerId,
          "tagNames": tagNames,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        try {
          await republishAccessToken();
          final response = await dio.put(
            hostUrl,
            options: _authOptions(),
            data: {
              "userId": ownerId,
              "tagNames": tagNames,
            },
          );
        } catch (e) {}
      }
    }
  }

  // 필터 수정
  Future<void> modifiedFilter(String sort, String period) async {
    String hostUrl = "$baseUrl/filter";
    try {
      final response = await dio.patch(
        hostUrl,
        options: _authOptions(),
        data: {
          "userId": ownerId,
          "sort": sort,
          "period": period,
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        try {
          await republishAccessToken();
          final response = await dio.patch(
            hostUrl,
            options: _authOptions(),
            data: {
              "userId": ownerId,
              "sort": sort,
              "period": period,
            },
          );
        } catch (e) {}
      }
    }
  }

  // 다른 사용자 정보 불러오기
  Future<User?> getUserInfo({required int userId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/users/$userId',
        options: _authOptions(),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return null;
  }

  Future<User?> getUserByEmail({required String email}) async {
    try {
      final response = await dio.get(
        '$baseUrl/users',
        data: {"email": email},
        options: _authOptions(),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      print("[ERROR] ${e.toString()}");
      // showErrorPopup(e.toString());
    }
    return null;
  }

  Future<User?> getUserByUserId({required int userId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/users/$userId',
        options: _authOptions(),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return null;
  }

  void _sendInitValue(response) {
    Get.find<SelectionBarViewModel>().convertFromJson(response.data["filter"]);
    Get.find<ProfileViewModel>().convertFromJson(response.data["user"]);
    Get.find<UserConfig>().convertFromJson(response.data["userSetting"]);
    // Get.find<GoogleMapViewModel>().initPhotos(response.data["folderPhotos"]);
    Get.find<TagSelectionViewModel>().initTags(response.data["tags"]);
    Get.find<FolderViewModel>().resetFolder();

    final socketInterceptor = SocketFunctionController();
    socketInterceptor.callSession(connected: true);
    Get.offNamed('/map');
  }

  Options _authOptions() => Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

// 시간되면 구현할 기능
// 1. 즐겨찾기 추가, 해제
// 2. 차단 추가, 해제
// 3. 탈퇴
}
