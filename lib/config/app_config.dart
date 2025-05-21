import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/screens/bot/chatbot_view_model.dart';
import 'package:picto_frontend/screens/comfyui/comfyui_view_model.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/folder/sub_screen/folder_selection_view_model.dart';
import 'package:picto_frontend/screens/main_frame_view_model.dart';
import 'package:picto_frontend/screens/map/tag/tag_selection_view_model.dart';
import 'package:picto_frontend/screens/profile/calendar/calendar_view_model.dart';
import 'package:picto_frontend/screens/profile/profile_view_model.dart';
import 'package:picto_frontend/screens/upload/upload_view_model.dart';

import '../screens/folder/sub_screen/invite/folder_invitation_view_model.dart';
import '../screens/login/login_view_model.dart';
import '../screens/login/sub_screen/register_view_model.dart';
import '../screens/map/google_map/cluster/picto_cluster_manager.dart';
import '../screens/map/google_map/google_map_view_model.dart';
import '../screens/map/selection_bar_view_model.dart';
import '../screens/splash/splash_view_model.dart';
import '../services/session_scheduler_service/session_socket.dart';

class AppConfig {
  // bogota.iptime.org : HOME
  // 192.168.255.10 : LAB
  static final ip = "bogota.iptime.org";
  static final httpUrl = "http://$ip";
  static final wsUrl = "ws://$ip";

  // 최대 지연 시간
  static const int maxLatency = 3;

  static const int throttleSec = 3;

  // 화면 정지
  static const int stopScreenSec = 3;

  static const int socketConnectionWaitSec = 1;

  // location send period
  static const int locationSendPeriod = 10;

  // theme data
  static const Color primarySeedColor = Color(0xFF6750A4);
  static const Color secondarySeedColor = Color(0xFF3871BB);
  static const Color tertiarySeedColor = Color(0xFF6CA450);

  // global
  static const Color backgroundColor = Colors.white;
  static const Color mainColor = Color(0xff7038ff);
  static const Color secondaryColor = Color.fromRGBO(209, 197, 252, 1);

  // GetX 등록
  static void enrollGetxController() {
    // 로그인 관련 컨트롤러 ----------------------
    Get.put<SessionSocket>(SessionSocket());
    Get.put<RegisterViewModel>(RegisterViewModel());
    Get.put<SplashViewModel>(SplashViewModel());
    Get.put<LoginViewModel>(LoginViewModel());

    // 로그인 이후 사용될 컨트롤러 ----------------------
    Get.put<PictoClusterManager>(PictoClusterManager());
    Get.put<SelectionBarViewModel>(SelectionBarViewModel());
    Get.put<TagSelectionViewModel>(TagSelectionViewModel());
    Get.put<GoogleMapViewModel>(GoogleMapViewModel());
    Get.put<MapViewModel>(MapViewModel());
    Get.put<UploadViewModel>(UploadViewModel());
    Get.put<FolderViewModel>(FolderViewModel());
    Get.put<FolderSelectionViewModel>(FolderSelectionViewModel());
    Get.put<FolderInvitationViewModel>(FolderInvitationViewModel());

    // 사용자 정보 ----------------------
    Get.put<ProfileViewModel>(ProfileViewModel());
    Get.put<UserConfig>(UserConfig());

    // 챗봇
    Get.put<ChatbotViewModel>(ChatbotViewModel());
    // ComfyUI
    Get.put<ComfyuiViewModel>(ComfyuiViewModel());

    // 캘린더
    Get.put<CalendarViewModel>(CalendarViewModel());
  }

  // NotoSansKR체 적용
  static TextStyle getDefaultTextStyle(Color color, double fontSize, FontWeight fontWeight) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: "NotoSansKR",
      color: color,
    );
  }
}
