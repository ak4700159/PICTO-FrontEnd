import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

void showErrorPopup(String errorMsg) {
  Get.dialog(
    AlertDialog(
      shape: BeveledRectangleBorder(),
      title: Row(
        children: [
          const Icon(Icons.error,  color: Colors.red,),
          const Text('[ERROR INFO]'),
        ],
      ),
      content: SingleChildScrollView(child: Text(errorMsg,)),
      actions: [
        TextButton(
          child: const Text("닫기"),
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );
}

void exitPopup(String msg) {

}