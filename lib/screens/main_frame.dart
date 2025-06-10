import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/folder/folder_list_screen.dart';
import 'package:picto_frontend/screens/folder/folder_view_model.dart';
import 'package:picto_frontend/screens/main_frame_view_model.dart';
import 'package:picto_frontend/screens/map/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/profile/profile_screen.dart';
import 'package:picto_frontend/utils/popup.dart';
import '../icon/picto_icons.dart';
import 'bot/chatbot_rooms_screen.dart';
import 'calendar/calendar_view_model.dart';
import 'comfyui/comfyui_screen.dart';
import 'comfyui/comfyui_view_model.dart';
import 'map/google_map/google_map.dart';

enum MapStatus { googleMap, folder, comfyUI, chatbot, setting }

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("main frame build");
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final mapViewModel = Get.find<MapViewModel>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showSelectionDialog(
            context: context,
            positiveEvent: () {
              SystemNavigator.pop();
            },
            negativeEvent: () {
              Get.back();
            },
            positiveMsg: "네",
            negativeMsg: "아니요",
            content: "나가시겠습니까?");
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Obx(() => SizedBox(
              height: width * 0.2,
              width: width * 0.2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: "map",
                    backgroundColor: 2 == mapViewModel.navigationBarCurrentIndex.value
                        ? AppConfig.mainColor
                        : Colors.grey,
                    shape: CircleBorder(),
                    onPressed: () {
                      if(mapViewModel.navigationBarCurrentIndex.value == 2) {
                        final googleMApViewModel = Get.find<GoogleMapViewModel>();
                        googleMApViewModel.moveCurrentPos();
                      } else {
                        mapViewModel.changeNavigationBarIndex(2);
                      }
                    },
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            )),
        bottomNavigationBar: _getBottomNavigationBar(context),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Obx(() => _getMainFrame(context)),
        ),
      ),
    );
  }

  // 하단 네비게이션바 호출마다 실행되는 함수
  Widget _getMainFrame(BuildContext context) {
    final mapViewModel = Get.find<MapViewModel>();
    final comfyuiViewModel = Get.find<ComfyuiViewModel>();
    if (mapViewModel.navigationBarCurrentIndex.value == 4) {
      // calendarViewModel.buildCalendarEventMap(folderViewModel.convertCalendarEvent());
    } else if (mapViewModel.navigationBarCurrentIndex.value != 1) {
      comfyuiViewModel.reset();
    }
    return switch (mapViewModel.navigationBarCurrentIndex.value) {
      // 수정필요 : 0 -> chat_photo bot / 1 -> comfy ui / 2 -> google map / 3 -> folder / 4 -> profile /
      0 => ChatbotListScreen(),
      1 => ComfyuiScreen(),
      2 => CustomGoogleMap(),
      3 => FolderListScreen(),
      4 => ProfileScreen(),
      _ => Center(
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
            Icons.person,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.person,
            color: AppConfig.mainColor,
          ),
          label: "프로필"),
    ];
    final mapViewModel = Get.find<MapViewModel>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: BottomAppBar(
        padding: EdgeInsets.all(0),
        shadowColor: Colors.grey,
        height: MediaQuery.sizeOf(context).height * 0.08,
        color: Colors.grey.shade100,
        elevation: 0,
        notchMargin: 8,
        // 중요한 속성, 자식의 부모 위젯의 크기를 벗어날 경우 자동으로 잘라줌
        clipBehavior: Clip.antiAlias,
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(
            // side: BorderSide(color: Colors.black, width: 10),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          StadiumBorder(side: BorderSide(width: 10)),
        ),
        child: Obx(
          () => BottomNavigationBar(
            // 그림자 없애기
            elevation: 0,
            onTap: mapViewModel.changeNavigationBarIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: mapViewModel.navigationBarCurrentIndex.value,
            iconSize: 30,
            selectedFontSize: 0,
            items: bottomNavigationBarItems,
            backgroundColor: Colors.grey.shade100,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
