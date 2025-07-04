import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/location_bottom_sheet.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/utils/popup.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/app_config.dart';
import '../../folder/folder_view_model.dart';
import '../selection_bar.dart';
import 'google_map_view_model.dart';

class CustomGoogleMap extends StatelessWidget {
  const CustomGoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    final folderViewModel = Get.find<FolderViewModel>();
    folderViewModel.isUpdate.value = false;
    return Stack(
      children: [
        // 메인 지도 설정
        Obx(
          () => GoogleMap(
            // 줌 컨트로 버튼 포함 여부
            zoomControlsEnabled: false,
            // 나침반 표시 여부
            compassEnabled: false,
            // 지도 기울이기 허용 여부
            tiltGesturesEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: googleMapViewModel.currentCameraPos,
            onMapCreated: googleMapViewModel.setController,
            style: googleMapViewModel.mapStyleString,
            // 카메라 움직일 때마다 실행되는 콜백 함수
            onCameraMove: googleMapViewModel.onCameraMove,
            // 카메라 이동이 멈출 때 실행되는 콜백 함수
            onCameraIdle: googleMapViewModel.onCameraIdle,
            // small[2~7], middle[7~12], large[12~17]
            // 배율에 따라 마커를 동적으로 변환해야됨
            markers: Set<Marker>.of(googleMapViewModel.currentMarkers),
            minMaxZoomPreference: MinMaxZoomPreference(2, 20),
            // 3D 건물 표현
            buildingsEnabled: false,
            onTap: googleMapViewModel.onTap,
            // 사용자 위치 중심 반경 3km 원
            circles: googleMapViewModel.circles,
          ),
        ),
        // 위젯 정보 표시
        CustomInfoWindow(
          controller: googleMapViewModel.customInfoWindowController,
          height: 55,
          width: 75,
          offset: 20,
        ),
        // 상단 위젯
        Column(
          children: [
            TopBox(size: 0.05),
            SelectionBar(),
            // ValueTestWidget(),
          ],
        ),
        // 하단 Floating buttons
        Positioned(
          bottom: MediaQuery.sizeOf(context).height * 0.1,
          left: MediaQuery.sizeOf(context).width * 0.85,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _getBottomRightFloatingButtons(context),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getBottomRightFloatingButtons(BuildContext context) {
    return [
      // 이미지 재로딩 -> 마커 리셋
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.06,
          child: FloatingActionButton(
            onPressed: ()  {
              final googleMapViewModel = Get.find<GoogleMapViewModel>();
              googleMapViewModel.resetMarker();
            },
            backgroundColor: AppConfig.mainColor,
            heroTag: "reload",
            child: Icon(
              Icons.restart_alt,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
      // 사진 공유
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.06,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.blueAccent,
            heroTag: "share",
            child: PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              menuPadding: EdgeInsets.all(4),
              color: Colors.white,
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              itemBuilder: (context) => <PopupMenuItem>[
                PopupMenuItem(
                  onTap: () {
                    Get.toNamed('/upload');
                  },
                  child: Text(
                    "사진 업로드",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w700),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    showLocationBottomSheet(context);
                    // 액자 걸기 -> 위치 저장
                  },
                  child: Text(
                    "위치 저장하기",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontFamily: "NotoSansKR",
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // 캘린더 이동
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.06,
          child: FloatingActionButton(
            onPressed: () async {
              // 테스트 버튼 주입
              // googleMapViewModel.moveCurrentPos();
              // showErrorPopup("test");
              Get.toNamed('/calendar');
            },
            backgroundColor: Colors.teal,
            heroTag: "calendar",
            child: Icon(
              Icons.newspaper_outlined,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
    ];
  }
}
