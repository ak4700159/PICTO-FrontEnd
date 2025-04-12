import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../services/session_scheduler_service/session_socket.dart';
import '../services/socket_function_controller.dart';

InputDecoration getCustomInputDecoration(
    {required String label, String? hintText, Widget? suffixIcon}) {
  return InputDecoration(
    errorMaxLines: 2,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
    labelText: label,
    hintText: hintText,
    suffixIcon: suffixIcon,
  );
}

InputDecoration getCustomInputDecoration2(
    {required String label, String? hintText, Widget? suffixIcon}) {
  return InputDecoration(
    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    errorMaxLines: 2,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    labelText: label,
    hintText: hintText,
    suffixIcon: suffixIcon,
  );
}

Widget getTestConnectionFloatBtn(
    BuildContext context) {
  SocketFunctionController socketInterceptor = Get.find<SocketFunctionController>();
  SessionSocket sessionHandler = Get.find<SessionSocket>();
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Obx(() => Text('/map/${sessionHandler.connected.value}')),
      SizedBox(
        width: context.mediaQuery.size.width * 0.5,
        child: FloatingActionButton(
          backgroundColor: AppConfig.mainColor,
          onPressed: () {
            socketInterceptor.callSession(connected: !sessionHandler.connected.value);
          },
          child: Obx(() => Text(
                sessionHandler.connected.value ? '웹소켓 접속중' : '웹소켓 연결 해제',
                style: TextStyle(color: AppConfig.backgroundColor),
              )),
        ),
      ),
    ],
  );
}

// stomp 테스트 .. ?
