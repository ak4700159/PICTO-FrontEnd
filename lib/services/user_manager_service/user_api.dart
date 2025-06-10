import 'dart:convert';
import 'package:dio/dio.dart';
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
import '../../screens/calendar/calendar_event.dart';
import '../../screens/calendar/calendar_view_model.dart';
import '../../screens/splash/splash_view_model.dart';
import '../../utils/popup.dart';
import '../folder_manager_service/folder_api.dart';
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
        connectTimeout: const Duration(milliseconds: 5000),
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 10)),
  )..interceptors.add(CustomInterceptor());

  Future<void> init() async {
    // print("[INFO] app debugging");
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
      final response = await dio.post(
        hostUrl,
        data: {
          'email': newUser.email,
          'password': newUser.password,
          'accountName': newUser.accountName,
          'name': newUser.name,
          'lat': lat,
          'lng': lng,
        },
      );
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
      showErrorPopup("로그인에 실패하였습니다.");
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
    FolderManagerApi().fetchFCM();
    try {
      final response = await dio.get(hostUrl, options: _authOptions());
      await _sendInitValueToViewModel(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        print('[ERROR] access token fail');
        try {
          await republishAccessToken();
          final response = await dio.get(hostUrl, options: _authOptions());
          await _sendInitValueToViewModel(response);
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

  Future<bool> modifyUserInfo() async {
    try {
      final profileViewModel = Get.find<ProfileViewModel>();
      final response = await dio.patch('$baseUrl/user', options: _authOptions(), data: {
        "userId": ownerId,
        "email": profileViewModel.email.value,
        "intro": profileViewModel.newIntro,
        "accountName": profileViewModel.newAccount,
        "profilePhotoPath": profileViewModel.profilePath.value,
        "profileActive": profileViewModel.profileActive.value,
        "name": profileViewModel.name.value,
        "type": "info"
      });
      profileViewModel.accountName.value = profileViewModel.newAccount;
      profileViewModel.intro.value = profileViewModel.newIntro;
      showMsgPopup(msg: "사용자 프로필을 수정하였습니다", space: 0.4);
      return true;
    } catch (e) {
      showErrorPopup("사용자 프로필 수정에 실패했습니다.");
    }
    return false;
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

  Future<bool> updateUserProfilePhoto({required int photoId}) async {
    try {
      final response = await dio.put('$baseUrl/profile/photo',
          queryParameters: {
            "userId": UserManagerApi().ownerId,
            "photoId": photoId,
          },
          options: _authOptions());
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  Future<bool> removeUserProfilePhoto() async {
    try {
      final response = await dio.delete('$baseUrl/profile/photo',
          queryParameters: {
            "userId": UserManagerApi().ownerId,
          },
          options: _authOptions());
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  Future<int?> getUserProfilePhoto({required int userId}) async {
    try {
      final response = await dio.get('$baseUrl/profile/photo',
          queryParameters: {
            "userId": userId,
          },
          options: _authOptions());
      return int.tryParse(response.data.toString());
    } on DioException catch (e) {
      // showErrorPopup(e.toString());
    }
    return null;
  }

  // 이메일 인증코드 이메일에 전송
  Future<bool> sendEmailCode({required String email}) async {
    try {
      final response = await dio.post('$baseUrl/send-verify-email/$email');
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // 이메일 인증코드 인증
  Future<bool> verifyEmailCode({required String email, required String code}) async {
    try {
      final response = await dio.post(
        '$baseUrl/verify-email',
        queryParameters: {
          "email": email,
          "code": code,
        },
      );
      if (response.data["success"]) {
        return true;
      } else {
        showErrorPopup(response.data["message"]);
      }
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // 이메일 인증 확인 API
  Future<bool> checkEmailCode({required String email}) async {
    try {
      final response = await dio.get('$baseUrl/is-verified-email/$email');
      if (response.data["success"]) {
        return true;
      } else {
        showErrorPopup(response.data["message"]);
      }
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // 임시 비밀번호 전송
  Future<bool> sendTemporaryPassword({required String email}) async {
    try {
      final response = await dio.post('$baseUrl/send-temporary-password/$email');
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  // 사용자 비밀번호 변경
  Future<bool> changePassword(
      {required String email, required String oldPassword, required String newPassword}) async {
    try {
      final response = await dio.patch(
        '$baseUrl/password',
        data: {
          "email": email,
          "password": oldPassword,
          "newPassword": newPassword,
        },
        options: _authOptions(),
      );
      return true;
    } on DioException catch (e) {
      showErrorPopup("사용자 비밀번호 변경 실패");
    }
    return false;
  }

  // 회원 탈퇴
  Future<bool> withdraw(
      {required String email, required String accountName, required String password}) async {
    try {
      final response = await dio.delete('$baseUrl/user', data: {
        "email": email,
        "password": password,
        "accountName": accountName,
      });
      return true;
    } on DioException catch (e) {
      showErrorPopup(e.toString());
    }
    return false;
  }

  Future<void> _sendInitValueToViewModel(response) async {
    try {
      Get.find<SplashViewModel>().statusMsg.value = "데이터 초기화 중 ... ";
      // 필터값 적용
      Get.find<SelectionBarViewModel>().convertFromJson(response.data["filter"]);
      // 프로필 적용
      int? photoId = await UserManagerApi().getUserProfilePhoto(userId: ownerId!);
      Get.find<ProfileViewModel>().convertFromJson(response.data["user"], photoId);
      // 사용자 세팅값 적용
      Get.find<UserConfig>().convertFromJson(response.data["userSetting"]);
      // 태그 적용
      Get.find<TagSelectionViewModel>().initTags(response.data["tags"]);
      // 폴더 적용
      await Get.find<FolderViewModel>().resetFolder(init: true);
      // 위치 소켓 적용
      final socketInterceptor = SocketFunctionController();
      socketInterceptor.callSession(connected: true);
      Get.find<LoginViewModel>().loginStatus.value = "not";
      Get.offNamed('/map');
    } catch (e) {
      Get.find<LoginViewModel>().loginStatus.value = "fail";
    }
  }

  Options _authOptions() => Options(
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );
}
