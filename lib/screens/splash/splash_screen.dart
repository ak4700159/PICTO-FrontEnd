/*
1. 내부에 저장된 이메일, 비밀번호, 사용자 식별키, 엑세스 토큰, 리프레쉬 토큰을 로딩
2. 사용자 프로필 호출 -> 이때 리프레쉬 토큰까지 만료되었다면 재로그인.
3. 지도 로딩 전 필요한 사진 데이터 로딩
4. 세션 스케줄러와 연결
5. 된다면 도움말 표시하기
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/picto_logo.png',
                  height: context.mediaQuery.size.height * 0.5,
                  width: context.mediaQuery.size.height * 0.5,
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}
