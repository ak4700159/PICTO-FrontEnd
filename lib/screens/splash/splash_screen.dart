import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashViewModel>();
    splashController.userSettingDebouncer.setValue(null);
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PictoLogo(
                scale: 1,
                fontSize: 30,
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.03,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText(
                            splashController.statusMsg.value,
                            duration: Duration(seconds: AppConfig.stopScreenSec),
                            textStyle: _getTextStyle(),
                          )
                        ],
                        totalRepeatCount: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  TextStyle _getTextStyle() {
    final splashController = Get.find<SplashViewModel>();
    return switch(splashController.statusMsg.value) {
      "서버 오류 : 엑세스 토큰 발행 문제" => TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
      "서버 오류 : 잠시 후 이용해주세요" => TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
      _ => TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    };
  }
}
