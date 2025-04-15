import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_list_screen.dart';
import 'package:picto_frontend/screens/main_frame_view_model.dart';
import 'package:picto_frontend/screens/bot/chatbot_screen.dart';

import '../icon/picto_icons.dart';
import '../test_screens/ksm_test_screen.dart';
import 'bot/chatbot_list_screen.dart';
import 'comfyui/comfyui_screen.dart';
import 'map/google_map/google_map.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _mapViewModel = Get.find<MapViewModel>();
    return Obx(() =>
        Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Obx(() =>
              FloatingActionButton(
                heroTag: "map",
                backgroundColor: 2 == _mapViewModel.navigationBarCurrentIndex.value
                    ? AppConfig.mainColor
                    : Colors.grey,
                shape: CircleBorder(side: BorderSide(width: 1)),
                onPressed: () {
                  _mapViewModel.changeNavigationBarIndex(2);
                },
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
              )),
          bottomNavigationBar: _getBottomNavigationBar(context),
          body: _getMainFrame(context),
        ));
  }

  // 하단 네비게이션바 호출마다 실행되는 함수
  Widget _getMainFrame(BuildContext context) {
    final mapViewModel = Get.find<MapViewModel>();
    return switch (mapViewModel.navigationBarCurrentIndex.value) {
    // 0 -> 환경설정, 1 -> 포토북, 2-> 지도, 3 -> 공유폴더, 4 -> 프로필설정
    // 수정필요 : 0 -> chat_photo bot / 1 -> comfy ui / 2 -> google map / 3 -> folder / 4 -> profile /
      0 => ChatbotListScreen(),
      1 => ComfyuiScreen(),
      2 => CustomGoogleMap(),
      3 => FolderListScreen(),
      4 => AppBarMenuExample(),
      _ =>
          Center(
            child: Text(
              'error',
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
          ),
    };
  }

  Widget _getBottomNavigationBar(BuildContext context) {
    final List<BottomNavigationBarItem> bottomNavigationBarItems = [
      BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/pictory_grey.png',
            scale: 5,
          ),
          activeIcon: SizedBox(
              child: Image.asset(
                'assets/images/pictory_color.png',
                scale: 5,
              )),
          label: "챗봇 "),
      BottomNavigationBarItem(
          icon: Icon(
            PictoIcons.edit,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            PictoIcons.edit,
            color: AppConfig.mainColor,
          ),
          label: "ComfyUI"),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.line_weight_sharp,
          color: Colors.transparent,
        ),
        activeIcon: Icon(
          Icons.line_weight_sharp,
          color: Colors.transparent,
        ),
        label: "지도",
      ),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.folder,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.folder,
            color: AppConfig.mainColor,
          ),
          label: "폴더"),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.settings,
            color: AppConfig.mainColor,
          ),
          label: "프로필"),
    ];
    final mapViewModel = Get.find<MapViewModel>();

    return BottomAppBar(height: context.mediaQuery.size.height * 0.09,
      color: Colors.white,
      elevation: 0,
      notchMargin: 0,
      // 중요한 속성, 자식의 부모 위젯의 크기를 벗어날 경우 자동으로 잘라줌
      clipBehavior: Clip.antiAlias,
      shape: AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          StadiumBorder(side: BorderSide(width: 2, color: Colors.black))),
      child: Obx(() =>
          MediaQuery(
            data: MediaQuery.of(context).removePadding(removeBottom: true, removeTop: true),
            child: BottomNavigationBar(
              // 그림자 없애기
              elevation: 0,
              onTap: mapViewModel.changeNavigationBarIndex,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: mapViewModel.navigationBarCurrentIndex.value,
              iconSize: 30,
              selectedFontSize: 0,
              items: bottomNavigationBarItems,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
            ),
          )),
    );
  }
}
