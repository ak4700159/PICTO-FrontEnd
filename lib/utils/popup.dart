import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../config/app_config.dart';
import 'get_widget.dart';

void showErrorPopup(String errorMsg) {
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      contentPadding: EdgeInsets.all(10),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: Icon(
                Icons.info,
                size: 30,
                color: Colors.red,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                errorMsg,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showMsgPopup({required String msg, required double space}) {
  Get.dialog(
    barrierColor: Colors.transparent,
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(50),
      child: Builder(
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  // width: width * 0.5,
                  // height: height * 0.1,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                        color: Colors.grey.shade400,
                        offset: Offset(0, 5),
                      )
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.info,
                          size: 30,
                          color: AppConfig.mainColor,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          msg,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontFamily: "NotoSansKR",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: context.mediaQuery.size.height * space,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Future<void> showBlockingLoading(Duration duration) async {
  Get.dialog(
    PopScope(
      canPop: false, // ← 뒤로가기 버튼도 막음
      child: Center(
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
  );
  await Future.delayed(duration);
  Get.back();
}

Future<void> showSelectionDialog(
    {required BuildContext context,
    required Function positiveEvent,
    required Function negativeEvent,
    required String positiveMsg,
    required String negativeMsg,
    required String content}) async {
  double width = context.mediaQuery.size.width;
  double height = context.mediaQuery.size.height;
  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Container(
        width: width * 0.8,
        height: height * 0.16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              SizedBox(
                width: width * 0.7,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppConfig.mainColor,
                          ),
                          child: Text(
                            positiveMsg,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () async {
                            positiveEvent();
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            negativeMsg,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            negativeEvent();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showTemporaryPasswordSettingPopup() async {
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Builder(builder: (context) {
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;
        TextEditingController accountController = TextEditingController();
        TextEditingController nameController = TextEditingController();
        TextEditingController emailController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return Container(
          height: height * 0.32,
          width: width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            '닫기',
                            style: TextStyle(
                              fontFamily: "NotoSansKR",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: width * 0.5,
                        height: height * 0.08,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        child: FloatingActionButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? true) {
                              showErrorPopup("다시 작성해주세요");
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          backgroundColor: AppConfig.mainColor,
                          child: Text(
                            "임시 비밀번호 전송하기",
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: "NotoSansKR",
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            controller: accountController,
                            style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                            decoration: getCustomInputDecoration(
                              label: "계정 별명",
                              borderRadius: BorderRadius.circular(25),
                            ),
                            validator: (String? val) {
                              if (accountController.text.isEmpty) {
                                return "계정 별명을 작성해주세요";
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            controller: nameController,
                            style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                            decoration: getCustomInputDecoration(
                              label: "생성자 이름",
                              borderRadius: BorderRadius.circular(25),
                            ),
                            validator: (String? val) {
                              if (accountController.text.isEmpty) {
                                return "이름을 작성해주세요";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                      decoration: getCustomInputDecoration(
                        label: "계정 이메일",
                        borderRadius: BorderRadius.circular(25),
                      ),
                      validator: (String? val) {
                        if (accountController.text.isEmpty) {
                          return "계정 이메일을 작성해주세요";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );
}

Future<void> showPasswordReset() async {
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Builder(
        builder: (context) {
          final height = context.mediaQuery.size.height;
          final width = context.mediaQuery.size.width;
          final passwdController = TextEditingController();
          final passwdReController = TextEditingController();
          final formKey = GlobalKey<FormState>();
          return Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  height: height * 0.29,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            controller: passwdController,
                            style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                            decoration: getCustomInputDecoration(
                              label: "새로운 비밀번호",
                              borderRadius: BorderRadius.circular(25),
                            ),
                            validator: (String? val) {
                              if (passwdController.text.isEmpty) {
                                return "비밀번호를 입력해주세요.";
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: passwdReController,
                            style: TextStyle(fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                            decoration: getCustomInputDecoration(
                              label: "새로운 비밀번호 재작성",
                              borderRadius: BorderRadius.circular(25),
                            ),
                            validator: (String? val) {
                              if (passwdReController.text.isEmpty) {
                                return "비밀번호를 다시 입력해주세요.";
                              }
                              return null;
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: height * 0.08,
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    if (formKey.currentState?.validate() ?? true) {
                                      showErrorPopup("다시 작성해주세요");
                                    }
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  backgroundColor: AppConfig.mainColor,
                                  child: Text(
                                    "비밀번호 적용",
                                    style: TextStyle(
                                        fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: height * 0.08,
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    "취소",
                                    style: TextStyle(
                                        fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: height * 0.3, color: Colors.green,),
              ],
            ),
          );
        },
      ),
    ),
  );
}
