import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';
import 'package:picto_frontend/services/socket_controller.dart';
import 'package:picto_frontend/utils/get_widget.dart';

// 맵은 크게 상단 선택바
// 하단 네비게이션바
// 메인 지도 화면으로 이루어진다.

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SocketController interceptor = SocketController();
    SessionSchedulerHandler sessionHandler = Get.find<SessionSchedulerHandler>();
    print('[INFO] ${sessionHandler.status.value}\n');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('/map/${sessionHandler.status.value}')),
            getTestConnectionFloatBtn(context, interceptor),
          ],
        ),
      ),
    );
  }
}
