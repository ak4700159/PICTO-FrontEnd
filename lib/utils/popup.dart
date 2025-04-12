import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../config/app_config.dart';

void showErrorPopup(String errorMsg) {
  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(
            Icons.error,
            color: Colors.red,
          ),
          const Text('[ERROR INFO]'),
        ],
      ),
      content: SingleChildScrollView(
          child: Text(
        errorMsg,
      )),
      actions: [
        // TextButton(
        //   child: const Text("닫기"),
        //   onPressed: () => Get.back(),
        // ),
      ],
    ),
  );
}

void showPositivePopup(String errorMsg) {
  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(
            Icons.info,
            color: AppConfig.mainColor,
          ),
          const Text('[INFO]'),
        ],
      ),
      content: SingleChildScrollView(
          child: Text(
        errorMsg,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )),
      actions: [
        // TextButton(
        //   child: const Text("닫기"),
        //   onPressed: () => Get.back(),
        // ),
      ],
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
