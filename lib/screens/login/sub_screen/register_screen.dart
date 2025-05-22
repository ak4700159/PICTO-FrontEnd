import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/login/sub_screen/register_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';

import '../../../utils/get_widget.dart';
import '../../../utils/validator.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _registerController = Get.find<RegisterViewModel>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false, // 🔥 키보드 올라와도 레이아웃 밀리지 않음
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  TopBox(size: 0.1),
                  // 픽토 로고
                  Text('PICTO', style: TextStyle(fontSize: 30, color: Colors.grey)),
                  Image.asset("assets/images/picto_logo.png",
                      colorBlendMode: BlendMode.modulate,
                      opacity: const AlwaysStoppedAnimation(0.5)),
                  TopBox(size: 0.01),
                  _getFormFiled(context),
                  TopBox(size: 0.08),
                  Obx(() => _getRegisterButton(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _getFormFiled(BuildContext context) {
    double width = context.mediaQuery.size.width;
    double height = context.mediaQuery.size.height;
    return SizedBox(
      width: context.mediaQuery.size.width * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 이름 FormField
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: height * 0.06,
                child: TextFormField(
                  style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                  keyboardType: TextInputType.name,
                  decoration: getCustomInputDecoration(
                    label: "이름",
                    hintText: "홍길동",
                    borderRadius: BorderRadius.circular(25),
                  ),
                  validator: nameValidator,
                  onSaved: (value) => _registerController.name.value = value!,
                ),
              ),
            ),
            // 별칭 FormField
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: height * 0.06,
                child: TextFormField(
                  style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                  keyboardType: TextInputType.name,
                  decoration: getCustomInputDecoration(
                    label: "계정명",
                    hintText: "Hong",
                    borderRadius: BorderRadius.circular(25),
                  ),
                  validator: accountValidator,
                  onSaved: (value) => _registerController.accountName.value = value!,
                ),
              ),
            ),
            // 이메일 FormField + 중복 검사 버튼
            IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: height * 0.06,
                            child: TextFormField(
                              style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                              keyboardType: TextInputType.emailAddress,
                              decoration: getCustomInputDecoration(
                                label: "이메일",
                                hintText: "your@eamil.com",
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  bottomLeft: Radius.circular(25),
                                ),
                              ),
                              validator: emailValidator,
                              onChanged: (value) => _registerController.email.value = value,
                              onSaved: (value) => _registerController.email.value = value!,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: height * 0.06,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                          color: AppConfig.mainColor,
                        ),
                        child: TextButton(
                          onPressed: () {
                            _registerController.validateEmail();
                            // 이메일 중복 검사
                          },
                          // style: TextButton.styleFrom(backgroundColor: AppConfig.mainColor),
                          child: Obx(
                            () => Text(
                              _registerController.emailDuplicatedMsg.value,
                              style: TextStyle(
                                fontFamily: "NotoSansKR",
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // 비밀번호 FormField
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  height: height * 0.06,
                  child: TextFormField(
                    style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                    obscureText: _registerController.isPasswordVisible.value,
                    decoration: getCustomInputDecoration(
                      label: "비밀번호",
                      suffixIcon: IconButton(
                        icon: Icon(
                          !_registerController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _registerController.togglePasswordVisible();
                        },
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    validator: passwdValidator,
                    onSaved: (value) => _registerController.passwd.value = value!,
                  ),
                ),
              ),
            ),
            // 비밀번호 재입력 FormField
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  height: height * 0.06,
                  child: TextFormField(
                    style : TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                    obscureText: _registerController.isPasswordVisible.value,
                    decoration: getCustomInputDecoration(
                      label: "비밀번호 재입력",
                      suffixIcon: IconButton(
                        icon: Icon(
                          !_registerController.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _registerController.togglePasswordVisible();
                        },
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    // validator: passwdValidator,
                    onSaved: (value) => _registerController.passwdCheck.value = value!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRegisterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppConfig.mainColor,
      ),
      width: context.mediaQuery.size.width * 0.7,
      height: context.mediaQuery.size.height * 0.06,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: TextButton(
          onPressed: () async {
            // 1. 이름, 이메일, 비밀번호, 비밀번호 재입력 Form필드 검사
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
            } else {
              _registerController.registerMsg.value = "다시 작성해주세요.";
              return;
            }

            // 2. 이메일 중복 검사 확인
            if (_registerController.emailDuplicatedMsg.value != "사용 가능") {
              _registerController.registerMsg.value = "이메일 중복 검사 해주세요.";
              return;
            }

            // 3. 비밀번호 매칭 확인
            if (_registerController.passwd.value != _registerController.passwdCheck.value) {
              _registerController.registerMsg.value = "비밀번호가 일치하지 않습니다..";
              return;
            }

            // 4. 회원가입 시도
            try {
              _registerController.signup();
              _registerController.registerMsg.value = "회원가입 성공!";
              await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));
              Get.toNamed('/login');
            } on DioException catch (e) {
              _registerController.registerMsg.value = "네트워크 오류";
              print("[ERROR]signup failed");
            }
          },
          // style: TextButton.styleFrom(
          //   backgroundColor: AppConfig.mainColor,
          // ),
          // 상태 메시지에 따라 버튼 UI 변경은 나중에.
          child: Text(
            _registerController.registerMsg.value,
            style: TextStyle(
              fontFamily: "NotoSansKR",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
