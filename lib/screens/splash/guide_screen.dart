import 'dart:math';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../login/login_view_model.dart';

class GuideScreen extends StatelessWidget {
  GuideScreen({super.key});

  final CarouselSliderController _controller = CarouselSliderController();
  final loginViewModel = Get.find<LoginViewModel>();
  final List guideImageNames = [
    "guide1.png",
    "guide2.png",
    "guide4.png",
    "guide3.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            Center(child: sliderWidget(context)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.mediaQuery.size.height * 0.1,
                ),
                sliderIndicator(),
              ],
            ),
            if (loginViewModel.guideSliderIdx.value == 3) startButton(context)
          ],
        ));
  }

  Widget sliderWidget(BuildContext parent) {
    return CarouselSlider(
      carouselController: _controller,
      items: guideImageNames.map(
        (name) {
          return Builder(
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(40),
                color: Colors.white,
                child: Image.asset(
                  "assets/images/$name",
                  fit: BoxFit.fitWidth,
                  width: parent.mediaQuery.size.width,
                  // height: parent.mediaQuery.size.height,
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: parent.mediaQuery.size.height,
        viewportFraction: 1.0,
        autoPlay: false,
        // autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          loginViewModel.guideSliderIdx.value = index;
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: guideImageNames.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 15,
              height: 15,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: loginViewModel.guideSliderIdx.value != entry.key
                    ? Colors.grey.shade200
                    : AppConfig.mainColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget startButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Center(
          child: SizedBox(
            width: context.mediaQuery.size.width * 0.8,
            height: context.mediaQuery.size.height * 0.07,
            child: FloatingActionButton(
              backgroundColor: AppConfig.mainColor,
              onPressed: () {
                Get.offNamed('/login');
              },
              child: Text("PICTO 시작하기",
                style: TextStyle(
                  fontFamily: "NotoSansKR",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: context.mediaQuery.size.height * 0.08,
        ),
      ],
    );
  }
}
