import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../services/session_scheduler_service/session_socket.dart';
import '../services/socket_function_controller.dart';

InputDecoration getCustomInputDecoration({
  required String label,
  required BorderRadius borderRadius,
  BorderSide? borderSide,
  String? hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    filled: true,
    fillColor: Color.fromRGBO(217, 217, 217, 0.19),
    errorMaxLines: 2,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: borderRadius,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: borderSide ?? BorderSide.none,
      borderRadius: borderRadius,
    ),
    border: OutlineInputBorder(
      borderSide: borderSide ?? BorderSide.none,
      borderRadius: borderRadius,
    ),
    hintStyle: TextStyle(
      fontFamily: "NotoSansKR",
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    labelStyle: TextStyle(
      fontFamily: "NotoSansKR",
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.grey,
    ),
    labelText: label,
    hintText: hintText,
    suffixIcon: suffixIcon,
  );
}

InputDecoration getCustomInputDecoration2(
    {required String label, String? hintText, Widget? suffixIcon}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade300,
    errorMaxLines: 2,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    hintStyle: TextStyle(
      fontFamily: "NotoSansKR",
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppConfig.mainColor,
    ),
    labelStyle: TextStyle(
      fontFamily: "NotoSansKR",
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.grey,
    ),
    labelText: label,
    hintText: hintText,
    suffixIcon: suffixIcon,
  );
}

Widget getTestConnectionFloatBtn(BuildContext context) {
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
