import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../services/session_scheduler_service/handler.dart';
import '../services/socket_controller.dart';

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

Widget getTestConnectionFloatBtn(BuildContext context,
    SocketController interceptor) {
  SessionSchedulerHandler sessionHandler = Get.find<SessionSchedulerHandler>();
  return SizedBox(
    width: context.mediaQuery.size.width * 0.5,
    child: FloatingActionButton(
      backgroundColor: AppConfig.mainColor,
      onPressed: () async {
        if (sessionHandler.status.value) {
          interceptor.disconnectSession();
        } else {
          interceptor.connectSession();
        }
      },
      child: Obx(() => Text(
            sessionHandler.status.value
                ? '웹소켓 접속중'
                : '웹소켓 연결 해제',
            style: TextStyle(color: AppConfig.backgroundColor),
          )),
    ),
  );
}
