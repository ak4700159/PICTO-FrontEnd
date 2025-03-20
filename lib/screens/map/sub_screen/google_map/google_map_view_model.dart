import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapViewModel extends GetxController {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  RxDouble currentLat = 0.0.obs;
  RxDouble currentLng = 0.0.obs;
  int currentStep = 0;
  late String mapStyleString;
  late CameraPosition currentCameraPos;
  // 지역대표 사진(줌에 따라 변화)
  // zoom [max:] ? [min:]
  // 단계 [large:도/특별시/광역시] ? [middle:시/군/구] ? [small:읍/면/동]
  RxSet<Marker> representativePhotos = <Marker>{}.obs;

  // 3km 이내 주변 사진(사용자 현재 위치 + 낮은 단계 줌배율인 경우)
  RxSet<Marker> aroundPhotos = <Marker>{}.obs;

  // 내 사진(항시)
  RxSet<Marker> myPhotos = <Marker>{}.obs;

  // 공유폴더 사진(항시)
  RxSet<Marker> folderPhotos = <Marker>{}.obs;

  @override
  void onInit() {
    // 지도 양식 로딩
    rootBundle.loadString('assets/map_styles/map_style.json').then((string) {
      mapStyleString = string;
    });
    super.onInit();
  }

  Set<Marker> returnMarkerAccordingToZoom() {
    switch(currentCameraPos.zoom) {

    }
    return folderPhotos;
  }

  void onCameraMove(CameraPosition pos) {
    currentCameraPos = pos;
  }

  void setController(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller); // 최초 1회만 실행됨
    }
  }

  Future<void> getPermission() async {
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

    // 최초 카메라 설정
    Position position = await Geolocator.getCurrentPosition();
    currentLat.value = position.latitude;
    currentLng.value = position.longitude;
    currentCameraPos = CameraPosition(
      target: LatLng(currentLat.value, currentLng.value),
      zoom: 14.4746,
    );
    print("[INFO] now location : ${currentLat.value}/${currentLng.value}\n");
  }
}
