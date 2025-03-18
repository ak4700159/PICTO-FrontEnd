import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';

class HttpFunctionController{
  final userSettingThrottle = Throttle(
    Duration(seconds: AppConfig.throttleSec),
    initialValue: false,
    checkEquality: false,
  );

  HttpFunctionController() {
    userSettingThrottle.values.listen((isAccessToken) async {
      UserManagerHandler().setUserAllInfo(isAccessToken);
    });
  }

  void callSetUserAllInfo({required bool isAccessToken}) {
    userSettingThrottle.setValue(isAccessToken);
  }
}
