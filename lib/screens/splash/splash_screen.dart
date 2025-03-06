import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final splashController = Get.put<SplashViewModel>(SplashViewModel());

  @override
  Widget build(BuildContext context) {
    splashController.initStatus();

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PictoLogo(scale: 1, fontSize: 30,),
              SizedBox(
                width: context.mediaQuery.size.width,
                height: context.mediaQuery.size.height * 0.03,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => AnimatedTextKit(
                        animatedTexts: [
                          FadeAnimatedText(
                            splashController.statusMsg.value,
                            duration: Duration(milliseconds: 3000),
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
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
}
