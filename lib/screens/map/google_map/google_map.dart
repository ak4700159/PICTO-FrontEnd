import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/top_box.dart';
import 'package:picto_frontend/screens/map/value_test_widget.dart';
import 'package:picto_frontend/utils/location.dart';
import 'package:picto_frontend/utils/popup.dart';

import '../../../../config/app_config.dart';
import '../selection_bar.dart';
import 'google_map_view_model.dart';

class CustomGoogleMap extends StatelessWidget {
  const CustomGoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
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
            minMaxZoomPreference: MinMaxZoomPreference(2, 17),
            // 3D 건물 표현
            buildingsEnabled: false,
            onTap: googleMapViewModel.onTap,
          ),
        ),
        CustomInfoWindow(
          controller: googleMapViewModel.customInfoWindowController,
          height: 70,
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
          bottom: context.mediaQuery.size.height * 0.02,
          left: context.mediaQuery.size.width * 0.85,
          child: SizedBox(
            width: context.mediaQuery.size.width * 0.15,
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
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    return [
      // 로그아웃
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: context.mediaQuery.size.height * 0.06,
          child: FloatingActionButton(
            onPressed: () {
              // 저장된 shared preferences 초기화 후 로그인 화면으로 이동
              Get.offNamed('/login');
            },
            backgroundColor: Colors.orange,
            heroTag: "exit",
            child: Icon(
              Icons.exit_to_app,
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
          height: context.mediaQuery.size.height * 0.06,
          child: FloatingActionButton(
            onPressed: () {
              // 사진 공유 화면으로 이동
              Get.toNamed('/upload');
            },
            backgroundColor: Colors.blueAccent,
            heroTag: "share",
            child: Icon(
              Icons.add,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
      // 예비 버튼
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: context.mediaQuery.size.height * 0.06,
          child: FloatingActionButton(
            onPressed: () async {
              // 테스트 버튼 주입
              // googleMapViewModel.moveCurrentPos();
              // showErrorPopup("test");
              final googleViewModel = Get.find<GoogleMapViewModel>();
              final location = await fetchAddressFromKakao(
                  latitude: googleViewModel.currentLat.value,
                  longitude: googleViewModel.currentLng.value);
              print("[INFO] ${location.toString()}");
            },
            backgroundColor: Colors.grey,
            heroTag: "test",
            child: Icon(
              Icons.hourglass_empty,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
    ];
  }
}
