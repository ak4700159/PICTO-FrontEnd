import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends GetxController {
  LoginViewModel({required this.splashViewModel});

  final SplashViewModel splashViewModel;
  RxBool isPasswordVisible = false.obs;
  RxString passwd = "".obs;
  RxString email = "".obs;
  RxString loginStatus = "".obs;

  void togglePasswordVisible() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    print("[INFO]${splashViewModel.statusMsg.value}");
    // 로그인 api 호출
    // 이메일 오류 = "email" 비밀번호 오류 = "passwd"
    loginStatus.value = "success";// 성공시

  }
}