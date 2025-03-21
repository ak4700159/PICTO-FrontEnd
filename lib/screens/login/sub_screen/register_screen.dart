import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/login/sub_screen/register_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/top_box.dart';

import '../../../utils/get_widget.dart';
import '../../../utils/validator.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _registerController = Get.find<RegisterViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    colorBlendMode: BlendMode.modulate, opacity: const AlwaysStoppedAnimation(0.5)),
                TopBox(size: 0.01),
                _getFormFiled(context),
                TopBox(size: 0.1),
                Obx(() => _getRegisterButton(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _getFormFiled(BuildContext context) {
    return SizedBox(
      width: context.mediaQuery.size.width * 0.9,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 이름 FormField
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextFormField(
                keyboardType: TextInputType.name,
                decoration: getCustomInputDecoration(label: "이름", hintText: "홍길동"),
                validator: nameValidator,
                onSaved: (value) => _registerController.name.value = value!,
              ),
            ),
            // 이메일 FormField + 중복 검사 버튼
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.6,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: getCustomInputDecoration(label: "이메일", hintText: "your@eamil.com"),
                      validator: emailValidator,
                      onSaved: (value) => _registerController.email.value = value!,
                    ),
                  ),
                  SizedBox(
                    width: context.mediaQuery.size.width * 0.25,
                    height: context.mediaQuery.size.height * 0.075,
                    child: TextButton(
                      onPressed: () {
                        // 이메일 중복 검사
                      },
                      style: TextButton.styleFrom(backgroundColor: AppConfig.mainColor),
                      child: Text("중복 검사", style: TextStyle(fontSize: 15, color: AppConfig.backgroundColor)),
                    ),
                  )
                ],
              ),
            ),
            // 비밀번호 FormField
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  obscureText: _registerController.isPasswordVisible.value,
                  decoration: getCustomInputDecoration(
                    label: "비밀번호",
                    suffixIcon: IconButton(
                      icon: Icon(
                        !_registerController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        _registerController.togglePasswordVisible();
                      },
                    ),
                  ),
                  validator: passwdValidator,
                  onSaved: (value) => _registerController.passwd.value = value!,
                ),
              ),
            ),
            // 비밀번호 재입력 FormField
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextFormField(
                  obscureText: _registerController.isPasswordVisible.value,
                  decoration: getCustomInputDecoration(
                    label: "비밀번호 재입력",
                    suffixIcon: IconButton(
                      icon: Icon(
                        !_registerController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        _registerController.togglePasswordVisible();
                      },
                    ),
                  ),
                  validator: passwdValidator,
                  onSaved: (value) => _registerController.passwdCheck.value = value!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getRegisterButton(BuildContext context) {
    return SizedBox(
      width: context.mediaQuery.size.width * 0.9,
      height: context.mediaQuery.size.height * 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: () {
            // 1. 이름, 이메일, 비밀번호, 비밀번호 재입력 Form필드 검사
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
            } else {
              _registerController.registerStatus.value = "다시 작성해주세요.";
              return;
            }

            // 2. 이메일 중복 검사 확인
            if(_registerController.registerStatus.value != "사용 가능"){
              _registerController.registerStatus.value = "이메일 중복 검사 해주세요";
              return;
            }

            // 3. 비밀번호 중복 확인
            if(!_registerController.passwdCheck.value) {

            }

            _registerController.signup();
          },
          style: TextButton.styleFrom(
            backgroundColor: AppConfig.mainColor,
          ),
          child: Text(
            _registerController.registerStatus.value,
            style: TextStyle(fontSize: 20, color: AppConfig.backgroundColor),
          ),
        ),
      ),
    );
  }
}
