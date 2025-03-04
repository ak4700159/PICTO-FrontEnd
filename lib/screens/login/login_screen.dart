import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/login/login_view_model.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _viewModel = LoginViewModel();

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
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    labelText: '이메일',
                    hintText: 'example@email.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '올바른 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.mediaQuery.size.height * 0.01),
                TextFormField(
                  obscureText: _viewModel.isPasswordVisible.value,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    labelText: '비밀번호',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.mediaQuery.size.height * 0.02),
                SizedBox(
                  height: context.mediaQuery.size.height * 0.07,
                  width: context.mediaQuery.size.width,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xff7038ff),
                    ),
                    onPressed: () {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // 비밀번호 새로 등록 화면 이동
                      },
                      child: Text(
                        '비밀번호 찾기',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 회원가입 페이지 이동
                      },
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: '계정이 없으신가요? '),
                            TextSpan(
                              text: '회원가입',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
}
