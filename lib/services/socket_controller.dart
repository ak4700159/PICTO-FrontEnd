import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';

import '../config/app_config.dart';

class SocketController {
  final sessionController = Get.find<SessionSchedulerHandler>();
  final sessionDebouncer = Debouncer<bool>(
    const Duration(seconds: AppConfig.debounceSec),
    initialValue: false,
    checkEquality: false,
  );

  SocketController() {
    sessionDebouncer.values.listen((exit) {
      if (exit) {
        sessionController.disconnectWebSocket();
      } else {
        sessionController.connectWebSocket();
      }
    });
  }

  void connectSession() async {
    sessionDebouncer.setValue(false);
  }

  void disconnectSession() {
    sessionDebouncer.setValue(true);
  }

  void connectChatting() {}
}
