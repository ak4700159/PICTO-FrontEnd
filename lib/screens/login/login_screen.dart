import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/login/login_view_model.dart';
import 'package:picto_frontend/utils/get_widget.dart';
import 'package:picto_frontend/utils/validator.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  final _loginController = Get.find<LoginViewModel>();

  @override
  Widget build(BuildContext context) {
    double widgetHeight = context.mediaQuery.size.height;
    double widgetWidth = context.mediaQuery.size.width;
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
                SizedBox(height: widgetHeight * 0.02),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: getCustomInputDecoration(
                      label: "이메일", hintText: "your@eamil.com"),
                  validator: emailValidator,
                  onSaved: (value) => _loginController.email.value = value!,
                ),
                SizedBox(height: widgetHeight * 0.01),
                Obx(
                  () => TextFormField(
                    obscureText: _loginController.isPasswordVisible.value,
                    decoration: getCustomInputDecoration(
                      label: "비밀번호",
                      suffixIcon: IconButton(
                        icon: Icon(
                          !_loginController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _loginController.togglePasswordVisible();
                        },
                      ),
                    ),
                    validator: passwdValidator,
                    onSaved: (value) => _loginController.passwd.value = value!,
                  ),
                ),
                SizedBox(height: widgetHeight * 0.02),
                SizedBox(
                  height: widgetHeight * 0.07,
                  width: widgetWidth,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppConfig.mainColor,
                    ),
                    onPressed: _login,
                    child: Obx(() => _loggingText()),
                  ),
                ),
                SizedBox(height: widgetHeight * 0.01),
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

  void _login() {
    // step1. 사용자 w
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // step2. 서버 로그인 시도
      _loginController.login();
    }
  }

  Widget _loggingText() {
    if (_loginController.loginStatus.value == "not") {
      return Text(
        "Login",
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else if (_loginController.loginStatus.value == "loading") {
      return Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(
          color: AppConfig.backgroundColor,
        ),
      );
    } else if (_loginController.loginStatus.value == "fail") {
      return Text(
        "다시 로그인해주세요.",
        style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      );
    }
    return Text(
      "로그인 성공!",
      style: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
