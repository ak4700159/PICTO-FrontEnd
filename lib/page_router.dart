import 'package:get/get.dart';
import 'package:picto_frontend/screens/login/login_screen.dart';
import 'package:picto_frontend/screens/splash/splash_screen.dart';
import 'package:picto_frontend/test_ground/ksm_test_screen.dart';

class PageRouter{
  static List<GetPage> getPages() {
    List<GetPage> pages = [
      GetPage(name: '/ksm_test_ground', page: () => TestScreen()),
      GetPage(name: '/splash', page: () => SplashScreen()),
      GetPage(name: '/login', page: () => LoginScreen()),
      // 회원 가입
      // 사진 선택
      // 사용자 보인 프로필
      // 폴더 리스트
      // 지도
      // 포토북, 실시간
      // 사진 업로드
    ];
    return pages;
  }
}