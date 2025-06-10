import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/login/sub_screen/register_view_model.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/services/user_manager_service/user_api.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../../utils/get_widget.dart';
import '../../../utils/validator.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _registerController = Get.find<RegisterViewModel>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showSelectionDialog(
          context: context,
          content: "작성하신 내용이 삭제됩니다.",
          positiveEvent: () {
            _registerController.resetController();
            Get.offNamed('/login');
          },
          positiveMsg: "네",
          negativeEvent: () {
            Get.back();
          },
          negativeMsg: "아니요",
        );
      },
      child: GestureDetector(
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
                    Text('PICTO',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppConfig.mainColor,
                          fontWeight: FontWeight.bold,
                        )),
                    Image.asset("assets/images/picto_logo.png",
                        colorBlendMode: BlendMode.modulate,
                        opacity: const AlwaysStoppedAnimation(0.4)),
                    TopBox(size: 0.07),
                    _getFormFiled(context),
                    TopBox(size: 0.07),
                    Obx(() => _getRegisterButton(context)),
                    TopBox(size: 0.07),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _getFormFiled(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 이름 FormField
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                // height: height * 0.08,
                child: TextFormField(
                  style: TextStyle(
                      fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
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
                // height: height * 0.08,
                child: TextFormField(
                  style: TextStyle(
                      fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
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
            Obx(() => IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                // height: height * 0.08,
                                child: TextFormField(
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "NotoSansKR",
                                    fontWeight: FontWeight.w600,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: getCustomInputDecoration(
                                    label: "이메일",
                                    hintText: "your@eamil.com",
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  validator: emailValidator,
                                  onChanged: (value) {
                                    _registerController.email.value = value;
                                    _registerController.emailDuplicatedMsg.value = "중복 검사";
                                    _registerController.isEmailCodeAuth.value = false;
                                    _registerController.isEmailCodeSend.value = false;
                                    _registerController.emailCode.value = "";
                                  },
                                  onSaved: (value) => _registerController.email.value = value!,
                                  readOnly: _registerController.emailDuplicatedMsg.value == "사용 가능",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: AppConfig.mainColor,
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (_registerController.emailDuplicatedMsg.value == "사용 가능") return;
                                if (_registerController.email.value.isEmpty) {
                                  showMsgPopup(msg: "이메일 작성해주세요", space: 0.22);
                                } else if (emailValidator(_registerController.email.value) !=
                                    null) {
                                  showMsgPopup(msg: "이메일 형식이 아닙니다", space: 0.22);
                                } else {
                                  _registerController.validateEmail();
                                }
                              },
                              child: Obx(
                                () => _registerController.emailDuplicatedLoading.value
                                    ? AnimatedTextKit(
                                        animatedTexts: [
                                          FadeAnimatedText(
                                            "처리중",
                                            duration: Duration(seconds: 1),
                                            textStyle: TextStyle(
                                              fontFamily: "NotoSansKR",
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                        repeatForever: true,
                                      )
                                    : Text(
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
                )),

            // 이메일 중복 검사 이후 인증코드 전송 가능.
            Obx(() => _registerController.emailDuplicatedMsg.value == "사용 가능"
                ? _getEmailAuthWidget(context: context)
                : SizedBox(
                    height: 0,
                  )),

            // 비밀번호 FormField
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  // height: height * 0.08,
                  child: TextFormField(
                    style: TextStyle(
                        fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
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
                  // height: height * 0.08,
                  child: TextFormField(
                    style: TextStyle(
                        fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
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
                    validator: passwdValidator,
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
      width: MediaQuery.sizeOf(context).width * 0.7,
      height: MediaQuery.sizeOf(context).height * 0.06,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: _registerController.registerLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : TextButton(
                onPressed: () async {
                  // 1. 이름, 이메일, 비밀번호, 비밀번호 재입력 Form필드 검사
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                  } else {
                    // _registerController.registerMsg.value = "다시 작성해주세요.";
                    return;
                  }

                  // 2. 이메일 중복 검사 확인
                  if (_registerController.emailDuplicatedMsg.value != "사용 가능") {
                    // _registerController.registerMsg.value = "이메일 중복 검사 해주세요.";
                    return;
                  }

                  // 3. 비밀번호 매칭 확인
                  if (_registerController.passwd.value != _registerController.passwdCheck.value) {
                    // _registerController.registerMsg.value = "비밀번호가 일치하지 않습니다..";
                    return;
                  }

                  if (!_registerController.isEmailCodeAuth.value) {
                    return;
                  }

                  // 4. 회원가입 시도
                  try {
                    _registerController.signup();
                    // _registerController.registerMsg.value = "회원가입 성공!";
                    await Future.delayed(Duration(seconds: AppConfig.stopScreenSec));
                    Get.toNamed('/login');
                  } on DioException catch (e) {
                    _registerController.registerMsg.value = "네트워크 오류";
                    print("[ERROR]signup failed");
                  }
                },

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

  Widget _getEmailAuthWidget({required BuildContext context}) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _registerController.isEmailCodeSend.value
                ? Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          // height: height * 0.08,
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w600,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            decoration: getCustomInputDecoration(
                              label: "인증코드",
                              hintText: "XXXXXX",
                              borderRadius: BorderRadius.circular(25),
                            ),
                            validator: emailCodeValidator,
                            onChanged: (value) {
                              _registerController.emailCode.value = value;
                            },
                            onSaved: (value) => _registerController.emailCode.value = value!,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 8),
                height: height * 0.067,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppConfig.mainColor,
                ),
                child: !_registerController.isEmailCodeAuth.value
                    ? _registerController.emailAuthVerifyLoading.value ||
                            _registerController.emailAuthSendLoading.value
                        ? Center(
                            child: AnimatedTextKit(
                              animatedTexts: [
                                FadeAnimatedText(
                                  _registerController.emailAuthSendLoading.value
                                      ? "인증 코드 전송 중"
                                      : "인증 코드 확인 중",
                                  duration: Duration(seconds: 1),
                                  textStyle: TextStyle(
                                    fontFamily: "NotoSansKR",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              repeatForever: true,
                            ),
                          )
                        : TextButton(
                            onPressed: () async {
                              // 이미 인증이 완료되었다면.
                              if (_registerController.isEmailCodeAuth.value) return;

                              if (!_registerController.isEmailCodeSend.value) {
                                // 인증코드 전송
                                _registerController.emailAuthSendLoading.value = true;
                                if (await UserManagerApi()
                                    .sendEmailCode(email: _registerController.email.value)) {
                                  showMsgPopup(msg: "인증코드를 전송하였습니다.", space: 0.4);
                                  _registerController.isEmailCodeSend.value =
                                      !_registerController.isEmailCodeSend.value;
                                }
                                _registerController.emailAuthSendLoading.value = false;
                              } else {
                                // 인증코드 검증
                                _registerController.emailAuthVerifyLoading.value = true;
                                if (await UserManagerApi().verifyEmailCode(
                                    email: _registerController.email.value,
                                    code: _registerController.emailCode.value)) {
                                  showMsgPopup(msg: "인증코드 확인되었습니다!", space: 0.4);
                                  _registerController.isEmailCodeAuth.value = true;
                                }
                                _registerController.emailAuthVerifyLoading.value = false;
                              }
                            },
                            child: Text(
                              _registerController.isEmailCodeSend.value ? "인증 코드 확인" : "인증 코드 전송",
                              style: TextStyle(
                                fontFamily: "NotoSansKR",
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )
                    : Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Center(
                          child: Text(
                            "이메일 인증 성공",
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
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
    );
  }
}
