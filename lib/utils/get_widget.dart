import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../models/user.dart';
import '../services/photo_store_service/photo_store_api.dart';
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
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    labelStyle: TextStyle(
      fontFamily: "NotoSansKR",
      fontSize: 12,
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
        width: MediaQuery.sizeOf(context).width * 0.5,
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

Widget getUserProfile({required User user, required BuildContext context, required double size, required double scale}) {
  if(size > 1.0 || size < 0) {
    throw Exception("사이즈 오류");
  }

  if(scale > 1.0 || scale < 0) {
    throw Exception("스케일 오류");
  }

  return FutureBuilder(
    future: PhotoStoreApi().downloadUserProfile(userId: user.userId!, scale: scale),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).width * size,
          width: MediaQuery.sizeOf(context).width * size,
          child: Center(
            child: SizedBox(
                height: MediaQuery.sizeOf(context).width * size / 2,
                width: MediaQuery.sizeOf(context).width * size / 2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                )),
          ),
        );
      }

      if (snapshot.hasError) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).width * size,
          width: MediaQuery.sizeOf(context).width * size,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            // 아이콘 다른 사용자
            child: Icon(Icons.person, color: Colors.grey[800]),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          height: MediaQuery.sizeOf(context).width * size,
          width: MediaQuery.sizeOf(context).width * size,
          errorBuilder: (context, object, trace) {
            return Image.asset(
              "assets/images/picto_logo.png",
              fit: BoxFit.cover,
              height: MediaQuery.sizeOf(context).width * size,
              width: MediaQuery.sizeOf(context).width * size,
            );
          },
        ),
      );
    },
  );
}

// stomp 테스트 .. ?
