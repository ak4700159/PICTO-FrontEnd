import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';

import '../config/app_config.dart';

class SocketFunctionController {
  final sessionController = Get.find<SessionSchedulerHandler>();
  final sessionDebouncer = Debouncer<bool>(
    const Duration(seconds: AppConfig.debounceSec),
    initialValue: false,
    checkEquality: false,
  );

  SocketFunctionController() {
    sessionDebouncer.values.listen((connected) {
      if (connected) {
        sessionController.connectWebSocket();
      } else {
        sessionController.disconnectWebSocket();
      }
    });
  }

  void execSession({required bool connected}) {
    sessionDebouncer.setValue(connected);
  }

  void connectChatting() {}
}
