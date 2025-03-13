import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:picto_frontend/page_router.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';
import 'package:picto_frontend/services/session_scheduler_service/handler.dart';
import 'package:picto_frontend/theme.dart';

import 'config/app_config.dart';

void main() {
  // 상단 상태바, 하단 네비게이션 바 설정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppConfig.mainColor,
    ),
  );
  runApp(Picto());
}

class Picto extends StatelessWidget {
  Picto({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController =
        Get.put<SessionSchedulerHandler>(SessionSchedulerHandler());
    final splashController = Get.put<SplashViewModel>(SplashViewModel());
    return GetMaterialApp(
      title: 'PICTO APP',
      theme: PictoThemeData.init(),
      getPages: PageRouter.getPages(),
      initialRoute: '/map',
      debugShowCheckedModeBanner: false,
    );
  }
}
