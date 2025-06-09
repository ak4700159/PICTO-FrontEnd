import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:picto_frontend/utils/functions.dart';

import '../config/app_config.dart';
import 'get_widget.dart';

void showErrorPopup(String errorMsg) {
  Get.dialog(
    barrierDismissible: true,
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            convertNaturalKorean(msg),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: "NotoSansKR",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * space,
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
  double width = MediaQuery.sizeOf(context).width;
  double height = MediaQuery.sizeOf(context).height;
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
        TextEditingController emailController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return Container(
          height: height * 0.21,
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
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      style: TextStyle(
                          fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
                      decoration: getCustomInputDecoration(
                        label: "계정 이메일",
                        borderRadius: BorderRadius.circular(25),
                      ),
                      validator: (String? val) {
                        if (emailController.text.isEmpty) {
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

Future<void> showPasswordResetPopup() async {
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      insetPadding: EdgeInsets.all(0),
      child: Builder(
        builder: (context) {
          final height = MediaQuery.sizeOf(context).height;
          final width = MediaQuery.sizeOf(context).width;
          final passwdController = TextEditingController();
          final passwdReController = TextEditingController();
          final formKey = GlobalKey<FormState>();
          return Form(
            key: formKey,
            child: Container(
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
                        style: TextStyle(
                            fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
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
                        style: TextStyle(
                            fontSize: 12, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
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
                            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                            child: FloatingActionButton(
                              heroTag: "adapt",
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? true) {
                                  showErrorPopup("다시 작성해주세요");
                                }
                              },
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              backgroundColor: AppConfig.mainColor,
                              child: Text(
                                "비밀번호 적용",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "NotoSansKR",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: height * 0.08,
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                            child: FloatingActionButton(
                              heroTag: "back",
                              onPressed: () {
                                Get.back();
                              },
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              backgroundColor: Colors.red,
                              child: Text(
                                "취소",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "NotoSansKR",
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
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
          );
        },
      ),
    ),
  );
}

void showGuidePopup(String msg) {
  final List<String> lines = msg.split('\n');
  final List<InlineSpan> spans = [];

  bool nextLineBold = false;

  for (int i = 0; i < lines.length; i++) {
    final currentLine = lines[i].trim();

    // 이전 줄과 현재 줄이 모두 비어있으면 다음 줄을 강조 대상으로 지정
    if (i > 0 && lines[i - 1].trim().isEmpty && currentLine.isNotEmpty || i == 0) {
      nextLineBold = true;
    }

    // 줄 스타일 결정
    final TextStyle style = TextStyle(
      fontSize: nextLineBold
          ? lines.length - 1 == i
              ? 13
              : 14
          : 12,
      fontWeight: nextLineBold ? FontWeight.w500 : FontWeight.w300,
      color: Colors.black,
      fontFamily: "NotoSansKR",
    );

    String addNull = lines.length - 1 == i ? "" : "\n";
    spans.add(TextSpan(text: currentLine + addNull, style: style));

    // 강조는 단 한 줄만, 이후에는 false로 초기화
    nextLineBold = false;
  }

  Get.dialog(
    AlertDialog(
      titlePadding: EdgeInsets.all(10),
      contentPadding: EdgeInsets.only(
        bottom: 25,
        left: 18,
        right: 18,
      ),
      backgroundColor: Colors.white,
      title: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  // Get.back();
                },
                icon: Icon(Icons.bookmark)),
            const Text(
              '가이드라인',
              style: TextStyle(
                color: AppConfig.mainColor,
                fontFamily: "NotoSansKR",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.cancel_outlined)),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: RichText(
          text: TextSpan(children: spans),
          textAlign: TextAlign.start,
        ),
      ),
    ),
  );
}
