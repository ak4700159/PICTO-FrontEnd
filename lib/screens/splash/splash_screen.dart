import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/screens/splash/splash_view_model.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final splashController = Get.put<SplashViewModel>(SplashViewModel());

  @override
  Widget build(BuildContext context) {
    splashController.loadDataFromStorage();

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/picto_logo.png',
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: context.mediaQuery.size.height * 0.05,
              ),
              Text(
                "PICTO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
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
                            duration: Duration(milliseconds: 2000),
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )
                        ],
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
