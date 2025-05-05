import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';
import 'package:picto_frontend/services/session_scheduler_service/session_socket.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_manager_service/signin_response.dart';

class LoginViewModel extends GetxController {
  RxBool isPasswordVisible = true.obs;
  RxString passwd = "".obs;
  RxString email = "".obs;
  RxString loginStatus = "not".obs;
  RxInt sliderIdx = 0.obs;

  void togglePasswordVisible() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    loginStatus.value = "loading";
    await Future.delayed(Duration(seconds: 2));
    SigninResponse response;
    // 로그인 api 호출
    try {
      await UserManagerApi().signin(email.value, passwd.value);
    } on DioException catch (e) {
      loginStatus.value = "fail";
      return;
    }

    // 이메일 오류 = "email" 비밀번호 오류 = "passwd"
    // 로그인 성공! 설정 초기화 후 메인 화면 이동
    await UserManagerApi().setUserAllInfo();
    // Get.find<FolderViewModel>().initFolder();
  }
}
