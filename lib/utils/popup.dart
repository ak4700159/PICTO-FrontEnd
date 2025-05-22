import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../config/app_config.dart';

void showErrorPopup(String errorMsg) {
  Get.dialog(
    AlertDialog(
      titlePadding: EdgeInsets.all(20),
      contentPadding: EdgeInsets.only(
        bottom: 12,
        left: 12,
        right: 12,
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
              'ERROR INFO',
              style:
                  TextStyle(fontSize: 16, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          errorMsg,
          style: TextStyle(fontSize: 14, color: Colors.red, fontFamily: "NotoSansKR", fontWeight: FontWeight.w400),
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
        bottom: 12,
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
              'INFO',
              style:
                  TextStyle(fontSize: 16, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          msg,
          style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: "NotoSansKR", fontWeight: FontWeight.w400),
        ),
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

void exitPopup(String msg) {}
