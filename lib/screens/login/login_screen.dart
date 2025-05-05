import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/login/login_view_model.dart';
import 'package:picto_frontend/utils/get_widget.dart';
import 'package:picto_frontend/utils/validator.dart';
import 'package:picto_frontend/widgets/picto_logo.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _loginController = Get.find<LoginViewModel>();
  final CarouselSliderController _controller = CarouselSliderController();
  List imageList = [
    "https://cdn.pixabay.com/photo/2014/04/14/20/11/pink-324175_1280.jpg",
    "https://cdn.pixabay.com/photo/2014/02/27/16/10/flowers-276014_1280.jpg",
    "https://cdn.pixabay.com/photo/2012/03/01/00/55/flowers-19830_1280.jpg",
    "https://cdn.pixabay.com/photo/2015/06/19/20/13/sunset-815270_1280.jpg",
    "https://cdn.pixabay.com/photo/2016/01/08/05/24/sunflower-1127174_1280.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    double widgetHeight = context.mediaQuery.size.height;
    double widgetWidth = context.mediaQuery.size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 외부 터치 시 키보드 내림
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: context.mediaQuery.size.height * 0.05),
                  PictoLogo(scale: 1.2, fontSize: 30),
                  SizedBox(height: widgetHeight * 0.02),
                  // 이메일 입력칸
                  Container(
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1, color: Colors.grey.shade300))),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: getCustomInputDecoration(
                          label: "이메일",
                          hintText: "your@eamil.com",
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25), topLeft: Radius.circular(25))),
                      validator: emailValidator,
                      onSaved: (value) => _loginController.email.value = value!,
                    ),
                  ),
                  // 비밀번호 입력칸
                  Obx(
                    () => TextFormField(
                      obscureText: _loginController.isPasswordVisible.value,
                      decoration: getCustomInputDecoration(
                          label: "비밀번호",
                          suffixIcon: IconButton(
                            icon: Icon(
                              !_loginController.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              _loginController.togglePasswordVisible();
                            },
                          ),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25))),
                      validator: passwdValidator,
                      onSaved: (value) => _loginController.passwd.value = value!,
                    ),
                  ),
                  SizedBox(height: widgetHeight * 0.02),
                  // 텍스트 버튼(login)
                  Container(
                    decoration: BoxDecoration(
                      color: AppConfig.mainColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: widgetHeight * 0.07,
                    width: widgetWidth,
                    child: TextButton(
                      onPressed: _login,
                      child: Obx(() => _loggingText()),
                    ),
                  ),
                  SizedBox(height: widgetHeight * 0.01),
                  // 회원가입 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // TextButton(
                      //   onPressed: () {
                      //     // 비밀번호 새로 등록 화면 이동
                      //     Get.toNamed('/passwd_setting');
                      //   },
                      //   child: Text(
                      //     '비밀번호를 잊으셨나요?',
                      //     style: TextStyle(fontSize: 14, color: Colors.black),
                      //   ),
                      // ),
                      TextButton(
                        onPressed: () {
                          // 회원가입 페이지 이동
                          Get.toNamed('/register');
                        },
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            fontFamily: "NotoSansKR",
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: Colors.blue,
                        width: context.mediaQuery.size.width,
                        height: context.mediaQuery.size.height * 0.2,
                        child: Stack(
                          children: [
                            sliderWidget(context),
                            sliderIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    // step1. FormField 검사 -> value 저장
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // step2. 서버 로그인 시도
      _loginController.login();
    }
  }

  Widget _loggingText() {
    if (_loginController.loginStatus.value == "not") {
      return Text(
        "로그인",
        style: TextStyle(
          fontFamily: "NotoSansKR",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    } else if (_loginController.loginStatus.value == "loading") {
      return Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(
          color: AppConfig.backgroundColor,
        ),
      );
    } else if (_loginController.loginStatus.value == "fail") {
      return Text(
        "다시 로그인해주세요.",
        style: TextStyle(
          fontFamily: "NotoSansKR",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }
    return Text(
      "로그인 성공!",
      style: TextStyle(
        fontFamily: "NotoSansKR",
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget sliderWidget(BuildContext parent) {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
        (imgLink) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    imgLink,
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: parent.mediaQuery.size.height * 0.2,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          Get.find<LoginViewModel>().sliderIdx.value = index;
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                    Get.find<LoginViewModel>().sliderIdx.value == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
