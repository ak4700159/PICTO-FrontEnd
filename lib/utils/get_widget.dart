import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../services/session_scheduler_service/handler.dart';
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

Widget getTestConnectionFloatBtn(
    BuildContext context) {
  SocketFunctionController interceptor = SocketFunctionController();
  SessionSchedulerHandler sessionHandler = Get.find<SessionSchedulerHandler>();
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Obx(() => Text('/map/${sessionHandler.connected.value}')),
      SizedBox(
        width: context.mediaQuery.size.width * 0.5,
        child: FloatingActionButton(
          backgroundColor: AppConfig.mainColor,
          onPressed: () {
            interceptor.callSession(connected: !sessionHandler.connected.value);
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
