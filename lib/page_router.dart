import 'package:get/get.dart';
import 'package:picto_frontend/screens/folder/folder_screen.dart';
import 'package:picto_frontend/screens/login/login_screen.dart';
import 'package:picto_frontend/screens/login/sub_screen/passwd_setting_screen.dart';
import 'package:picto_frontend/screens/main_frame.dart';
import 'package:picto_frontend/screens/login/sub_screen/register_screen.dart';
import 'package:picto_frontend/screens/photo/photo_screen.dart';
import 'package:picto_frontend/screens/splash/splash_screen.dart';
import 'package:picto_frontend/screens/upload/upload_screen.dart';
import 'package:picto_frontend/test_ground/ksm_test_screen.dart';

class PageRouter{
  static List<GetPage> getPages() {
    List<GetPage> pages = [
      GetPage(name: '/splash', page: () => SplashScreen()),
      GetPage(name: '/login', page: () => LoginScreen()),
      GetPage(name: '/register', page: () => RegisterScreen()),
      GetPage(name: '/map', page: () => MapScreen()),
      GetPage(name: '/passwd_setting', page: () => PasswdSettingScreen()),
      GetPage(name: '/photo', page: () => PhotoScreen()),
      GetPage(name: '/folder', page: () => FolderScreen()),
      GetPage(name: '/upload', page: () => UploadScreen()),
      // AI 챗봇 화면
      // ComfyUI 상호 작용 화면
    ];
    return pages;
  }
}