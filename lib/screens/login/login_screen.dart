import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/login/login_view_model.dart';
import 'package:picto_frontend/theme.dart';
import 'package:picto_frontend/utils/get_widget.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _viewModel = LoginViewModel(splashViewModel: Get.find());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: context.mediaQuery.size.height * 0.05,
                ),
                PictoLogo(scale: 1.2, fontSize: 30),
                SizedBox(height: context.mediaQuery.size.height * 0.02),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: getCustomInputDecoration(
                      label: "이메일", hintText: "your@eamil.com"),
                  validator: _emailValidator,
                  onSaved: (value) => _viewModel.email.value = value!,
                ),
                SizedBox(height: context.mediaQuery.size.height * 0.01),
                Obx(
                  () => TextFormField(
                    obscureText: _viewModel.isPasswordVisible.value,
                    decoration: getCustomInputDecoration(
                      label: "비밀번호",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _viewModel.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _viewModel.togglePasswordVisible();
                        },
                      ),
                    ),
                    validator: _passwdValidator,
                    onSaved: (value) => _viewModel.passwd.value = value!,
                  ),
                ),
                SizedBox(height: context.mediaQuery.size.height * 0.02),
                SizedBox(
                  height: context.mediaQuery.size.height * 0.07,
                  width: context.mediaQuery.size.width,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: PictoThemeData.mainColor,
                    ),
                    onPressed: () {
                      _viewModel.login();
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                      }
                      // 로그인 처리 로직
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: context.mediaQuery.size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // 비밀번호 새로 등록 화면 이동
                        Get.toNamed('/passwd_setting');
                      },
                      child: Text(
                        '비밀번호를 잊으셨나요?',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 회원가입 페이지 이동
                        Get.toNamed('/register');
                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _emailValidator(String? value) {
    String response = "";
    if (value?.isEmpty ?? true) {
      return '이메일을 입력해주세요.';
    } else {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = RegExp(pattern);
      if (!regExp.hasMatch(value!)) {
        return '잘못된 이메일 형식입니다.';
      } else if (response == "email") {
        return '존재하지 않는 이메일입니다.';
      }
      return null;
    }
  }

  String? _passwdValidator(String? value) {
    String response = "";
    if (value?.isEmpty ?? true) {
      return '비밀번호를 입력해주세요.';
    } else {
      String pattern =
          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
      RegExp regExp = RegExp(pattern);
      if (!regExp.hasMatch(value!)) {
        return '특수문자, 영문, 숫자 포함 8자 이상 15자 이내로 입력해주세요.';
      } else if (response == "passwd") {
        return '비밀번호가 틀렸습니다..';
      }
      return null;
    }
  }
}
