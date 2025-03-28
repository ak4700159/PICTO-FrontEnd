import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_manager_service/signin_response.dart';

class LoginViewModel extends GetxController {
  RxBool isPasswordVisible = true.obs;
  RxString passwd = "".obs;
  RxString email = "".obs;
  RxString loginStatus = "not".obs;

  void togglePasswordVisible() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    loginStatus.value = "loading";
    await Future.delayed(Duration(seconds: 2));
    SigninResponse response;
    // 로그인 api 호출
    try {
      response =
          await UserManagerHandler().signin(email.value, passwd.value);
    } on DioException catch (e) {
      loginStatus.value = "fail";
      return;
    }

    // 이메일 오류 = "email" 비밀번호 오류 = "passwd"
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("User-Id", response.userId);
    await preferences.setString("Access-Token", response.accessToken);
    await preferences.setString("Refresh-Token", response.refreshToken);
    loginStatus.value = "success";

    // 로그인 성공! 설정 초기화 후 메인 화면 이동
    final splashController = Get.find<SplashViewModel>();
    splashController.setUserConfigThroughToken(isAccessToken: true);
  }
}
