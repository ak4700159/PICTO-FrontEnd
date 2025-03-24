import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map/google_map_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/top_box.dart';
import 'package:picto_frontend/screens/map/sub_screen/value_test_widget.dart';

import '../../../../config/app_config.dart';
import '../selection_bar.dart';

class CustomGoogleMap extends StatelessWidget {
  const CustomGoogleMap({super.key});

  @override
  Widget build(BuildContext context) {
    final googleMapViewModel = Get.find<GoogleMapViewModel>();
    return Stack(
      children: [
        // 메인 지도 설정
        GoogleMap(
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: googleMapViewModel.currentCameraPos,
          onMapCreated: googleMapViewModel.setController,
          style: googleMapViewModel.mapStyleString,
          onCameraMove: googleMapViewModel.onCameraMove,
          markers: googleMapViewModel.returnMarkerAccordingToZoom(),
          // small[2~7], middle[7~12], large[12~17]
          minMaxZoomPreference: MinMaxZoomPreference(2, 17),
        ),
        // 상단 위젯
        Column(
          children: [
            TopBox(size: 0.05),
            SelectionBar(),
            ValueTestWidget(),
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
            },
            backgroundColor: AppConfig.mainColor,
            heroTag: "exit",
            child: Icon(
              Icons.exit_to_app,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
      // 사진공유
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: context.mediaQuery.size.height * 0.06,
          child: FloatingActionButton(
            onPressed: () {
              // 사진 공유 화면으로 이동
            },
            backgroundColor: AppConfig.mainColor,
            heroTag: "share",
            child: Icon(
              Icons.add,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
      // 예비버튼
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: context.mediaQuery.size.height * 0.06,
          child: FloatingActionButton(
            onPressed: () {
              // 테스트 버튼 주입
              googleMapViewModel.moveCurrentPos();
            },
            backgroundColor: AppConfig.mainColor,
            heroTag: "reload",
            child: Icon(
              Icons.cached,
              color: AppConfig.backgroundColor,
              size: 30,
            ),
          ),
        ),
      ),
    ];
  }
}
