import 'package:get/get.dart';
import 'package:picto_frontend/screens/bot/chatbot_screen.dart';
import 'package:picto_frontend/screens/calendar/calendar_screen.dart';
import 'package:picto_frontend/screens/folder/folder_frame.dart';
import 'package:picto_frontend/screens/folder/sub_screen/folder_create_screen.dart';
import 'package:picto_frontend/screens/folder/sub_screen/folder_info_screen.dart';
import 'package:picto_frontend/screens/folder/sub_screen/folder_selection_screen.dart';
import 'package:picto_frontend/screens/folder/sub_screen/invite/folder_invitation_screen.dart';
import 'package:picto_frontend/screens/folder/sub_screen/invite/folder_invitation_send_screen.dart';
import 'package:picto_frontend/screens/login/login_screen.dart';
import 'package:picto_frontend/screens/login/sub_screen/passwd_setting_screen.dart';
import 'package:picto_frontend/screens/main_frame.dart';
import 'package:picto_frontend/screens/login/sub_screen/register_screen.dart';
import 'package:picto_frontend/screens/map/tag/tag_selection_screen.dart';
import 'package:picto_frontend/screens/photo/photo_chatbot_screen.dart';
import 'package:picto_frontend/screens/photo/photo_comfyui_screen.dart';
import 'package:picto_frontend/screens/photo/photo_screen.dart';
import 'package:picto_frontend/screens/splash/guide_screen.dart';
import 'package:picto_frontend/screens/splash/splash_screen.dart';
import 'package:picto_frontend/screens/upload/upload_screen.dart';
import 'package:picto_frontend/test_screens/test_screen.dart';

class PageRouter {
  static List<GetPage> getPages() {
    List<GetPage> pages = [
      // 테스트 화면
      GetPage(name: '/', page: () => TestScreen()),
      // 로그인 + 지도 관련 화면
      GetPage(name: '/guide', page: () => GuideScreen()),
      GetPage(name: '/splash', page: () => SplashScreen()),
      GetPage(name: '/login', page: () => LoginScreen()),
      GetPage(name: '/register', page: () => RegisterScreen()),
      GetPage(name: '/map', page: () => MapScreen()),
      GetPage(name: '/passwd_setting', page: () => PasswdSettingScreen()),
      GetPage(name: '/photo', page: () => PhotoScreen()),
      GetPage(name: '/upload', page: () => UploadScreen()),
      GetPage(name: '/tag', page: () => TagSelectionScreen()),
      // 폴더 관련 화면
      GetPage(name: '/folder', page: () => FolderFrame()),
      GetPage(name: '/folder/select', page: () => FolderSelectionScreen()),
      GetPage(name: '/folder/info', page: () => FolderInfoScreen()),
      GetPage(name: '/folder/create', page: () => FolderCreateScreen()),
      GetPage(name: '/folder/invite', page: () => FolderInvitationScreen()),
      GetPage(name: '/folder/invite/send', page: () => FolderInvitationSendScreen()),
      // 챗봇
      GetPage(name: '/chatbot', page: () => ChatbotScreen()),
      GetPage(name: '/chatbot/photo', page: () => PhotoChatbotScreen()),
      // comfyUI ? 필요없을지도
      GetPage(name: '/comfyui/photo', page: () => PhotoComfyuiScreen()),

      GetPage(name: '/calendar', page: () => CalendarScreen()),
    ];
    return pages;
  }
}
