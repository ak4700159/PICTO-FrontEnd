import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/screens/map/map_view_model.dart';
import 'package:picto_frontend/screens/map/sub_screen/google_map.dart';
import 'package:picto_frontend/screens/map/sub_screen/selection_bar.dart';

// 맵은 크게 상단 선택바
// 하단 네비게이션바
// 메인 지도 화면으로 이루어진다.

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _mapViewModel = Get.put(MapViewModel());
    _getPermission();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConfig.mainColor,
        shape: CircleBorder(side: BorderSide(width: 1)),
        onPressed: () {
          _mapViewModel.changeNavigationBarIndex(2);
        },
        child: Icon(
          Icons.location_on,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: _getBottomNavigationBar(context),
      body: SizedBox(
        width: context.mediaQuery.size.width,
        child: Column(
          children: [
            SelectionBar(),
            SingleChildScrollView(
              child: SizedBox(
                  height: context.mediaQuery.size.height * 0.6,
                  child: Obx(() => _getMainFrame(context))),
            ),
          ],
        ),
      ),
    );
  }

  void _getPermission() async {
    // 위치 정보 획득 가능한지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('permissions are denied');
      }
    }

    // 현재 위치 구하기
    Position position = await Geolocator.getCurrentPosition();
    String latitude = position.latitude.toString();
    String longitude = position.longitude.toString();
    print("[INFO] now location : $latitude/$longitude\n");
  }

  Widget _getMainFrame(BuildContext context) {
    final mapViewModel = Get.find<MapViewModel>();
    return switch (mapViewModel.navigationBarCurrentIndex.value) {
      // 0 -> 확경설정, 1 -> 포토북, 3 -> 공유폴더, 4 -> 프로필설정
      2 => CustomGoogleMap(),
      _ => Center(
          child: Text('error'),
        ),
    };
  }

  Widget _getBottomNavigationBar(BuildContext context) {
    final List<BottomNavigationBarItem> bottomNavigationBarItems = [
      BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.settings,
            color: Colors.black,
          ),
          label: "환경 설정"),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.bookmark,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.bookmark,
            color: Colors.black,
          ),
          label: "포토북"),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.line_weight_sharp,
          color: AppConfig.mainColor,
        ),
        label: "empty",
      ),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.folder,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.folder,
            color: Colors.black,
          ),
          label: "폴더"),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.perm_device_info_outlined,
            color: Colors.grey,
          ),
          activeIcon: Icon(
            Icons.perm_device_info_outlined,
            color: Colors.black,
          ),
          label: "프로필")
    ];
    final mapViewModel = Get.find<MapViewModel>();

    return BottomAppBar(
      color: Colors.deepPurple,
      elevation: 0,
      notchMargin: 1,
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
      child: Obx(() => BottomNavigationBar(
            // 그림자 없애기
            elevation: 0,
            onTap: mapViewModel.changeNavigationBarIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: mapViewModel.navigationBarCurrentIndex.value,
            iconSize: 30,
            selectedFontSize: 10,
            items: bottomNavigationBarItems,
            backgroundColor: Colors.deepPurple,
            type: BottomNavigationBarType.fixed,
          )),
    );
  }
}
