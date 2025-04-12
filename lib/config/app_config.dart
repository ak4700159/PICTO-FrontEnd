import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/user_config.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/main_frame_view_model.dart';
import 'package:picto_frontend/screens/map/tag/tag_selection_view_model.dart';
import 'package:picto_frontend/screens/photo/photo_view_model.dart';
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

  // GetX 등록
  static void enrollGetxController () {
    // 로그인 관련 컨트롤러 ----------------------
    final sessionHandler = Get.put<SessionSocket>(SessionSocket());
    final registerViewModle = Get.put<RegisterViewModel>(RegisterViewModel());
    final splashViewModel = Get.put<SplashViewModel>(SplashViewModel());
    final loginViewModel = Get.put<LoginViewModel>(LoginViewModel());

    // 로그인 이후 사용될 컨트롤러 ----------------------
    final pictoClusterManager = Get.put<PictoClusterManager>(PictoClusterManager());
    final selectionViewModel = Get.put<SelectionBarViewModel>(SelectionBarViewModel());
    final tagSelectionViewModel = Get.put<TagSelectionViewModel>(TagSelectionViewModel());
    final googleViewModel = Get.put<GoogleMapViewModel>(GoogleMapViewModel());
    final mapViewModel = Get.put<MapViewModel>(MapViewModel());
    final photoViewModel = Get.put<PhotoViewModel>(PhotoViewModel());
    final uploadViewModel = Get.put<UploadViewModel>(UploadViewModel());
    final folderViewModel = Get.put<FolderViewModel>(FolderViewModel());
    final folderInvitationViewModel = Get.put<FolderInvitationViewModel>(FolderInvitationViewModel());

    // 사용자 정보 ----------------------
    final profileViewModel = Get.put<ProfileViewModel>(ProfileViewModel());
    final userConfig = Get.put<UserConfig>(UserConfig());

    // NEW VIEWMODEL ----------------------
    // 챗봇 스트리밍
    // ComfyUI
  }
}