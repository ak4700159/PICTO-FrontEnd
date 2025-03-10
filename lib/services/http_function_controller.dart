import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/services/user_manager_service/handler.dart';

class HttpFunctionController {
  final userSettingThrottle = Debouncer(
    Duration(seconds: AppConfig.debounceSec),
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
