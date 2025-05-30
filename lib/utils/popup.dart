import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../config/app_config.dart';

void showErrorPopup(String errorMsg) {
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      titlePadding: EdgeInsets.all(20),
      contentPadding: EdgeInsets.only(
        bottom: 12,
        left: 20,
        right: 20,
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(
            Icons.error,
            color: Colors.red,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              '에러',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          errorMsg,
          style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontFamily: "NotoSansKR",
              fontWeight: FontWeight.w400),
        ),
      ),
    ),
  );
}

void showPositivePopup(String msg) {
  Get.dialog(
    AlertDialog(
      titlePadding: EdgeInsets.all(20),
      contentPadding: EdgeInsets.only(
        bottom: 18,
        left: 12,
        right: 12,
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(
            Icons.info,
            color: Colors.blueAccent,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              '정보',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: "NotoSansKR",
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
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
    ),
  );
}

void showMsgPopup({required String msg, required BuildContext context, required double space}) {
  double width = context.mediaQuery.size.width;
  double height = context.mediaQuery.size.height;
  Get.dialog(
    barrierColor: Colors.transparent,
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
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
                  flex: 2,
                  child: Icon(
                    Icons.info,
                    size: 30,
                    color: AppConfig.mainColor,
                  ),
                ),
                Expanded(
                  flex: 4,
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
          SizedBox(height: height * space,),
        ],
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
                padding: const EdgeInsets.only(top : 12.0),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w500,
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
